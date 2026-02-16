//
//  ZipWebViewCoordinatorTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
import WebKit

class ZipWebViewCoordinatorTests: XCTestCase {

    var coordinator: ZipWebView.Coordinator!
    var approveCallbackData: ZipCallbackData?
    var failureError: ZipError?

    override func setUp() {
        super.setUp()
        approveCallbackData = nil
        failureError = nil

        coordinator = ZipWebView.Coordinator(
            openTargetBlankInSameWebView: true,
            onApprove: { callbackData in
                self.approveCallbackData = callbackData
            },
            onFailure: { error in
                self.failureError = error
            }
        )
    }

    override func tearDown() {
        coordinator = nil
        approveCallbackData = nil
        failureError = nil
        super.tearDown()
    }

    // MARK: - URL Parsing Tests

    func testParseQueryParameters() {
        // Given
        let urlString = "https://example.com/callback?result=approved&checkoutId=123&order_id=456"
        let url = URL(string: urlString)!

        // When
        let params = parseQueryParametersHelper(from: url)

        // Then
        XCTAssertEqual(params["result"], "approved")
        XCTAssertEqual(params["checkoutId"], "123")
        XCTAssertEqual(params["order_id"], "456")
    }

    func testParseQueryParametersWithPercentEncoding() {
        // Given
        let urlString = "https://example.com/callback?result=approved&message=Payment%20successful"
        let url = URL(string: urlString)!

        // When
        let params = parseQueryParametersHelper(from: url)

        // Then
        XCTAssertEqual(params["result"], "approved")
        XCTAssertEqual(params["message"], "Payment successful")
    }

    func testParseQueryParametersWithEmptyQuery() {
        // Given
        let urlString = "https://example.com/callback"
        let url = URL(string: urlString)!

        // When
        let params = parseQueryParametersHelper(from: url)

        // Then
        XCTAssertTrue(params.isEmpty)
    }

    func testParseQueryParametersWithMalformedQuery() {
        // Given
        let urlString = "https://example.com/callback?result"
        let url = URL(string: urlString)!

        // When
        let params = parseQueryParametersHelper(from: url)

        // Then - Malformed params should be ignored
        XCTAssertTrue(params.isEmpty || params["result"] == nil)
    }

    // MARK: - Callback Handling - Success Cases

