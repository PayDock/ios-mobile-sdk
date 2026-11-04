//
//  NoHardwareIdentifiersTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// Only random IDs: no hardware, vendor or advertising identifier and no device API in the target (principle 10).
final class NoHardwareIdentifiersTests: XCTestCase {

    private static let forbidden = [
        "identifierForVendor", "advertisingIdentifier", "ASIdentifierManager", "AdSupport", "AppTrackingTransparency",
        "UIDevice"
    ]

    func testSources_UseNoHardwareOrAdvertisingIdentifier() throws {
        for file in try SourceScan.sourceFiles() {
            let text = try String(contentsOf: file, encoding: .utf8)
            for finding in SourceScan.findings(in: text, file: file.lastPathComponent, names: Self.forbidden) {
                XCTFail("\(finding.file):\(finding.line) uses \(finding.name)")
            }
        }
    }

    func testCheck_FlagsWhatItMustFlag() {
        for name in Self.forbidden {
            XCTAssertEqual(SourceScan.findings(in: "let value = \(name).sample", file: "Sample.swift", names: Self.forbidden).count,
                           1, name)
        }
        XCTAssertEqual(SourceScan.findings(in: "import AdSupport", file: "Sample.swift", names: Self.forbidden).count, 1)
        XCTAssertTrue(SourceScan.findings(in: "let id = UUID().uuidString", file: "Sample.swift", names: Self.forbidden).isEmpty)
    }
}
