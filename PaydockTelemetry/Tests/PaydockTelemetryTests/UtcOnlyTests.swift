//
//  UtcOnlyTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// Keeps every time in the target UTC epoch milliseconds: no time zone, calendar, formatter or locale (R_11).
final class UtcOnlyTests: XCTestCase {

    private static let forbidden = makeRegex(#"\b(TimeZone|Calendar|DateFormatter|ISO8601DateFormatter|DateComponents|Locale)\b"#)

    func testSources_UseNoTimeZoneCalendarFormatterOrLocale() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("../../Sources")
            .standardizedFileURL
        let enumerator = try XCTUnwrap(FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil))
        let files = enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }

        XCTAssertFalse(files.isEmpty, "No .swift file under \(sources.path)")

        for file in files {
            let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() where Self.matches(line) {
                XCTFail("\(file.lastPathComponent):\(index + 1) uses a local-time API: \(line.trimmingCharacters(in: .whitespaces))")
            }
        }
    }

    func testCheck_FlagsWhatItMustFlag() {
        for name in ["TimeZone", "Calendar", "DateFormatter", "ISO8601DateFormatter", "DateComponents", "Locale"] {
            XCTAssertTrue(Self.matches("let value = \(name).current"), name)
        }
        XCTAssertFalse(Self.matches("let now = Int64(Date().timeIntervalSince1970 * 1_000)"))
        XCTAssertFalse(Self.matches("let value = CalendarLike()"))
    }

    private static func matches(_ line: String) -> Bool {
        forbidden.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil
    }

    private static func makeRegex(_ pattern: String) -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: pattern)
        } catch {
            preconditionFailure("Invalid pattern \(pattern)")
        }
    }
}