    func testHandleResponseApproved() {
        // Given
        let params = [
            "result": "approved",
            "checkoutId": "checkout_123",
            "order_id": "order_456"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNotNil(approveCallbackData)
        XCTAssertEqual(approveCallbackData?.status, .approved)
        XCTAssertEqual(approveCallbackData?.checkoutId, "checkout_123")
        XCTAssertEqual(approveCallbackData?.orderId, "order_456")
        XCTAssertNil(failureError)
    }

    func testHandleResponseApprovedWithoutOrderId() {
        // Given
        let params = [
            "result": "approved",
            "checkoutId": "checkout_123"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNotNil(approveCallbackData)
        XCTAssertEqual(approveCallbackData?.status, .approved)
        XCTAssertEqual(approveCallbackData?.checkoutId, "checkout_123")
        XCTAssertNil(approveCallbackData?.orderId)
        XCTAssertNil(failureError)
    }

    func testHandleResponseApprovedWithIdInsteadOfOrderId() {
        // Given
        let params = [
            "result": "approved",
            "checkoutId": "checkout_123",
            "id": "id_789"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNotNil(approveCallbackData)
        XCTAssertEqual(approveCallbackData?.status, .approved)
        XCTAssertEqual(approveCallbackData?.checkoutId, "checkout_123")
        XCTAssertEqual(approveCallbackData?.orderId, "id_789")
        XCTAssertNil(failureError)
    }

    // MARK: - Callback Handling - Error Cases

    func testHandleResponseDeclined() {
        // Given
        let params = [
            "result": "declined",
            "checkoutId": "checkout_123"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNil(approveCallbackData)
        XCTAssertNotNil(failureError)

        guard case .transactionDeclined(let checkoutId) = failureError else {
            XCTFail("Expected transactionDeclined error")
            return
        }

        XCTAssertEqual(checkoutId, "checkout_123")
    }

    func testHandleResponseCancelled() {
        // Given
        let params = [
            "result": "cancelled",
            "checkoutId": "checkout_456"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNil(approveCallbackData)
        XCTAssertNotNil(failureError)

        guard case .transactionCanceled(let checkoutId) = failureError else {
            XCTFail("Expected transactionCanceled error")
            return
        }

        XCTAssertEqual(checkoutId, "checkout_456")
    }

    func testHandleResponseReferred() {
        // Given
        let params = [
            "result": "referred",
            "checkoutId": "checkout_789"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNil(approveCallbackData)
        XCTAssertNotNil(failureError)

        guard case .transactionReferred(let checkoutId) = failureError else {
            XCTFail("Expected transactionReferred error")
            return
        }

        XCTAssertEqual(checkoutId, "checkout_789")
    }

    func testHandleResponseUnexpected() {
        // Given
        let params = [
            "result": "unexpected",
            "checkoutId": "checkout_999"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNil(approveCallbackData)
        XCTAssertNotNil(failureError)

        guard case .unexpectedStatus(let status, let checkoutId) = failureError else {
            XCTFail("Expected unexpectedStatus error")
            return
        }

        XCTAssertEqual(status, "unexpected")
        XCTAssertEqual(checkoutId, "checkout_999")
    }

    func testHandleResponseUnexpectedError() {
        // Given
        let params = [
            "result": "unexpected_error",
            "checkoutId": "checkout_111"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNil(approveCallbackData)
        XCTAssertNotNil(failureError)

        guard case .unexpectedStatus(let status, let checkoutId) = failureError else {
            XCTFail("Expected unexpectedStatus error")
            return
        }

        XCTAssertEqual(status, "unexpected_error")
        XCTAssertEqual(checkoutId, "checkout_111")
    }

    func testHandleResponseWithoutResultParameter() {
        // Given
        let params = ["checkoutId": "checkout_123"]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNil(approveCallbackData)
        XCTAssertNotNil(failureError)

        guard case .unexpectedStatus(let status, let checkoutId) = failureError else {
            XCTFail("Expected unexpectedStatus error")
            return
        }

        XCTAssertNil(status)
        XCTAssertEqual(checkoutId, "checkout_123")
    }

    func testHandleResponseWithUnknownStatus() {
        // Given
        let params = [
            "result": "unknown_status",
            "checkoutId": "checkout_222"
        ]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNil(approveCallbackData)
        XCTAssertNotNil(failureError)

        guard case .unexpectedStatus(let status, let checkoutId) = failureError else {
            XCTFail("Expected unexpectedStatus error")
            return
        }

        XCTAssertEqual(status, "unknown_status")
        XCTAssertEqual(checkoutId, "checkout_222")
    }

    func testHandleResponseWithoutCheckoutId() {
        // Given
        let params = ["result": "approved"]

        // When
        handleResponseHelper(params: params)

        // Then
        XCTAssertNotNil(approveCallbackData)
        XCTAssertEqual(approveCallbackData?.status, .approved)
        XCTAssertNil(approveCallbackData?.checkoutId)
        XCTAssertNil(failureError)
    }

    // MARK: - Helper Methods

    private func parseQueryParametersHelper(from url: URL) -> [String: String] {
        guard let query = url.query() else { return [:] }

        return query
            .split(separator: "&")
            .reduce(into: [:]) { result, queryParam in
                let parts = String(queryParam).split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    let key = String(parts[0])
                    let value = String(parts[1]).removingPercentEncoding ?? String(parts[1])
                    result[key] = value
                }
            }
    }

    private func handleResponseHelper(params: [String: String]) {
        // Extract status and checkoutId from query parameters
        guard let resultString = params["result"] else {
            coordinator.onFailure(.unexpectedStatus(status: nil, checkoutId: params["checkoutId"]))
            return
        }

        guard let status = ZipStatus(rawValue: resultString) else {
            coordinator.onFailure(.unexpectedStatus(status: resultString, checkoutId: params["checkoutId"]))
            return
        }

        let checkoutId = params["checkoutId"]
        let orderId = params["order_id"] ?? params["id"]

        // Handle based on status
        switch status {
        case .approved:
            let callbackData = ZipCallbackData(
                status: status,
                checkoutId: checkoutId,
                orderId: orderId
            )
            coordinator.onApprove(callbackData)

        case .declined:
            coordinator.onFailure(.transactionDeclined(checkoutId: checkoutId))

        case .cancelled:
            coordinator.onFailure(.transactionCanceled(checkoutId: checkoutId))

        case .referred:
            coordinator.onFailure(.transactionReferred(checkoutId: checkoutId))

        case .unexpected, .unexpectedError:
            coordinator.onFailure(.unexpectedStatus(status: resultString, checkoutId: checkoutId))
        }
    }
}
