//
//  PrivacyManifest.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// The telemetry target's privacy manifest, read as a property list.
enum PrivacyManifest {
    static let fileName = "PrivacyInfo"
    static let fileExtension = "xcprivacy"

    /// The manifest packaged in the target's resource bundle.
    static func packaged(file: StaticString = #filePath, line: UInt = #line) throws -> [String: Any] {
        let url = try XCTUnwrap(TelemetryResources.bundle.url(forResource: fileName, withExtension: fileExtension),
                                "\(fileName).\(fileExtension) is not in the telemetry resource bundle", file: file, line: line)
        return try read(url, file: file, line: line)
    }

    static func read(_ url: URL, file: StaticString = #filePath, line: UInt = #line) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        return try XCTUnwrap(plist as? [String: Any], "\(url.lastPathComponent) is not a dictionary", file: file, line: line)
    }

    /// The reasons declared for each accessed API category.
    static func accessedApiReasons(_ manifest: [String: Any]) -> [String: [String]] {
        let entries = manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]] ?? []
        var reasons: [String: [String]] = [:]
        for entry in entries {
            if let category = entry["NSPrivacyAccessedAPIType"] as? String {
                reasons[category] = entry["NSPrivacyAccessedAPITypeReasons"] as? [String] ?? []
            }
        }
        return reasons
    }
}
