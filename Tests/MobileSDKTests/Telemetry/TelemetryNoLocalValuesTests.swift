//
//  TelemetryNoLocalValuesTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest

/// R_02, R_05: no local value reaches any build. The collector table is the binding's only input: no SDK or telemetry
/// source names one of the former debug override's scheme variables or reads the process environment for a telemetry
/// setting, and `bindTelemetry` takes its endpoint only from the collector table. Source scans only: the behaviour
/// case (a real `bindTelemetry` with every former variable set) is in `TelemetryReleaseTests`, so the debug suite
/// never starts a real runtime.
final class TelemetryNoLocalValuesTests: XCTestCase {

    /// The former variables' common prefix, built so that this file does not name it.
    private static let formerPrefix = "PAYDOCK_" + "TELEMETRY_"

    private static let sourceDirectories = ["Sources", "PaydockTelemetry/Sources"]
    private static let bindingPath = "Sources/MobileSDK/Telemetry/TelemetryBinding.swift"

    /// The files that may read the process environment, and why: the binding's default argument (handed only to the
    /// test-process check) and the simulator's device model.
    private static let environmentReaders: Set<String> = [
        bindingPath,
        "PaydockTelemetry/Sources/PaydockTelemetry/ApplePlatformInfo.swift"
    ]
    private static let environmentRead = SourceScan.makeRegex(#"\bprocessInfo\.environment\b|\bgetenv\s*\("#)

    // MARK: - Sources

    /// No SDK or telemetry source names a former variable.
    func testNoSource_NamesAFormerVariable() throws {
        let files = try Self.sourceFiles()
        XCTAssertFalse(files.isEmpty, "No .swift file under \(Self.sourceDirectories): wrong repo root")

        for file in files {
            let text = try String(contentsOf: SourceScan.repoRoot.appendingPathComponent(file.path), encoding: .utf8)
            XCTAssertFalse(text.contains(Self.formerPrefix), "\(file.path) names a former \(Self.formerPrefix) variable")
        }
    }

    /// Only the listed files read the process environment.
    func testOnlyTheListedFiles_ReadTheProcessEnvironment() throws {
        for file in try Self.sourceFiles() where SourceScan.count(Self.environmentRead, in: file.code) > 0 {
            XCTAssertTrue(Self.environmentReaders.contains(file.path), "\(file.path) reads the process environment")
        }
    }

    /// `bindTelemetry` hands the process environment only to the test-process check, and takes its endpoint only from
    /// `TelemetryCollector.logsURL(for: environment)`.
    func testBindTelemetry_TakesItsEndpointOnlyFromTheCollectorTable() throws {
        let lines = try SourceScan.file(at: Self.bindingPath).code
        let start = try XCTUnwrap(lines.firstIndex { $0.contains("static func bindTelemetry(") }, "bindTelemetry not found")
        let body = Self.declaration(startingAt: start, in: lines)

        XCTAssertEqual(body.components(separatedBy: "processEnvironment").count - 1, 2,
                       "processEnvironment: the parameter and the test-process check only")
        XCTAssertTrue(body.contains("isTestProcess(environment: processEnvironment, bundleIdentifier: hostBundleIdentifier)"))
        XCTAssertEqual(body.components(separatedBy: "TelemetryCollector.").count - 1, 1, "one collector lookup")
        XCTAssertTrue(body.contains("endpoint: TelemetryCollector.logsURL(for: environment)"))
        XCTAssertEqual(body.components(separatedBy: "selectTelemetry(").count - 1, 1, "one selection")
        XCTAssertFalse(body.contains("#if"), "one path in every build")
    }

    // MARK: - Helpers

    /// The lines from `start` through the one that closes the first block opened at or after it.
    private static func declaration(startingAt start: Int, in lines: [String]) -> String {
        var depth = 0
        var opened = false
        var index = start
        while index < lines.count {
            depth += SourceScan.braceBalance(lines[index])
            opened = opened || lines[index].contains("{")
            if opened, depth <= 0 {
                break
            }
            index += 1
        }
        return lines[start...min(index, lines.count - 1)].joined(separator: "\n")
    }

    private static func sourceFiles() throws -> [SourceScan.File] {
        try sourceDirectories.flatMap { try SourceScan.files(under: $0) }
    }
}
