//
//  ErrorResApiFailureMessageTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.
//

import XCTest
@testable import MobileSDK
@testable import NetworkingLib

class ErrorResApiFailureMessageTests: XCTestCase {

    private let fallback = "Something went wrong"

    // MARK: - Uses error.message when present

    func testReturnsErrorMessageWhenPresent() {
        let errorRes = ErrorRes(
            status: 400,
            error: .init(message: "Invalid gateway", code: "INVALID_GATEWAY", details: nil),
            resource: nil,
            errorSummary: nil
        )
        XCTAssertEqual(
            errorRes.apiFailureMessage(fallback: fallback),
            "Invalid gateway"
        )
    }

    // MARK: - Returns fallback when no message

    func testReturnsFallbackWhenErrorAndErrorSummaryNil() {
        let errorRes = ErrorRes(status: 400, error: nil, resource: nil, errorSummary: nil)
        XCTAssertEqual(
            errorRes.apiFailureMessage(fallback: fallback),
            fallback
        )
    }

    func testReturnsFallbackWhenMessageEmpty() {
        let errorRes = ErrorRes(
            status: 400,
            error: .init(message: "", code: "CODE", details: nil),
            resource: nil,
            errorSummary: nil
        )
        XCTAssertEqual(
            errorRes.apiFailureMessage(fallback: fallback),
            fallback
        )
    }

    func testReturnsFallbackWhenMessageWhitespaceOnly() {
        let errorRes = ErrorRes(
            status: 400,
            error: .init(message: "   ", code: "CODE", details: nil),
            resource: nil,
            errorSummary: nil
        )
        XCTAssertEqual(
            errorRes.apiFailureMessage(fallback: fallback),
            fallback
        )
    }

    // MARK: - Trims whitespace

    func testTrimsMessageWhitespace() {
        let errorRes = ErrorRes(
            status: 400,
            error: .init(message: "  Actual message  ", code: "CODE", details: nil),
            resource: nil,
            errorSummary: nil
        )
        XCTAssertEqual(
            errorRes.apiFailureMessage(fallback: fallback),
            "Actual message"
        )
    }

    // MARK: - Fallback varies per consumer

    func testFallbackUsedForZipFetchUrl() {
        let errorRes = ErrorRes(status: 404, error: nil, resource: nil, errorSummary: nil)
        XCTAssertEqual(
            errorRes.apiFailureMessage(fallback: "Unable to fetch Zip widget URL"),
            "Unable to fetch Zip widget URL"
        )
    }

    func testFallbackUsedForColesPay() {
        let errorRes = ErrorRes(status: 500, error: nil, resource: nil, errorSummary: nil)
        XCTAssertEqual(
            errorRes.apiFailureMessage(fallback: "Unable to fetch Coles Pay widget order ID"),
            "Unable to fetch Coles Pay widget order ID"
        )
    }
}
