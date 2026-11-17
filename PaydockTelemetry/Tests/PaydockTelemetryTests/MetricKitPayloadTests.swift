//
//  MetricKitPayloadTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_12: the diagnostics of a payload's JSON, from the synthetic payloads under `Fixtures/metrickit/` and payloads
/// built in code. Only the listed keys are read.
final class MetricKitPayloadTests: XCTestCase {

    private static let appUUID = "C95ED3C1-F639-3822-BC5C-B2D03AFDD182"
    private static let uikitUUID = "3E0F5B7A-9C1D-3F2E-A4B5-C6D7E8F90A1B"
    private static let timeEnd: Int64 = 1_793_830_203_000

    // MARK: - Diagnostics

    func testACrashPayload_GivesItsTypeSignalAndTheAttributedThreadsFrames_InnermostFirst() throws {
        let diagnostics = MetricKitPayload.diagnostics(json: try MetricKitFixtures.data("crash"), timeEnd: Self.timeEnd)

        XCTAssertEqual(diagnostics, [
            MetricKitDiagnostic(kind: .crash, exceptionType: 1, signal: 11, frames: [
                DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: Self.appUUID, offset: 0x1b5058),
                DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: Self.appUUID, offset: 0x1b4d08),
                DiagnosticFrame(binaryName: "UIKitCore", binaryUUID: Self.uikitUUID, offset: 0x58f740)
            ], timeEnd: Self.timeEnd)
        ])
    }

    func testUUIDs_AreUppercased() throws {
        let diagnostics = MetricKitPayload.diagnostics(json: try MetricKitFixtures.data("crash"), timeEnd: Self.timeEnd)

        let uuids = try XCTUnwrap(diagnostics.first).frames.map(\.binaryUUID)
        XCTAssertEqual(uuids, uuids.map { $0.uppercased() })
        XCTAssertEqual(uuids.first, Self.appUUID)
    }

    func testAHangPayload_GivesAHang_WithNoTypeOrSignal() throws {
        let diagnostics = MetricKitPayload.diagnostics(json: try MetricKitFixtures.data("hang"), timeEnd: Self.timeEnd)

        XCTAssertEqual(diagnostics, [
            MetricKitDiagnostic(kind: .hang, exceptionType: nil, signal: nil, frames: [
                DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: Self.appUUID, offset: 0x1b4dd8),
                DiagnosticFrame(binaryName: "UIKitCore", binaryUUID: Self.uikitUUID, offset: 0x58f740)
            ], timeEnd: Self.timeEnd)
        ])
    }

    func testNoAttributedThread_TakesTheFirstThread() throws {
        let diagnostics = MetricKitPayload.diagnostics(json: try MetricKitFixtures.data("unattributed"), timeEnd: Self.timeEnd)

        XCTAssertEqual(diagnostics.map(\.frames), [
            [DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: Self.appUUID, offset: 0x2251a8)]
        ])
        XCTAssertEqual(diagnostics.first?.exceptionType, 10)
        XCTAssertEqual(diagnostics.first?.signal, 6)
    }

    func testCrashes_ComeBeforeHangs() throws {
        let diagnostics = MetricKitPayload.diagnostics(json: try MetricKitFixtures.data("crash-and-hang"), timeEnd: Self.timeEnd)

        XCTAssertEqual(diagnostics.map(\.kind), [.crash, .hang])
        XCTAssertEqual(diagnostics.first?.exceptionType, 6)
        XCTAssertEqual(diagnostics.first?.signal, 5)
    }

    func testMalformedJSON_GivesNone() {
        for text in ["", "{", "not json", "[]", "\"crashDiagnostics\"", "{\"crashDiagnostics\": 7}", "{}"] {
            XCTAssertEqual(MetricKitPayload.diagnostics(json: Data(text.utf8), timeEnd: Self.timeEnd), [], text)
        }
    }

    func testADiagnosticWithoutACallStack_HasNoFrames() {
        let json = Data(#"{"crashDiagnostics": [{"diagnosticMetaData": {"exceptionType": 1, "signal": 11}}]}"#.utf8)

        XCTAssertEqual(MetricKitPayload.diagnostics(json: json, timeEnd: Self.timeEnd), [
            MetricKitDiagnostic(kind: .crash, exceptionType: 1, signal: 11, frames: [], timeEnd: Self.timeEnd)
        ])
    }

    func testAFrameMissingAKey_IsSkipped_AndItsCallersKept() throws {
        for key in ["binaryName", "binaryUUID", "offsetIntoBinaryTextSegment"] {
            var broken = MetricKitFixtures.frame("ExampleApp", uuid: Self.appUUID, offset: 0x10)
            broken[key] = nil
            let json = try MetricKitFixtures.crash(frames: [
                broken,
                MetricKitFixtures.frame("ExampleApp", uuid: Self.appUUID, offset: 0x20),
                MetricKitFixtures.frame("UIKitCore", uuid: Self.uikitUUID, offset: 0x30)
            ])

            let frames = try XCTUnwrap(MetricKitPayload.diagnostics(json: json, timeEnd: Self.timeEnd).first).frames

            XCTAssertEqual(frames.map(\.offset), [0x20, 0x30], key)
        }
    }

    func testAFrameWithANegativeOrTextOffset_IsSkipped() throws {
        var negative = MetricKitFixtures.frame("ExampleApp", uuid: Self.appUUID, offset: 0)
        negative["offsetIntoBinaryTextSegment"] = -4
        var text = MetricKitFixtures.frame("ExampleApp", uuid: Self.appUUID, offset: 0)
        text["offsetIntoBinaryTextSegment"] = "0x20"
        let json = try MetricKitFixtures.crash(frames: [
            negative, text, MetricKitFixtures.frame("ExampleApp", uuid: Self.appUUID, offset: 0x30)
        ])

        XCTAssertEqual(try XCTUnwrap(MetricKitPayload.diagnostics(json: json, timeEnd: Self.timeEnd).first).frames.map(\.offset),
                       [0x30])
    }

    func testAtMost64Frames_AreKept() throws {
        let json = try MetricKitFixtures.crash(frames: (0..<100).map {
            MetricKitFixtures.frame("ExampleApp", uuid: Self.appUUID, offset: UInt64($0))
        })

        let frames = try XCTUnwrap(MetricKitPayload.diagnostics(json: json, timeEnd: Self.timeEnd).first).frames

        XCTAssertEqual(frames.count, 64)
        XCTAssertEqual(frames.map(\.offset), (0..<64).map(UInt64.init))
    }

    // MARK: - Names

    func testEveryMachExceptionName() {
        let names = ["EXC_BAD_ACCESS", "EXC_BAD_INSTRUCTION", "EXC_ARITHMETIC", "EXC_EMULATION", "EXC_SOFTWARE",
                     "EXC_BREAKPOINT", "EXC_SYSCALL", "EXC_MACH_SYSCALL", "EXC_RPC_ALERT", "EXC_CRASH", "EXC_RESOURCE",
                     "EXC_GUARD", "EXC_CORPSE_NOTIFY"]

        XCTAssertEqual((1...13).map(MetricKitPayload.exceptionName), names)
    }

    func testAnUnlistedMachException_FallsBackToItsNumber() {
        XCTAssertEqual(MetricKitPayload.exceptionName(0), "EXC_0")
        XCTAssertEqual(MetricKitPayload.exceptionName(14), "EXC_14")
        XCTAssertEqual(MetricKitPayload.exceptionName(-1), "EXC_-1")
        XCTAssertEqual(MetricKitPayload.exceptionName(Int.min), "EXC_\(Int.min)")
    }

    func testEverySignalName() {
        let names = ["SIGHUP", "SIGINT", "SIGQUIT", "SIGILL", "SIGTRAP", "SIGABRT", "SIGEMT", "SIGFPE", "SIGKILL", "SIGBUS",
                     "SIGSEGV", "SIGSYS", "SIGPIPE", "SIGALRM", "SIGTERM"]

        XCTAssertEqual((1...15).map(MetricKitPayload.signalName), names)
    }

    func testAnUnlistedSignal_FallsBackToItsNumber() {
        XCTAssertEqual(MetricKitPayload.signalName(0), "SIG0")
        XCTAssertEqual(MetricKitPayload.signalName(16), "SIG16")
        XCTAssertEqual(MetricKitPayload.signalName(-1), "SIG-1")
        XCTAssertEqual(MetricKitPayload.signalName(Int.min), "SIG\(Int.min)")
    }

    // MARK: - Free text

    func testTheTerminationReasonMemoryRegionInfoAndExceptionReason_AreNeverRead() throws {
        let freeText = "\(SensitiveSamples.message): card \(SensitiveSamples.cardNumber), \(SensitiveSamples.groupedCardNumber), "
            + "contact \(SensitiveSamples.email)"
        let json = try MetricKitFixtures.data("free-text", freeText: freeText)
        XCTAssertTrue(try XCTUnwrap(String(data: json, encoding: .utf8)).contains(SensitiveSamples.cardNumber))

        let diagnostics = MetricKitPayload.diagnostics(json: json, timeEnd: Self.timeEnd)
        let events = DiagnosticReader.events(diagnostics, marker: nil, classifier: nil, now: Self.timeEnd).events

        XCTAssertEqual(events.count, 1)
        let pending = PendingRecord(id: "s-1", sessionId: "s", event: try XCTUnwrap(events.first), createdAt: Self.timeEnd)
        let record = Allowlist.filter(RecordFactory.create(pending, connection: .wifi))
        let encoded = try XCTUnwrap(String(bytes: OtlpLogEncoder.recordJSON(record), encoding: .utf8))
        for text in ["\(diagnostics)", "\(events)", encoded] {
            for forbidden in SensitiveSamples.forbiddenInOutput {
                XCTAssertFalse(text.contains(forbidden))
            }
        }
        XCTAssertEqual(record.value("exception.type"), .string("EXC_CRASH"))
        XCTAssertEqual(record.value("paydock.crash.reason"), .string("SIGABRT"))
    }

    /// The three free-text keys appear in the target's sources only in the parser's doc comment that says so.
    func testTheFreeTextKeys_AppearInTheSourcesOnlyInADocComment() throws {
        let keys = ["terminationReason", "virtualMemoryRegionInfo", "exceptionReason"]
        var commented: Set<String> = []
        for file in try SourceScan.sourceFiles() {
            let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: .newlines)
            for finding in SourceScan.findings(in: lines.joined(separator: "\n"), file: file.lastPathComponent, names: keys) {
                let line = lines[finding.line - 1].trimmingCharacters(in: .whitespaces)
                if finding.file == "MetricKitPayload.swift", line.hasPrefix("///") {
                    commented.insert(finding.name)
                } else {
                    XCTFail("\(finding.file):\(finding.line) names \(finding.name)")
                }
            }
        }
        XCTAssertEqual(commented, Set(keys))
    }
}
