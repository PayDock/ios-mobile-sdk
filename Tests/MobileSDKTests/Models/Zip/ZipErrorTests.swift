//
//  ZipErrorTests.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import XCTest
@testable import MobileSDK
@testable import NetworkingLib

class ZipErrorTests: XCTestCase {

    // MARK: - Custom Message Tests

    func testErrorFetchingZipUrlCustomMessage() {
        // Given
        let errorRes = ErrorRes(
            status: 400,
            error: ErrorRes.ErrorObj(message: "Invalid gateway", code: "INVALID_GATEWAY"),
            resource: nil,
            errorSummary: nil
        )
        let error = ZipError.errorFetchingZipUrl(error: errorRes)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unable to fetch Zip widget URL")
    }

    func testErrorCapturingChargeCustomMessage() {
        // Given
        let errorRes = ErrorRes(
            status: 500,
            error: ErrorRes.ErrorObj(message: "Charge failed", code: "CHARGE_ERROR"),
            resource: nil,
            errorSummary: nil
        )
        let error = ZipError.errorCapturingCharge(error: errorRes)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unable to complete the charge")
    }

    func testWebViewFailedCustomMessage() {
        // Given
        let nsError = NSError(domain: "WebViewError", code: -1, userInfo: [NSLocalizedDescriptionKey: "WebView crashed"])
        let error = ZipError.webViewFailed(error: nsError)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Zip WebView widget has failed")
    }

    func testTransactionCanceledCustomMessage() {
        // Given
        let error = ZipError.transactionCanceled(checkoutId: "checkout_123")

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Zip transaction was canceled")
    }

    func testTransactionDeclinedCustomMessage() {
        // Given
        let error = ZipError.transactionDeclined(checkoutId: "checkout_456")

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Zip transaction was declined")
    }

    func testTransactionReferredCustomMessage() {
        // Given
        let error = ZipError.transactionReferred(checkoutId: "checkout_789")

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Zip transaction requires review (referred)")
    }

    func testUnexpectedStatusCustomMessageWithStatus() {
        // Given
        let error = ZipError.unexpectedStatus(status: "processing", checkoutId: "checkout_111")

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unexpected Zip status: processing")
    }

    func testUnexpectedStatusCustomMessageWithoutStatus() {
        // Given
        let error = ZipError.unexpectedStatus(status: nil, checkoutId: "checkout_222")

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unexpected Zip status: unknown")
    }

    func testInitialisingWalletTokenCustomMessage() {
        // Given
        let error = ZipError.initialisingWalletToken(reason: "Token expired")

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Token expired")
    }

    func testUnknownErrorCustomMessage() {
        // Given
        let error = ZipError.unknownError

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unknown error")
    }

    // MARK: - CheckoutId Extraction Tests

    func testCheckoutIdFromTransactionCanceled() {
        // Given
        let error = ZipError.transactionCanceled(checkoutId: "checkout_123")

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertEqual(checkoutId, "checkout_123")
    }

    func testCheckoutIdFromTransactionDeclined() {
        // Given
        let error = ZipError.transactionDeclined(checkoutId: "checkout_456")

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertEqual(checkoutId, "checkout_456")
    }

    func testCheckoutIdFromTransactionReferred() {
        // Given
        let error = ZipError.transactionReferred(checkoutId: "checkout_789")

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertEqual(checkoutId, "checkout_789")
    }

    func testCheckoutIdFromUnexpectedStatus() {
        // Given
        let error = ZipError.unexpectedStatus(status: "processing", checkoutId: "checkout_999")

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertEqual(checkoutId, "checkout_999")
    }

    func testCheckoutIdNilFromErrorFetchingZipUrl() {
        // Given
        let errorRes = ErrorRes(status: 400, error: nil, resource: nil, errorSummary: nil)
        let error = ZipError.errorFetchingZipUrl(error: errorRes)

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertNil(checkoutId)
    }

    func testCheckoutIdNilFromErrorCapturingCharge() {
        // Given
        let errorRes = ErrorRes(status: 500, error: nil, resource: nil, errorSummary: nil)
        let error = ZipError.errorCapturingCharge(error: errorRes)

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertNil(checkoutId)
    }

    func testCheckoutIdNilFromWebViewFailed() {
        // Given
        let nsError = NSError(domain: "Test", code: -1, userInfo: nil)
        let error = ZipError.webViewFailed(error: nsError)

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertNil(checkoutId)
    }

    func testCheckoutIdNilFromUnknownError() {
        // Given
        let error = ZipError.unknownError

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertNil(checkoutId)
    }

    func testCheckoutIdNilFromInitialisingWalletToken() {
        // Given
        let error = ZipError.initialisingWalletToken(reason: "Token expired")

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertNil(checkoutId)
    }

    func testCheckoutIdNilWhenExplicitlyNil() {
        // Given
        let error = ZipError.transactionCanceled(checkoutId: nil)

        // When
        let checkoutId = error.checkoutId

        // Then
        XCTAssertNil(checkoutId)
    }
}
