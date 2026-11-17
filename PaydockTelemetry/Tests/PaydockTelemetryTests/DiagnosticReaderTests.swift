//
//  DiagnosticReaderTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_10, R_11 (Android `ExitReportReaderTest` where it applies): diagnostics become crash events, the old ones and
/// the one crash the handler already recorded skipped.
final class DiagnosticReaderTests: XCTestCase {

    private static let uuid = "C95ED3C1-F639-3822-BC5C-B2D03AFDD182"
    private static let previousUUID = "0D4E6A1B-2C3F-3A5B-9C8D-7E6F5A4B3C2D"
    private static let uikitUUID = "3E0F5B7A-9C1D-3F2E-A4B5-C6D7E8F90A1B"
    private static let now: Int64 = 1_793_852_047_512
    private static let maxAge = TelemetryLimits.recordMaxAgeMilliseconds
    private static let sdkOffset: UInt64 = 0x1b5058
    private static let appOffset: UInt64 = 0x2251a8
    private static let classifier = FrameClassifier(builds: [
        FramePoints(imageName: "ExampleApp", uuid: uuid, sdkRanges: [0x1b4000...0x1b6000])
    ])

    // MARK: - Events

    func testACrash_IsASignalCrashEvent_WithNamesFramesItsTime_AndInSdkByUUID() {
        let crash = Self.crash(exceptionType: 1, signal: 11, frames: [
            Self.app(Self.sdkOffset), Self.app(0x1b4d08), DiagnosticFrame(binaryName: "UIKitCore", binaryUUID: Self.uikitUUID,
                                                                           offset: 0x58f740)
        ], timeEnd: Self.now - 3_600_000)

        let result = DiagnosticReader.events([crash], marker: nil, classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(result.events, [
            .crash(error: TelemetryEvent.ErrorInfo(type: "EXC_BAD_ACCESS", frames: [
                "ExampleApp 0x1b5058", "ExampleApp 0x1b4d08", "UIKitCore 0x58f740"
            ]), source: .metricKit, kind: .signal, inSdk: true, crashReason: "SIGSEGV", occurredAt: Self.now - 3_600_000)
        ])
        XCTAssertFalse(result.clearMarker)
    }

    func testACrashOutsideTheRanges_IsNotInTheSdk() {
        let crash = Self.crash(signal: 11, frames: [Self.app(Self.appOffset)])

        let events = DiagnosticReader.events([crash], marker: nil, classifier: Self.classifier, now: Self.now).events

        XCTAssertEqual(Self.inSdk(events), [false])
    }

    func testAHang_IsAHangEvent_WithNoTypeOrReason_AndThePayloadsEndAsItsTime() {
        let hang = MetricKitDiagnostic(kind: .hang, exceptionType: nil, signal: nil, frames: [Self.app(0x1b4dd8)],
                                       timeEnd: Self.now - 60_000)

        let events = DiagnosticReader.events([hang], marker: nil, classifier: Self.classifier, now: Self.now).events

        XCTAssertEqual(events, [
            .crash(error: TelemetryEvent.ErrorInfo(type: nil, frames: ["ExampleApp 0x1b4dd8"]), source: .metricKit,
                   kind: .hang, inSdk: true, occurredAt: Self.now - 60_000)
        ])
    }

    func testAnUnknownUUID_InTheSdksImage_LeavesInSdkUnset() {
        let crash = Self.crash(signal: 11, frames: [
            DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: "11111111-2222-3333-4444-555555555555", offset: Self.sdkOffset)
        ])

        let events = DiagnosticReader.events([crash], marker: nil, classifier: Self.classifier, now: Self.now).events

        XCTAssertEqual(Self.inSdk(events), [nil])
    }

    func testASavedEarlierBuild_ClassifiesByItsOwnRanges() {
        let classifier = FrameClassifier(builds: [
            FramePoints(imageName: "ExampleApp", uuid: Self.uuid, sdkRanges: [0x1b4000...0x1b6000]),
            FramePoints(imageName: "ExampleApp", uuid: Self.previousUUID, sdkRanges: [0x2000...0x3000])
        ])
        let crash = Self.crash(signal: 11, frames: [
            DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: Self.previousUUID, offset: 0x2100)
        ])

