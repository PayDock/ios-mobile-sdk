//
//  ClientSdkVersionResolutionTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

/// The Client SDK address: the environment's alias of the supported line, or the merchant's pin.
final class ClientSdkVersionResolutionTests: XCTestCase {

    override func tearDown() {
        MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: .sandbox))
        super.tearDown()
    }

    func testSupportedLineAndAliases() {
        XCTAssertEqual(Constants.clientSdkSupportedLine, "v1.150")
        XCTAssertEqual(Constants.clientSdkStableVersion, "v1.150.stable")
        XCTAssertEqual(Constants.clientSdkCandidateVersion, "v1.150.candidate")
    }

    func testWithoutPin_productionAndSandboxLoadStable_stagingLoadsCandidate() {
        let expected: [(SDKEnvironment, String)] = [
            (.production, "https://widget.paydock.com/sdk/v1.150.stable/widget.umd.min.js"),
            (.sandbox, "https://widget.paydock.com/sdk/v1.150.stable/widget.umd.min.js"),
            (.staging, "https://widget.paydock.com/sdk/v1.150.candidate/widget.umd.min.js")
        ]
        for (environment, address) in expected {
            MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: environment))
            XCTAssertEqual(Constants.clientSdkUrlString, address, "\(environment)")
        }
    }

    func testPinWinsInEveryEnvironment() throws {
        for environment in [SDKEnvironment.production, .sandbox, .staging] {
            let config = try MobileSDKConfig(environment: environment, clientSdkVersion: "v1.150.1")
            MobileSDK.shared.configureMobileSDK(config: config)
            XCTAssertEqual(Constants.clientSdkUrlString,
                           "https://widget.paydock.com/sdk/v1.150.1/widget.umd.min.js", "\(environment)")
        }
    }

    func testAddressShape() {
        XCTAssertEqual(Constants.clientSdkUrlString(version: "v1.150.stable"),
                       "https://widget.paydock.com/sdk/v1.150.stable/widget.umd.min.js")
    }

    func testExistingInitialiser_needsNoTry_andHasNoPin() {
        let config = MobileSDKConfig(environment: .production)
        XCTAssertNil(config.clientSdkVersion)

        MobileSDK.shared.configureMobileSDK(config: config)
        XCTAssertEqual(Constants.clientSdkUrlString, "https://widget.paydock.com/sdk/v1.150.stable/widget.umd.min.js")
    }

    func testPinnedInitialiser_acceptsReleaseOfTheLine() throws {
        let config = try MobileSDKConfig(environment: .sandbox, clientSdkVersion: "v1.150.1")
        XCTAssertEqual(config.clientSdkVersion, "v1.150.1")

        MobileSDK.shared.configureMobileSDK(config: config)
        XCTAssertEqual(Constants.clientSdkUrlString, "https://widget.paydock.com/sdk/v1.150.1/widget.umd.min.js")
    }

    func testPinnedInitialiser_refusesOtherLine() {
        assertRefused("v1.151.0")
        assertRefused("v2.150.0")
    }

    func testPinnedInitialiser_refusesBetaAliasesAndMalformedVersions() {
        for version in ["v1.150.1-beta", "v1.150.stable", "v1.150.candidate", "v1.150", "1.150.1", "v1.150.x",
                        "v1..1", ""] {
            assertRefused(version)
        }
    }

    func testRefusal_codeAndMessageNameTheLine() {
        let error = MobileSDKConfigError.clientSdkVersionOutsideSupportedLine(clientSdkVersion: "v1.151.0",
                                                                              supportedLine: "v1.150")
        XCTAssertEqual(error.code, "CONFIG_CLIENT_SDK_VERSION_OUTSIDE_SUPPORTED_LINE")
        XCTAssertEqual(error.customMessage, "clientSdkVersion v1.151.0 is outside supported line v1.150")
    }

    private func assertRefused(_ version: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try MobileSDKConfig(environment: .sandbox, clientSdkVersion: version),
                             file: file, line: line) { error in
            XCTAssertEqual(error as? MobileSDKConfigError,
                           .clientSdkVersionOutsideSupportedLine(clientSdkVersion: version, supportedLine: "v1.150"),
                           file: file, line: line)
        }
    }
}
