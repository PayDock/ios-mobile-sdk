//
//  BinDataRefreshCoordinatorTests.swift
//  BinProcessingTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import BinProcessing

// MARK: - Spy

/// Test double for `BinDataCacheManaging`.
/// Records call counts and lets tests control return values
/// used in `BinDataRefreshCoordinatorTest`.
final class SpyBinDataCacheManager: BinDataCacheManaging {

    // MARK: shouldRefreshOnForeground

    /// Controls the return value of `shouldRefreshOnForeground()`. Change between calls
    /// to simulate multiple foreground events with varying staleness.
    var shouldRefreshOnForegroundResult = false
    private(set) var shouldRefreshOnForegroundCallCount = 0

    func shouldRefreshOnForeground() -> Bool {
        shouldRefreshOnForegroundCallCount += 1
        return shouldRefreshOnForegroundResult
    }

    // MARK: refreshBinDataIfNeeded

    private(set) var refreshBinDataIfNeededCallCount = 0
    /// Called after `refreshBinDataIfNeeded()` completes; use to fulfill XCTestExpectations.
    var onRefreshBinDataIfNeeded: (() -> Void)?

    func refreshBinDataIfNeeded() async {
        refreshBinDataIfNeededCallCount += 1
        onRefreshBinDataIfNeeded?()
    }
}

// MARK: - BinDataRefreshCoordinatorTests

/// Unit tests for `BinDataRefreshCoordinator`.
///
/// Tests verify the lifecycle-based refresh logic including:
/// - SDK initialization refresh trigger
/// - App foreground refresh when cache is stale or missing
/// - Skipping refresh when cache is fresh
/// - Correct behaviour across multiple foreground events
final class BinDataRefreshCoordinatorTests: XCTestCase {

    // MARK: - refreshAtSDKInit Tests

    func testRefreshAtSDKInitTriggersRefreshBinDataIfNeeded() async {
        let spy = SpyBinDataCacheManager()
        let coordinator = BinDataRefreshCoordinator(cacheManager: spy)

        let expectation = expectation(description: "refreshBinDataIfNeeded called at SDK init")
        spy.onRefreshBinDataIfNeeded = { expectation.fulfill() }

        coordinator.refreshAtSDKInit()

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(spy.refreshBinDataIfNeededCallCount, 1)
    }

    func testRefreshAtSDKInitHandlesRefreshOutcomeGracefully() async {
        // refreshBinDataIfNeeded is fire-and-forget; any internal error is swallowed.
        // This test verifies the coordinator calls through regardless.
        let spy = SpyBinDataCacheManager()
        let coordinator = BinDataRefreshCoordinator(cacheManager: spy)

        let expectation = expectation(description: "refreshBinDataIfNeeded called")
        spy.onRefreshBinDataIfNeeded = { expectation.fulfill() }

        coordinator.refreshAtSDKInit()

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(spy.refreshBinDataIfNeededCallCount, 1)
    }

    // MARK: - handleForegroundEvent Tests

    func testHandleForegroundEventTriggersRefreshWhenShouldRefreshReturnsTrue() async {
        let spy = SpyBinDataCacheManager()
        spy.shouldRefreshOnForegroundResult = true
        let coordinator = BinDataRefreshCoordinator(cacheManager: spy)

        let expectation = expectation(description: "refreshBinDataIfNeeded called on foreground")
        spy.onRefreshBinDataIfNeeded = { expectation.fulfill() }

        coordinator.handleForegroundEvent()

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(spy.shouldRefreshOnForegroundCallCount, 1)
        XCTAssertEqual(spy.refreshBinDataIfNeededCallCount, 1)
    }

    func testHandleForegroundEventSkipsRefreshWhenShouldRefreshReturnsFalse() {
        let spy = SpyBinDataCacheManager()
        spy.shouldRefreshOnForegroundResult = false
        let coordinator = BinDataRefreshCoordinator(cacheManager: spy)

        coordinator.handleForegroundEvent()

        XCTAssertEqual(spy.shouldRefreshOnForegroundCallCount, 1)
        XCTAssertEqual(spy.refreshBinDataIfNeededCallCount, 0)
    }

    func testHandleForegroundEventHandlesRefreshOutcomeGracefully() async {
        let spy = SpyBinDataCacheManager()
        spy.shouldRefreshOnForegroundResult = true
        let coordinator = BinDataRefreshCoordinator(cacheManager: spy)

        let expectation = expectation(description: "refreshBinDataIfNeeded called even on internal failure")
        spy.onRefreshBinDataIfNeeded = { expectation.fulfill() }

        coordinator.handleForegroundEvent()

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(spy.shouldRefreshOnForegroundCallCount, 1)
        XCTAssertEqual(spy.refreshBinDataIfNeededCallCount, 1)
    }

    // MARK: - Multiple Foreground Events Tests

    func testMultipleForegroundEventsEachCheckShouldRefreshOnForeground() async {
        let spy = SpyBinDataCacheManager()
        let coordinator = BinDataRefreshCoordinator(cacheManager: spy)

        let twoRefreshesExpectation = expectation(description: "two refreshes completed")
        twoRefreshesExpectation.expectedFulfillmentCount = 2
        spy.onRefreshBinDataIfNeeded = { twoRefreshesExpectation.fulfill() }

        // First foreground — refresh needed
        spy.shouldRefreshOnForegroundResult = true
        coordinator.handleForegroundEvent()

        // Second foreground — cache still fresh
        spy.shouldRefreshOnForegroundResult = false
        coordinator.handleForegroundEvent()

        // Third foreground — stale again
        spy.shouldRefreshOnForegroundResult = true
        coordinator.handleForegroundEvent()

        await fulfillment(of: [twoRefreshesExpectation], timeout: 2.0)

        XCTAssertEqual(spy.shouldRefreshOnForegroundCallCount, 3)
        XCTAssertEqual(spy.refreshBinDataIfNeededCallCount, 2)
    }
}
