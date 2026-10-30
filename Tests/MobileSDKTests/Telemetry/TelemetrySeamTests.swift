//
//  TelemetrySeamTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest

/// Keeps the SDK behind the telemetry seam (R_08): SDK code may refer only to the `Telemetry` facade and
/// `TelemetryEvent`. Only the core `MobileSDK` target (`Sources/`) may import `PaydockTelemetry`, never re-exported
/// and never `@testable`.
final class TelemetrySeamTests: XCTestCase {

    /// Repo-relative paths of the files allowed to name the lifecycle types: the activation binding (MD-33) only.
    private static let lifecycleAllowlist: Set<String> = []

    private static let lifecycleNames = makeRegex(#"\b(TelemetryRuntime|NoOpTelemetry|TelemetryIntent|TelemetryLevel)\b"#)
    private static let anyImport = makeRegex(#"^\s*(?:@\w+\s+)*import\s+(?:\w+\s+)?PaydockTelemetry\b"#)
    private static let forbiddenImport = makeRegex(#"@(?:_exported|testable)\s+(?:@\w+\s+)*import\s+(?:\w+\s+)?PaydockTelemetry\b"#)

    func testSDKCode_RefersOnlyToTheFacadeAndTheEvents() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Telemetry
            .deletingLastPathComponent() // MobileSDKTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // repo root
        let coreFiles = try Self.swiftFiles(under: root.appendingPathComponent("Sources"))

        XCTAssertFalse(coreFiles.isEmpty, "No .swift file under \(root.path)/Sources: wrong repo root")

        var files = coreFiles.map { (url: $0, isCore: true) }
        for directory in try Self.supportSourceDirectories(in: root) {
            files += try Self.swiftFiles(under: directory).map { (url: $0, isCore: false) }
        }

        for file in files {
            let path = Self.relativePath(of: file.url, in: root)
            let text = try String(contentsOf: file.url, encoding: .utf8)
            let lines = text.components(separatedBy: .newlines)

            if lines.contains(where: { Self.matches(Self.forbiddenImport, $0) }) {
                XCTFail("\(path) re-exports or @testable-imports PaydockTelemetry")
            }
            if !file.isCore, lines.contains(where: { Self.matches(Self.anyImport, $0) }) {
                XCTFail("\(path) imports PaydockTelemetry; only files under Sources/ may")
            }
            if !Self.lifecycleAllowlist.contains(path), Self.matches(Self.lifecycleNames, text) {
                XCTFail("\(path) names a telemetry type beyond the Telemetry facade and TelemetryEvent")
            }
        }
    }

    /// `CommonModels/Sources`, `BinProcessing/Sources` and every `Data*/Sources` directory.
    private static func supportSourceDirectories(in root: URL) throws -> [URL] {
        let dataTargets = try FileManager.default
            .contentsOfDirectory(atPath: root.path)
            .filter { $0.hasPrefix("Data") }
        return (["CommonModels", "BinProcessing"] + dataTargets.sorted())
            .map { root.appendingPathComponent($0).appendingPathComponent("Sources") }
            .filter { FileManager.default.fileExists(atPath: $0.path) }
    }

    private static func swiftFiles(under directory: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        return enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    private static func relativePath(of file: URL, in root: URL) -> String {
        let rootPath = root.standardizedFileURL.path + "/"
        let filePath = file.standardizedFileURL.path
        return filePath.hasPrefix(rootPath) ? String(filePath.dropFirst(rootPath.count)) : filePath
    }

    private static func matches(_ regex: NSRegularExpression, _ text: String) -> Bool {
        regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    private static func makeRegex(_ pattern: String) -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        } catch {
            preconditionFailure("Invalid pattern \(pattern)")
        }
    }
}
