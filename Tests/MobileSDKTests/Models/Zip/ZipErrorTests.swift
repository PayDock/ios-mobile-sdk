//
//  ZipErrorTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
@testable import NetworkingLib

class ZipErrorTests: XCTestCase {

    // MARK: - Custom Message Tests

    func testErrorFetchingZipUrlCustomMessage() {
        // Given - API returns a message, so we show the API failure reason
        let errorRes = ErrorRes(
            status: 400,
            error: .init(message: "Invalid gateway", code: "INVALID_GATEWAY", details: nil),
            resource: nil,
            errorSummary: nil
        )
        let error = ZipError.errorFetchingZipUrl(error: errorRes)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Invalid gateway")
    }

    func testErrorFetchingZipUrlCustomMessageWhenNoApiMessage() {
        // Given - No API message, fallback is shown
        let errorRes = ErrorRes(status: 400, error: nil, resource: nil, errorSummary: nil)
        let error = ZipError.errorFetchingZipUrl(error: errorRes)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unable to fetch Zip widget URL")
    }

    func testErrorCapturingChargeCustomMessage() {
        // Given - API returns a message, so we show the API failure reason
        let errorRes = ErrorRes(
            status: 500,
            error: .init(message: "Charge failed", code: "CHARGE_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        let error = ZipError.errorCapturingCharge(error: errorRes)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Charge failed")
    }

    func testErrorCapturingChargeCustomMessageWhenNoApiMessage() {
        // Given - No API message, fallback is shown
        let errorRes = ErrorRes(status: 500, error: nil, resource: nil, errorSummary: nil)
        let error = ZipError.errorCapturingCharge(error: errorRes)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unable to complete the charge")
    }

    func testInvalidCheckoutUrlCustomMessage() {
        // Given
        let error = ZipError.invalidCheckoutUrl

        // When
        let message = error.customMessage

        // Then - Matches INVALID_URL
        XCTAssertEqual(message, "Unsupported URL - unable to proceed.")
    }

    func testWebViewFailedCustomMessage() {
        // Given - NSError has localizedDescription, so we show it (e.g. "Request timed out", "Network connection was lost")
        let nsError = NSError(domain: "WebViewError", code: -1, userInfo: [NSLocalizedDescriptionKey: "WebView crashed"])
        let error = ZipError.webViewFailed(error: nsError)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Zip WebView widget has failed: WebView crashed")
    }

    func testWebViewFailedCustomMessageWhenDescriptionEmpty() {
        // Given - NSError with no userInfo; system may still provide a localizedDescription
        let nsError = NSError(domain: "WebViewError", code: -1, userInfo: nil)
        let error = ZipError.webViewFailed(error: nsError)

        // When
        let message = error.customMessage

        // Then - We show the system description when present (e.g. "The operation couldn't be completed. (WebViewError error -1.)")
        XCTAssertTrue(message.hasPrefix("Zip WebView widget has failed"), "Should prefix with fallback")
        let isFallbackOrDetail = message == "Zip WebView widget has failed" || message.contains("WebViewError")
        XCTAssertTrue(isFallbackOrDetail, "Should be fallback or include detail")
    }

    func testWebViewFailedCustomMessageForTimedOut() {
        // Given - NSURLErrorDomain timed out (e.g. from WKWebView)
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        let error = ZipError.webViewFailed(error: nsError)

        // When
        let message = error.customMessage

        // Then - Specific message for timeout
        XCTAssertEqual(message, "The request timed out. Please check your connection and try again.")
    }

    func testWebViewFailedCustomMessageForNetworkConnectionLost() {
        // Given - NSURLErrorDomain connection lost (e.g. from WKWebView)
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost, userInfo: nil)
        let error = ZipError.webViewFailed(error: nsError)

        // When
        let message = error.customMessage

        // Then - Specific message for connection lost
        XCTAssertEqual(message, "The network connection was lost. Please try again.")
    }

    func testWebViewFailedCustomMessageForNotConnectedToInternet() {
        // Given - NSURLErrorDomain not connected to internet
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let error = ZipError.webViewFailed(error: nsError)

        // When
        let message = error.customMessage

        // Then - Specific message for offline
        XCTAssertEqual(message, "The Internet connection appears to be offline. Please check your network.")
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
        // Given - No request error
        let error = ZipError.unknownError(nil)

        // When
        let message = error.customMessage

        // Then
        XCTAssertEqual(message, "Unknown error")
    }

    func testUnknownErrorWithRequestErrorCustomMessage() {
        // Given - Underlying RequestError (e.g. connection timeout) supplies uiMessage
        let requestError = RequestError.connectionError(URLError(.timedOut))
        let error = ZipError.unknownError(requestError)

        // When
        let message = error.customMessage

        // Then - Uses RequestError.uiMessage (e.g. timed out description)
        XCTAssertNotEqual(message, "Unknown error")
        XCTAssertFalse(message.isEmpty)
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
        let error = ZipError.unknownError(nil)

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
