//
//  ReportSiteTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_03: the site is captured where SDK code reports, and nothing else happens there.
final class ReportSiteTests: XCTestCase {

    func testCapture_OnTheMainThread_GivesItsAddresses_AtMost64_AndMain() {
        XCTAssertTrue(Thread.isMainThread)

        let site = ReportSite.capture()

        XCTAssertFalse(site.returnAddresses.isEmpty)
        XCTAssertLessThanOrEqual(site.returnAddresses.count, TelemetryEvent.ErrorInfo.maxFrames)
        XCTAssertEqual(TelemetryEvent.ErrorInfo.maxFrames, 64)
        XCTAssertEqual(site.threadName, "main")
    }

    func testCapture_DeepInARecursion_KeepsAtMost64() {
        let site = Self.captureAt(depth: 100)

        XCTAssertEqual(site.returnAddresses.count, 64)
    }

    func testCapture_OnANamedThread_GivesItsName_AndNilForAnUnnamedOne() {
        let named = Self.capture(onThreadNamed: "com.paydock.sample")
        let unnamed = Self.capture(onThreadNamed: nil)

        XCTAssertEqual(named.threadName, "com.paydock.sample")
        XCTAssertNil(unnamed.threadName)
        XCTAssertFalse(named.returnAddresses.isEmpty)
    }

    func testInit_KeepsAtMost64Addresses() {
        let site = ReportSite(returnAddresses: Array(1...100), threadName: nil)

        XCTAssertEqual(site.returnAddresses, Array(1...64))
    }

    // MARK: - Helpers

    @inline(never)
    private static func captureAt(depth: Int) -> ReportSite {
        depth == 0 ? ReportSite.capture() : captureAt(depth: depth - 1)
    }

    private static func capture(onThreadNamed name: String?) -> ReportSite {
        let box = SiteBox()
        let done = DispatchSemaphore(value: 0)
        let thread = Thread {
            box.site = ReportSite.capture()
            done.signal()
        }
        thread.name = name
        thread.start()
        done.wait()
        return box.site ?? ReportSite(returnAddresses: [], threadName: "not captured")
    }

    private final class SiteBox: @unchecked Sendable {
        var site: ReportSite?
    }
}
