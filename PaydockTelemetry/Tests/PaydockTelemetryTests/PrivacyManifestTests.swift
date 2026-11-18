//
//  PrivacyManifestTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// R_09: the telemetry target ships its privacy manifest as a package resource, with every key of § Contracts: no
/// tracking, crash data and other diagnostic data not linked and not for tracking, for app functionality, and the
/// required-reason APIs it uses.
final class PrivacyManifestTests: XCTestCase {

    private static let appFunctionality = ["NSPrivacyCollectedDataTypePurposeAppFunctionality"]

    func testTheManifest_IsInTheResourceBundle() throws {
        XCTAssertFalse(try PrivacyManifest.packaged().isEmpty)
    }

    func testTheManifest_DeclaresNoTracking() throws {
        let manifest = try PrivacyManifest.packaged()

        XCTAssertEqual(manifest["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual(try XCTUnwrap(manifest["NSPrivacyTrackingDomains"] as? [String]), [])
    }

    func testTheManifest_DeclaresCrashAndOtherDiagnosticData_NotLinked_NotTracking_ForAppFunctionality() throws {
        let manifest = try PrivacyManifest.packaged()
        let types = try XCTUnwrap(manifest["NSPrivacyCollectedDataTypes"] as? [[String: Any]])

        XCTAssertEqual(types.compactMap { $0["NSPrivacyCollectedDataType"] as? String },
                       ["NSPrivacyCollectedDataTypeCrashData", "NSPrivacyCollectedDataTypeOtherDiagnosticData"])
        for type in types {
            let name = type["NSPrivacyCollectedDataType"] as? String ?? "?"
            XCTAssertEqual(type["NSPrivacyCollectedDataTypeLinked"] as? Bool, false, name)
            XCTAssertEqual(type["NSPrivacyCollectedDataTypeTracking"] as? Bool, false, name)
            XCTAssertEqual(type["NSPrivacyCollectedDataTypePurposes"] as? [String], Self.appFunctionality, name)
            XCTAssertEqual(type.count, 4, "\(name) has an unexpected key")
        }
    }

    func testTheManifest_DeclaresUserDefaultsAndSystemBootTime() throws {
        let manifest = try PrivacyManifest.packaged()

        XCTAssertEqual(PrivacyManifest.accessedApiReasons(manifest), [
            "NSPrivacyAccessedAPICategoryUserDefaults": ["CA92.1"],
            "NSPrivacyAccessedAPICategorySystemBootTime": ["35F9.1"]
        ])
        XCTAssertEqual((manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]])?.count, 2)
    }

    func testTheManifest_HasOnlyTheFourKeys() throws {
        XCTAssertEqual(Set(try PrivacyManifest.packaged().keys), [
            "NSPrivacyTracking", "NSPrivacyTrackingDomains", "NSPrivacyCollectedDataTypes", "NSPrivacyAccessedAPITypes"
        ])
    }
}
