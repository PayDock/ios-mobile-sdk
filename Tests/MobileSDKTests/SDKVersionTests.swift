//
//  SDKVersionTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK

/// Keeps the runtime version (`service.version`) equal to the release version.
final class SDKVersionTests: XCTestCase {

    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // MobileSDKTests
        .deletingLastPathComponent() // Tests
        .deletingLastPathComponent() // repo root

    func testCurrent_EqualsVersionNameOfTheVersionXcconfig() throws {
        let xcconfig = try String(
            contentsOf: Self.root.appendingPathComponent("ExampleApp/ExampleApp/Configs/Version.xcconfig"),
            encoding: .utf8
        )
        let versionName = xcconfig
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { $0.hasPrefix("VERSION_NAME") }?
            .split(separator: "=", maxSplits: 1)
            .last?
            .trimmingCharacters(in: .whitespaces)

        XCTAssertEqual(SDKVersion.current, try XCTUnwrap(versionName, "No VERSION_NAME in Version.xcconfig"),
                       "Bump SDKVersion.current with VERSION_NAME")
    }

    func testChangelog_HasAHeadingForTheCurrentVersion() throws {
        let changelog = try String(contentsOf: Self.root.appendingPathComponent("CHANGELOG.md"), encoding: .utf8)

        XCTAssertTrue(
            changelog.components(separatedBy: .newlines).contains { $0.hasPrefix("## [\(SDKVersion.current)]") },
            "CHANGELOG.md has no ## [\(SDKVersion.current)] heading"
        )
    }
}
