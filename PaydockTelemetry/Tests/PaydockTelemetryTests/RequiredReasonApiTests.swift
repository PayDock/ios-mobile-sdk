//
//  RequiredReasonApiTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// No new required-reason API category (D16): no boot time, file timestamp, file size, disk space or keyboard API,
/// user defaults only behind `UserDefaultsKeyValueStore`, and `FileManager` only in `FileDurableStore`.
final class RequiredReasonApiTests: XCTestCase {

    private static let forbidden = [
        "systemUptime", "mach_absolute_time", "creationDate", "modificationDate", "attributesOfItem",
        "volumeAvailableCapacity", "activeInputModes", "contentModificationDate", "fileModificationDate", "fileSize",
        "totalFileAllocatedSize", "volumeAvailableCapacityForImportantUsage"
    ]
    private static let userDefaults = "UserDefaults"
    private static let userDefaultsFile = "UserDefaultsKeyValueStore.swift"
    private static let fileManager = "FileManager"
    private static let fileManagerFile = "FileDurableStore.swift"
    private static let monotonicClock = "clock_gettime_nsec_np"

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

    func testSources_UseFileManagerOnlyInTheFileStore() throws {
        var storeUsesIt = false
        for file in try SourceScan.sourceFiles() {
            let text = try String(contentsOf: file, encoding: .utf8)
            let findings = SourceScan.findings(in: text, file: file.lastPathComponent, names: [Self.fileManager])
            if file.lastPathComponent == Self.fileManagerFile {
                storeUsesIt = !findings.isEmpty
            } else {
                for finding in findings {
                    XCTFail("\(finding.file):\(finding.line) uses FileManager outside \(Self.fileManagerFile)")
                }
            }
        }
        XCTAssertTrue(storeUsesIt, "\(Self.fileManagerFile) not found or no longer uses FileManager")
    }

    /// The monotonic clock is not on Apple's required-reason list, so it stays allowed.
    func testTheMonotonicClock_IsAllowed() throws {
        XCTAssertFalse(Self.forbidden.contains { SourceScan.matches($0, "clock_gettime_nsec_np(CLOCK_MONOTONIC)") })
        let uses = try SourceScan.sourceFiles().filter { file in
            let text = try String(contentsOf: file, encoding: .utf8)
            return !SourceScan.findings(in: text, file: file.lastPathComponent, names: [Self.monotonicClock]).isEmpty
        }
        XCTAssertEqual(uses.map(\.lastPathComponent), ["SystemMonotonicClock.swift"])
    }

    func testCheck_FlagsWhatItMustFlag() {
        for name in Self.forbidden + [Self.userDefaults, Self.fileManager] {
            XCTAssertTrue(SourceScan.matches(name, "let value = \(name).sample"), name)
        }
        XCTAssertFalse(SourceScan.matches(Self.userDefaults, "let store = UserDefaultsKeyValueStore()"))
        XCTAssertFalse(SourceScan.matches("FileManager", "let manager = FileManagerLike()"))
    }
}
