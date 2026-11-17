//
//  CrashRecorder.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// R_04, R_05, R_07, on the calling (crashing) thread: resolves `exception.callStackReturnAddresses` (at most 64),
/// describes them (R_08), classifies frames in the SDK's image by its UUID (others: name, no UUID), builds
/// `PendingRecord(id: "<sessionId>-<sequence.next()>", sessionId:, event: .crash(error: .from(exception, frames:),
/// source: .nsException, kind: .exception, inSdk:, crashReason: exception.name.rawValue, threadName:), createdAt:
/// clock.now())`, `Allowlist.filter(RecordFactory.create(_, connection: connection.current()))`, saves it with
/// `saveCrash(_, timeout: crashLockTimeoutSeconds)` only when it has `session.id` and `log.record.uid`, then saves the
/// marker when a frame lies in the SDK's image. Thread name: "main" on the main thread, else `Thread.current.name`
/// when not empty, else nil. Never reads the exception's reason or user info, and never prunes or reads the store.
package final class CrashRecorder: CrashRecording, @unchecked Sendable {
    private let sessionId: String
    private let sequence: RecordSequence
    private let store: any DurableStore
    private let stateStore: any TelemetryStateStore
    private let image: @Sendable () -> SdkImage?
    private let classifier: FrameClassifierBox
    private let resolver: any AddressResolving
    private let connection: any ConnectionMonitor
    private let clock: any Clock

    package init(sessionId: String, sequence: RecordSequence, store: any DurableStore,
                 stateStore: any TelemetryStateStore, image: @escaping @Sendable () -> SdkImage?,
                 classifier: FrameClassifierBox, resolver: any AddressResolving,
                 connection: any ConnectionMonitor, clock: any Clock) {
        self.sessionId = sessionId
        self.sequence = sequence
        self.store = store
        self.stateStore = stateStore
        self.image = image
        self.classifier = classifier
        self.resolver = resolver
        self.connection = connection
        self.clock = clock
    }

    package func record(_ exception: NSException) {
        let sdkImage = image()
        let addresses = exception.callStackReturnAddresses.prefix(TelemetryEvent.ErrorInfo.maxFrames).map(\.uintValue)
        var described: [String] = []
        var frames: [FrameAddress] = []
        var topSdkImageOffset: UInt64?
        for address in addresses {
            let resolved = resolver.resolve(address)
            described.append(StackFrame.describe(address, resolved))
            guard let frame = Self.frame(address, resolved, sdkImage: sdkImage) else {
                continue
            }
            frames.append(frame)
            if frame.uuid != nil, topSdkImageOffset == nil {
                topSdkImageOffset = frame.offset
            }
        }
        let event = TelemetryEvent.crash(
            error: .from(exception, frames: described), source: .nsException, kind: .exception,
            inSdk: classifier.current?.inSdk(frames), crashReason: exception.name.rawValue, threadName: Self.threadName()
        )
        let pending = PendingRecord(id: "\(sessionId)-\(sequence.next())", sessionId: sessionId, event: event,
                                    createdAt: clock.now())
        let record = Allowlist.filter(RecordFactory.create(pending, connection: connection.current()))
        guard record.value("session.id") != nil, record.value("log.record.uid") != nil,
              store.saveCrash(record, timeout: TelemetryLimits.crashLockTimeoutSeconds) else {
            return
        }
        guard let sdkImage, let topSdkImageOffset else {
            return
        }
        stateStore.saveCrashMarker(
            CrashMarker(sessionId: sessionId, imageUUID: sdkImage.uuid, topFrameOffset: topSdkImageOffset,
                        time: clock.now()),
            timeout: TelemetryLimits.crashLockTimeoutSeconds
        )
    }

    /// A frame in the SDK's image (same load address) carries the image's UUID; a frame in another image only its
    /// name. An unresolved address gives no frame to classify.
    private static func frame(_ address: UInt, _ resolved: ResolvedAddress?, sdkImage: SdkImage?) -> FrameAddress? {
        guard let resolved, address >= resolved.imageLoadAddress else {
            return nil
        }
        let offset = UInt64(address - resolved.imageLoadAddress)
        if let sdkImage, resolved.imageLoadAddress == sdkImage.loadAddress {
            return FrameAddress(imageName: sdkImage.name, uuid: sdkImage.uuid, offset: offset)
        }
        return FrameAddress(imageName: (resolved.imagePath as NSString).lastPathComponent, uuid: nil, offset: offset)
    }

    private static func threadName() -> String? {
        if Thread.isMainThread {
            return "main"
        }
        guard let name = Thread.current.name, !name.isEmpty else {
            return nil
        }
        return name
    }
}
#endif
