//
//  NSErrorWebViewMessageTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

class NSErrorWebViewMessageTests: XCTestCase {

    // MARK: - isWebViewNavigationCancellation

    func testIsWebViewNavigationCancellation_NSURLErrorCancelled() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
        XCTAssertTrue(error.isWebViewNavigationCancellation)
    }

    func testIsWebViewNavigationCancellation_WebKitFrameLoadInterrupted() {
        let error = NSError(domain: "WebKitErrorDomain", code: 102, userInfo: nil)
        XCTAssertTrue(error.isWebViewNavigationCancellation)
    }

    func testIsWebViewNavigationCancellation_FalseForTimedOut() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        XCTAssertFalse(error.isWebViewNavigationCancellation)
    }

    func testIsWebViewNavigationCancellation_FalseForOtherDomain() {
        let error = NSError(domain: "CustomDomain", code: NSURLErrorCancelled, userInfo: nil)
        XCTAssertFalse(error.isWebViewNavigationCancellation)
    }

    private let fallback = "WebView widget has failed"

    // MARK: - NSURLErrorDomain specific messages

    func testTimedOut() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "The request timed out. Please check your connection and try again."
        )
    }

    func testNetworkConnectionLost() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "The network connection was lost. Please try again."
        )
    }

    func testNotConnectedToInternet() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "The Internet connection appears to be offline. Please check your network."
        )
    }

    func testCannotFindHost() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotFindHost, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "The server could not be found. Please check the address and try again."
        )
    }

    func testCannotConnectToHost() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "Could not connect to the server. Please try again."
        )
    }

    func testSecureConnectionFailed() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorSecureConnectionFailed, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "A secure connection could not be established. Please try again."
        )
    }

    func testCancelled() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "The request was cancelled."
        )
    }

    func testInternationalRoamingOff() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorInternationalRoamingOff, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "Data roaming is off. Please enable it or connect to Wi‑Fi."
        )
    }

    func testDataNotAllowed() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorDataNotAllowed, userInfo: nil)
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "Cellular data is not allowed for this app. Please use Wi‑Fi or enable data."
        )
    }

    // MARK: - Unknown URL error code uses fallback + detail when present

    func testUnknownNSURLErrorCodeWithDescription() {
        let error = NSError(
            domain: NSURLErrorDomain,
            code: -9999,
            userInfo: [NSLocalizedDescriptionKey: "Custom URL error"]
        )
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "\(fallback): Custom URL error"
        )
    }

    // MARK: - Non-NSURLErrorDomain uses fallback + localizedDescription

    func testOtherDomainWithDescription() {
        let error = NSError(
            domain: "WebKitErrorDomain",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Frame load interrupted"]
        )
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: fallback),
            "\(fallback): Frame load interrupted"
        )
    }

    func testOtherDomainEmptyDescriptionReturnsFallback() {
        let error = NSError(domain: "CustomDomain", code: -1, userInfo: nil)
        let message = error.webViewFailureMessage(fallback: fallback)
        XCTAssertTrue(
            message == fallback || message.hasPrefix(fallback),
            "Should return fallback or fallback with system detail"
        )
    }

    // MARK: - Fallback varies per widget

    func testFallbackUsedForZip() {
        let error = NSError(domain: "Other", code: 0, userInfo: [NSLocalizedDescriptionKey: "Detail"])
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: "Zip WebView widget has failed"),
            "Zip WebView widget has failed: Detail"
        )
    }

    func testFallbackUsedForColesPay() {
        let error = NSError(domain: "Other", code: 0, userInfo: [NSLocalizedDescriptionKey: "Detail"])
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: "Coles Pay WebView widget has failed"),
            "Coles Pay WebView widget has failed: Detail"
        )
    }

    func testFallbackUsedFor3DS() {
        let error = NSError(domain: "Other", code: 0, userInfo: [NSLocalizedDescriptionKey: "Detail"])
        XCTAssertEqual(
            error.webViewFailureMessage(fallback: "3DS WebView widget has failed"),
            "3DS WebView widget has failed: Detail"
        )
    }
}