        let events = DiagnosticReader.events([crash], marker: nil, classifier: classifier, now: Self.now).events

        XCTAssertEqual(Self.inSdk(events), [true])
    }

    func testNoClassifierYet_LeavesInSdkUnset() {
        let events = DiagnosticReader.events([Self.crash(signal: 11, frames: [Self.app(Self.sdkOffset)])], marker: nil,
                                             classifier: nil, now: Self.now).events

        XCTAssertEqual(Self.inSdk(events), [nil])
    }

    func testACrashWithNoNumbers_HasNoTypeOrReason() {
        let crash = MetricKitDiagnostic(kind: .crash, exceptionType: nil, signal: nil, frames: [], timeEnd: Self.now)

        let events = DiagnosticReader.events([crash], marker: nil, classifier: Self.classifier, now: Self.now).events

        XCTAssertEqual(events, [
            .crash(error: TelemetryEvent.ErrorInfo(type: nil, frames: []), source: .metricKit, kind: .signal, inSdk: nil,
                   crashReason: nil, occurredAt: Self.now)
        ])
    }

    // MARK: - Age

    func testADiagnosticOlderThan156Hours_IsSkipped_AndExactly156HoursKept() {
        let tooOld = Self.crash(signal: 11, frames: [Self.app(0x10)], timeEnd: Self.now - Self.maxAge - 1)
        let oldest = Self.crash(signal: 11, frames: [Self.app(0x20)], timeEnd: Self.now - Self.maxAge)

        let events = DiagnosticReader.events([tooOld, oldest], marker: nil, classifier: Self.classifier, now: Self.now).events

        XCTAssertEqual(Self.frames(events), [["ExampleApp 0x20"]])
    }

    // MARK: - The marker

    func testASigabrtMatchingTheMarker_IsSkipped_AndTheMarkerCleared() {
        let crash = Self.crash(exceptionType: 10, signal: 6, frames: [Self.system, Self.app(Self.sdkOffset)])

        let result = DiagnosticReader.events([crash], marker: Self.marker(), classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(result.events, [])
        XCTAssertTrue(result.clearMarker)
    }

    func testASigabrtNotMatchingTheMarker_IsKept() {
        let otherOffset = Self.crash(signal: 6, frames: [Self.app(Self.sdkOffset + 4)])
        let otherUUID = Self.crash(signal: 6, frames: [
            DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: Self.previousUUID, offset: Self.sdkOffset)
        ])

        let result = DiagnosticReader.events([otherOffset, otherUUID], marker: Self.marker(), classifier: Self.classifier,
                                             now: Self.now)

        XCTAssertEqual(result.events.count, 2)
        XCTAssertFalse(result.clearMarker)
    }

    func testAMatchingCrashOnAnotherSignal_IsKept() {
        let segv = Self.crash(signal: 11, frames: [Self.app(Self.sdkOffset)])
        let hang = MetricKitDiagnostic(kind: .hang, exceptionType: nil, signal: 6, frames: [Self.app(Self.sdkOffset)],
                                       timeEnd: Self.now)

        let result = DiagnosticReader.events([segv, hang], marker: Self.marker(), classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(result.events.count, 2)
        XCTAssertFalse(result.clearMarker)
    }

    func testOnlyTheFirstMatch_IsSkipped() {
        let first = Self.crash(signal: 6, frames: [Self.app(Self.sdkOffset), Self.app(0x10)])
        let second = Self.crash(signal: 6, frames: [Self.app(Self.sdkOffset), Self.app(0x20)])

        let result = DiagnosticReader.events([first, second], marker: Self.marker(), classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(Self.frames(result.events), [["ExampleApp 0x1b5058", "ExampleApp 0x20"]])
        XCTAssertTrue(result.clearMarker)
    }

    func testAMarkerOlderThan156Hours_IsClearedAndNotMatched() {
        let crash = Self.crash(signal: 6, frames: [Self.app(Self.sdkOffset)])

        let result = DiagnosticReader.events([crash], marker: Self.marker(time: Self.now - Self.maxAge - 1),
                                             classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(result.events.count, 1)
        XCTAssertTrue(result.clearMarker)
    }

    func testAMarkerExactly156HoursOld_StillMatches() {
        let crash = Self.crash(signal: 6, frames: [Self.app(Self.sdkOffset)])

        let result = DiagnosticReader.events([crash], marker: Self.marker(time: Self.now - Self.maxAge),
                                             classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(result.events, [])
        XCTAssertTrue(result.clearMarker)
    }

    func testAMarkerWithALowercaseUUID_StillMatches() {
        let marker = CrashMarker(sessionId: "s", imageUUID: Self.uuid.lowercased(), topFrameOffset: Self.sdkOffset,
                                 time: Self.now - 60_000)

        let result = DiagnosticReader.events([Self.crash(signal: 6, frames: [Self.app(Self.sdkOffset)])], marker: marker,
                                             classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(result.events, [])
        XCTAssertTrue(result.clearMarker)
    }

    func testNoDiagnostics_KeepAMarker() {
        let result = DiagnosticReader.events([], marker: Self.marker(), classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(result.events, [])
        XCTAssertFalse(result.clearMarker)
    }

    // MARK: - Order

    func testEvents_KeepTheInputOrder() {
        let diagnostics = [
            Self.crash(signal: 11, frames: [Self.app(0x30)]),
            MetricKitDiagnostic(kind: .hang, exceptionType: nil, signal: nil, frames: [Self.app(0x10)], timeEnd: Self.now),
            Self.crash(signal: 6, frames: [Self.app(Self.sdkOffset)]),
            Self.crash(signal: 4, frames: [Self.app(0x20)])
        ]

        let result = DiagnosticReader.events(diagnostics, marker: Self.marker(), classifier: Self.classifier, now: Self.now)

        XCTAssertEqual(Self.frames(result.events), [["ExampleApp 0x30"], ["ExampleApp 0x10"], ["ExampleApp 0x20"]])
    }

    func testPayloadDiagnostics_BecomeEvents() throws {
        let diagnostics = MetricKitPayload.diagnostics(json: try MetricKitFixtures.data("crash"), timeEnd: Self.now - 60_000)

        let events = DiagnosticReader.events(diagnostics, marker: nil, classifier: Self.classifier, now: Self.now).events

        XCTAssertEqual(events, [
            .crash(error: TelemetryEvent.ErrorInfo(type: "EXC_BAD_ACCESS", frames: [
                "ExampleApp 0x1b5058", "ExampleApp 0x1b4d08", "UIKitCore 0x58f740"
            ]), source: .metricKit, kind: .signal, inSdk: true, crashReason: "SIGSEGV", occurredAt: Self.now - 60_000)
        ])
    }

    // MARK: - Helpers

    private static let system = DiagnosticFrame(binaryName: "libsystem_kernel.dylib",
                                                binaryUUID: "5D1C7F2A-0B3E-3C4D-8E9F-1A2B3C4D5E6F", offset: 0x11b0)

    private static func app(_ offset: UInt64) -> DiagnosticFrame {
        DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: uuid, offset: offset)
    }

    private static func crash(exceptionType: Int? = 10, signal: Int?, frames: [DiagnosticFrame],
                              timeEnd: Int64 = now - 60_000) -> MetricKitDiagnostic {
        MetricKitDiagnostic(kind: .crash, exceptionType: exceptionType, signal: signal, frames: frames, timeEnd: timeEnd)
    }

    private static func marker(time: Int64 = now - 120_000) -> CrashMarker {
        CrashMarker(sessionId: "7e41d9c2-8b05-4f6a-a3d1-0c9e2b7f5a68", imageUUID: uuid, topFrameOffset: sdkOffset, time: time)
    }

    private static func inSdk(_ events: [TelemetryEvent]) -> [Bool?] {
        events.map { event in
            guard case let .crash(_, _, _, inSdk, _, _, _) = event else {
                return nil
            }
            return inSdk
        }
    }

    private static func frames(_ events: [TelemetryEvent]) -> [[String]] {
        events.map { event in
            guard case let .crash(error, _, _, _, _, _, _) = event else {
                return []
            }
            return error?.frames ?? []
        }
    }
}
