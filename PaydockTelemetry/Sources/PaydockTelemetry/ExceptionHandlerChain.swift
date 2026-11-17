//
//  ExceptionHandlerChain.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// R_03, R_06: one link per process in the uncaught-exception handler chain. It records the exception, then always
/// hands it to the handler it replaced, so the merchant's own crash handling runs unchanged. `shared` uses the system
/// slot; its entry point is a C function calling `shared.handle`.
package final class ExceptionHandlerChain: @unchecked Sendable {
    package static let shared: ExceptionHandlerChain = ExceptionHandlerChain(
        slot: SystemExceptionHandlerSlot(),
        entryPoint: { exception in ExceptionHandlerChain.shared.handle(exception) }
    )

    /// Set in the handling thread's dictionary while it handles an exception.
    private static let handlingKey = "com.paydock.telemetry.handlingUncaughtException"

    private let slot: any ExceptionHandlerSlot
    private let entryPoint: @convention(c) (NSException) -> Void
    private let lock = NSLock()
    private var recorder: (any CrashRecording)?
    private var previousHandler: (@convention(c) (NSException) -> Void)?
    private var installed = false

    package init(slot: any ExceptionHandlerSlot, entryPoint: @convention(c) (NSException) -> Void) {
        self.slot = slot
        self.entryPoint = entryPoint
    }

    /// First call: previous = slot.get(), slot.set(entryPoint), installed only once the slot holds the entry point.
    /// Later calls: swap the recorder only. NSLock.
    package func install(_ recorder: any CrashRecording) {
        lock.lock()
        defer { lock.unlock() }
        self.recorder = recorder
        guard !installed else {
            return
        }
        let current = slot.get()
        // The entry point already in the slot is not a previous handler: forwarding to it would loop.
        let previous = current.flatMap { Self.isSame($0, entryPoint) ? nil : $0 }
        slot.set(entryPoint)
        guard let now = slot.get(), Self.isSame(now, entryPoint) else {
            return
        }
        previousHandler = previous
        installed = true
    }

    /// Records with the current recorder unless re-entered on this thread (a thread-dictionary flag), then always
    /// calls the previous handler with the same exception (`defer`). A re-entered call, as when a handler down the
    /// chain hands the exception back to this one, does neither: the outer call has recorded and forwards once.
    package func handle(_ exception: NSException) {
        let flags = Thread.current.threadDictionary
        guard flags[Self.handlingKey] == nil else {
            return
        }
        flags[Self.handlingKey] = true
        let (recorder, previous) = snapshot()
        defer {
            previous?(exception)
            flags[Self.handlingKey] = nil
        }
        recorder?.record(exception)
    }

    package var previous: (@convention(c) (NSException) -> Void)? {
        lock.lock()
        defer { lock.unlock() }
        return previousHandler
    }

    package var isInstalled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return installed
    }

    private func snapshot() -> (recorder: (any CrashRecording)?,
                                previous: (@convention(c) (NSException) -> Void)?) {
        lock.lock()
        defer { lock.unlock() }
        return (recorder, previousHandler)
    }

    private static func isSame(_ lhs: @convention(c) (NSException) -> Void,
                               _ rhs: @convention(c) (NSException) -> Void) -> Bool {
        unsafeBitCast(lhs, to: UnsafeRawPointer.self) == unsafeBitCast(rhs, to: UnsafeRawPointer.self)
    }
}
#endif
