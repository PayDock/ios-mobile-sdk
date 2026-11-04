//
//  SourceScan.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// Finds whole-word uses of forbidden names in the target's sources, comments included.
enum SourceScan {
    struct Finding: Equatable {
        let file: String
        let line: Int
        let name: String
    }

    /// Every `.swift` file under `PaydockTelemetry/Sources`.
    static func sourceFiles(file: StaticString = #filePath, line: UInt = #line) throws -> [URL] {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Support
            .appendingPathComponent("../../../Sources")
            .standardizedFileURL
        let enumerator = try XCTUnwrap(FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil),
                                       file: file, line: line)
        let files = enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        XCTAssertFalse(files.isEmpty, "No .swift file under \(sources.path)", file: file, line: line)
        return files
    }

    /// The forbidden names each line uses, as whole words.
    static func findings(in text: String, file: String, names: [String]) -> [Finding] {
        let lines = text.components(separatedBy: .newlines)
        var found: [Finding] = []
        for (index, content) in lines.enumerated() {
            for name in names where matches(name, content) {
                found.append(Finding(file: file, line: index + 1, name: name))
            }
        }
        return found
    }

    static func matches(_ name: String, _ line: String) -> Bool {
        let pattern = #"\b"# + NSRegularExpression.escapedPattern(for: name) + #"\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            preconditionFailure("Invalid pattern \(pattern)")
        }
        return regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil
    }
}
