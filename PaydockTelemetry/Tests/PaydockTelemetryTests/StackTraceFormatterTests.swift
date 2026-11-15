//
//  StackTraceFormatterTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class StackTraceFormatterTests: XCTestCase {

    private typealias Info = TelemetryEvent.ErrorInfo

    func testConstants() {
        XCTAssertEqual(StackTraceFormatter.maxFrames, 64)
        XCTAssertEqual(StackTraceFormatter.maxCauses, 8)
        XCTAssertEqual(StackTraceFormatter.maxBytes, 16_384)
    }

    func testTypeLine_ThenOneAtLinePerFrame() {
        let info = Info(type: "NSInvalidArgumentException", frames: ["MobileSDK $s9MobileSDK3fooyyF + 340", "MobileSDK 0x0000000104a3c1f0"])

        XCTAssertEqual(
            StackTraceFormatter.format(info),
            "NSInvalidArgumentException\n\tat MobileSDK $s9MobileSDK3fooyyF + 340\n\tat MobileSDK 0x0000000104a3c1f0"
        )
    }

    func testNoType_GivesNoTypeLine() {
        let info = Info(type: nil, frames: ["MobileSDK 0x0000000104a3c1f0", "UIKitCore 0x0000000184a3c1f0"])

        XCTAssertEqual(StackTraceFormatter.format(info), "\tat MobileSDK 0x0000000104a3c1f0\n\tat UIKitCore 0x0000000184a3c1f0")
    }

    func testCauses_FollowAsCausedByLines() {
        let inner = Info(type: "Sample.Inner", frames: ["Sample 0x0000000100000010"])
        let middle = Info(type: nil, frames: [], cause: inner)
        let info = Info(type: "Sample.Outer", frames: ["Sample 0x0000000100000000"], cause: middle)

        XCTAssertEqual(
            StackTraceFormatter.format(info),
            "Sample.Outer\n\tat Sample 0x0000000100000000\nCaused by: Sample.Inner\n\tat Sample 0x0000000100000010"
        )
    }

    func testFrames_AreCappedAt64PerException() {
        let info = Info(type: "Sample.Error", frames: (0..<100).map { "Sample 0x\(String(format: "%016x", $0))" })

        let lines = StackTraceFormatter.format(info).components(separatedBy: "\n")

        XCTAssertEqual(lines.count, 1 + StackTraceFormatter.maxFrames)
    }

    func testCauses_AreCappedAt8() {
        var info = Info(type: "Sample.Cause10", frames: [])
        for index in (0..<10).reversed() {
            info = Info(type: "Sample.Cause\(index)", frames: [], cause: info)
        }

        let lines = StackTraceFormatter.format(info).components(separatedBy: "\n")

        XCTAssertEqual(lines.first, "Sample.Cause0")
        XCTAssertEqual(lines.filter { $0.hasPrefix("Caused by: ") }.count, StackTraceFormatter.maxCauses)
        XCTAssertEqual(lines.last, "Caused by: Sample.Cause8")
    }

    func testText_IsCutAtTheLastWholeLineWithin16KB() {
        let frame = "MobileSDK $s9MobileSDK" + String(repeating: "a", count: 290) + " + 1"
        var info = Info(type: "Sample.Cause", frames: Array(repeating: frame, count: 60))
        for _ in 0..<3 {
            info = Info(type: "Sample.Error", frames: Array(repeating: frame, count: 60), cause: info)
        }

        let text = StackTraceFormatter.format(info)
        let lineSize = "\tat \(frame)".utf8.count

        XCTAssertLessThanOrEqual(text.utf8.count, StackTraceFormatter.maxBytes)
        XCTAssertGreaterThan(text.utf8.count + 1 + lineSize, StackTraceFormatter.maxBytes)
        XCTAssertTrue(text.hasSuffix("\tat \(frame)"))
    }

    func testText_ExactlyAtTheLimit_IsKept() {
        let line = String(repeating: "a", count: StackTraceFormatter.maxBytes)

        XCTAssertEqual(StackTraceFormatter.format(Info(type: line, frames: [])), line)
        XCTAssertEqual(StackTraceFormatter.format(Info(type: line + "a", frames: [])), "")
    }
}
