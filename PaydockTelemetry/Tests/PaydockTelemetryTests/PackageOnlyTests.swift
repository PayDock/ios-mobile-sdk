//
//  PackageOnlyTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// Keeps telemetry out of the SDK's public interface: every declaration in the target uses package access (RS-5).
final class PackageOnlyTests: XCTestCase {

    private static let forbiddenWord = makeRegex(#"\b(public|open)\b"#)
    private static let forbiddenAttributes = ["@_spi", "@_exported", "@usableFromInline"]
    private static let topLevelDeclaration = makeRegex(
        #"^(?:@\w+\s+)*(?:\w+\s+)*(struct|class|enum|protocol|func|let|var|typealias|actor)\b"#
    )
    private static let leadingAttributes = makeRegex(#"^(?:@\w+\s+)*"#)
    private static let allowedAccess = ["package ", "private ", "fileprivate "]

    func testEveryDeclaration_UsesPackageAccess() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("../../Sources/PaydockTelemetry")
            .standardizedFileURL
        let files = try FileManager.default
            .contentsOfDirectory(at: sources, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }

        XCTAssertFalse(files.isEmpty, "No .swift file in \(sources.path)")

        for file in files {
            let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: .newlines)
            for violation in Self.violations(in: lines) {
                XCTFail("\(file.lastPathComponent): \(violation)")
            }
        }
    }

    func testCheck_FlagsWhatItMustFlag() {
        XCTAssertFalse(Self.violations(in: ["public struct Sample {}"]).isEmpty)
        XCTAssertFalse(Self.violations(in: ["struct Sample {}"]).isEmpty)
        XCTAssertFalse(Self.violations(in: ["@frozen enum Sample {}"]).isEmpty)
        XCTAssertFalse(Self.violations(in: ["    open func sample() {}"]).isEmpty)
        XCTAssertFalse(Self.violations(in: ["    @usableFromInline package var sample = 1"]).isEmpty)
        XCTAssertTrue(Self.violations(in: ["/// public in a comment", "@frozen package enum Sample {}"]).isEmpty)
    }

    private static func violations(in lines: [String]) -> [String] {
        var found: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if ["//", "/*", "*"].contains(where: trimmed.hasPrefix) {
                continue
            }
            if matches(forbiddenWord, line) || forbiddenAttributes.contains(where: line.contains) {
                found.append("forbidden access: \(trimmed)")
            }
            if matches(topLevelDeclaration, line) {
                let range = NSRange(line.startIndex..., in: line)
                let declaration = leadingAttributes.stringByReplacingMatches(in: line, range: range, withTemplate: "")
                if !allowedAccess.contains(where: declaration.hasPrefix) {
                    found.append("not package access: \(trimmed)")
                }
            }
        }
        return found
    }

    private static func matches(_ regex: NSRegularExpression, _ line: String) -> Bool {
        regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil
    }

    private static func makeRegex(_ pattern: String) -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: pattern)
        } catch {
            preconditionFailure("Invalid pattern \(pattern)")
        }
    }
}
