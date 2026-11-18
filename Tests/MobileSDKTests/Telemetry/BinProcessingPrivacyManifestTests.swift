//
//  BinProcessingPrivacyManifestTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest

/// R_09, R_10: the bin-processing target's privacy manifest, read by path: no tracking, no collected data, and
/// UserDefaults (CA92.1), which its cache uses. The root manifest and the nested `BinProcessing/Package.swift` package it
/// beside the card-scheme JSON.
final class BinProcessingPrivacyManifestTests: XCTestCase {

    private static let manifestPath = "BinProcessing/Sources/BinProcessing/Resources/PrivacyInfo.xcprivacy"
    private static let resourceEntry = #".copy("Resources/PrivacyInfo.xcprivacy")"#

    func testTheManifest_DeclaresNoTracking_NoCollectedData_AndUserDefaults() throws {
        let manifest = try Self.manifest()

        XCTAssertEqual(manifest["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual(try XCTUnwrap(manifest["NSPrivacyTrackingDomains"] as? [String]), [])
        XCTAssertEqual(try XCTUnwrap(manifest["NSPrivacyCollectedDataTypes"] as? [Any]).count, 0)
        let accessed = try XCTUnwrap(manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        XCTAssertEqual(accessed.count, 1)
        XCTAssertEqual(accessed.first?["NSPrivacyAccessedAPIType"] as? String, "NSPrivacyAccessedAPICategoryUserDefaults")
        XCTAssertEqual(accessed.first?["NSPrivacyAccessedAPITypeReasons"] as? [String], ["CA92.1"])
    }

    func testTheRootManifest_PackagesIt() throws {
        try Self.assertPackaged(byManifestAt: "Package.swift")
    }

    func testTheNestedManifest_PackagesIt() throws {
        try Self.assertPackaged(byManifestAt: "BinProcessing/Package.swift")
    }

    /// The `BinProcessing` target of the package manifest at `path` lists the privacy manifest among its resources.
    private static func assertPackaged(byManifestAt path: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let manifest = try String(contentsOf: SourceScan.repoRoot.appendingPathComponent(path), encoding: .utf8)
        let binTarget = try XCTUnwrap(manifest.range(of: #"name: "BinProcessing",\s*dependencies:"#, options: .regularExpression),
                                      file: file, line: line)
        let binTargetEnd = try XCTUnwrap(manifest.range(of: ".testTarget(", range: binTarget.upperBound..<manifest.endIndex),
                                         file: file, line: line)

        XCTAssertTrue(manifest[binTarget.upperBound..<binTargetEnd.lowerBound].contains(resourceEntry), path,
                      file: file, line: line)
    }

    private static func manifest(file: StaticString = #filePath, line: UInt = #line) throws -> [String: Any] {
        let data = try Data(contentsOf: SourceScan.repoRoot.appendingPathComponent(manifestPath))
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        return try XCTUnwrap(plist as? [String: Any], file: file, line: line)
    }
}
