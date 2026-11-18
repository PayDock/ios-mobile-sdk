//
//  ApiHostsTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
import NetworkingLib
import PaydockTelemetry

/// R_02: the hosts the SDK points NetworkingLib at, one per `SDKEnvironment`, are exactly the telemetry target's API
/// hosts, so a failed attempt on any of them is reportable and nothing else is.
final class ApiHostsTests: XCTestCase {

    private static let environments: [SDKEnvironment] = [.production, .sandbox, .staging]

    override func tearDown() {
        MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: .sandbox))
        super.tearDown()
    }

    func testTheHostsOfEveryEnvironment_EqualTheApiHosts() {
        var hosts: [String] = []
        for environment in Self.environments {
            MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: environment))
            XCTAssertEqual(NetworkingLib.shared.host, Constants.baseURL, environment.rawValue)
            hosts.append(Constants.baseURL)
        }

        XCTAssertEqual(hosts.count, Set(hosts).count, "one host per environment")
        XCTAssertEqual(Set(hosts), NetworkFailureFacts.apiHosts)
    }

    #if DEBUG
    /// A debug build also accepts the example app's two stand-in hosts, and nothing else beyond the API hosts.
    func testTheReportableHosts_AreTheApiHostsAndTheStandIns() {
        XCTAssertEqual(NetworkFailureFacts.reportableHosts, NetworkFailureFacts.apiHosts.union(DebugStandInHosts.all))
    }
    #endif
}
