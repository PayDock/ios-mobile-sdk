//
//  RequiredReasonApiTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// No new required-reason API category (D16): no boot time, file timestamp, disk space or keyboard API, and user
/// defaults only behind `UserDefaultsKeyValueStore`.
final class RequiredReasonApiTests: XCTestCase {

    private static let forbidden = [
        "systemUptime", "mach_absolute_time", "creationDate", "modificationDate", "attributesOfItem",
        "volumeAvailableCapacity", "activeInputModes", "FileManager"
    ]
    private static let userDefaults = "UserDefaults"
    private static let userDefaultsFile = "UserDefaultsKeyValueStore.swift"

    func testSources_UseNoOtherRequiredReasonApi() throws {
        for file in try SourceScan.sourceFiles() {
            let text = try String(contentsOf: file, encoding: .utf8)
            for finding in SourceScan.findings(in: text, file: file.lastPathComponent, names: Self.forbidden) {
                XCTFail("\(finding.file):\(finding.line) uses the required-reason API \(finding.name)")
            }
        }
    }

    func testSources_UseUserDefaultsOnlyInItsStore() throws {
        var storeUsesIt = false
        for file in try SourceScan.sourceFiles() {
            let text = try String(contentsOf: file, encoding: .utf8)
            let findings = SourceScan.findings(in: text, file: file.lastPathComponent, names: [Self.userDefaults])
            if file.lastPathComponent == Self.userDefaultsFile {
                storeUsesIt = !findings.isEmpty
            } else {
                for finding in findings {
                    XCTFail("\(finding.file):\(finding.line) uses UserDefaults outside \(Self.userDefaultsFile)")
                }
            }
        }
        XCTAssertTrue(storeUsesIt, "\(Self.userDefaultsFile) not found or no longer uses UserDefaults")
    }

    func testCheck_FlagsWhatItMustFlag() {
        for name in Self.forbidden + [Self.userDefaults] {
            XCTAssertTrue(SourceScan.matches(name, "let value = \(name).sample"), name)
        }
        XCTAssertFalse(SourceScan.matches(Self.userDefaults, "let store = UserDefaultsKeyValueStore()"))
        XCTAssertFalse(SourceScan.matches("FileManager", "let manager = FileManagerLike()"))
    }
}
