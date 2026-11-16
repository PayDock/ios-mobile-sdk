//
//  Standalone3DSFailureTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import WebKit
@testable import MobileSDK

/// Failures the page can't recover from (Client SDK script load, web content process termination) and the session
/// context added to `webViewFailed` errors.
@MainActor
final class Standalone3DSFailureTests: XCTestCase {

    private var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
    private var inBackground = false

    private var failures: [Standalone3DSError] {
        results.compactMap {
            if case .failure(let error) = $0 { return error }
            return nil
        }
    }

    override func setUp() {
        super.setUp()
        results = []
        inBackground = false
    }

    private func makeCoordinator(charge3dsId: String? = "token-charge-id") -> Standalone3DSWidget.Coordinator {
        Standalone3DSWidget.Coordinator(completion: { [unowned self] in self.results.append($0) },
                                        charge3dsId: charge3dsId,
                                        clientSdkHost: "widget.paydock.com",
                                        isAppInBackground: { [unowned self] in self.inBackground })
    }

    private func webViewError(_ error: Standalone3DSError?) -> NSError? {
        guard case .webViewFailed(let nsError)? = error else { return nil }
        return nsError
    }

    // MARK: - Web content process termination

    func testContentProcessTerminated_endsSessionOnceWithContext() {
        let coordinator = makeCoordinator()
        inBackground = true

        coordinator.webViewWebContentProcessDidTerminate(WKWebView())
        coordinator.webViewWebContentProcessDidTerminate(WKWebView())

        XCTAssertEqual(failures.count, 1)
        let error = webViewError(failures.first)
        XCTAssertEqual(error?.domain, WKError.errorDomain)
        XCTAssertEqual(error?.code, WKError.Code.webContentProcessTerminated.rawValue)
        XCTAssertEqual(failures.first?.charge3dsId, "token-charge-id")
        XCTAssertEqual(failures.first?.inBackground, true)
        XCTAssertEqual(failures.first?.customMessage, "The page stopped unexpectedly. Please try again.")
        XCTAssertEqual(failures.first?.code, "STANDALONE_3DS_WEBVIEW_FAILED")
        XCTAssertTrue(coordinator.hasEnded)
    }

    func testContentProcessTerminated_prefersChargeIdFromEvents() {
        let coordinator = makeCoordinator()
        coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "event-charge-id", "status": "pending"])

        coordinator.webViewWebContentProcessDidTerminate(WKWebView())

        XCTAssertEqual(failures.last?.charge3dsId, "event-charge-id")
        XCTAssertEqual(failures.last?.inBackground, false)
    }

    // MARK: - Client SDK script load failure

    func testClientSdkLoadFailed_endsSessionOnceWithHost() {
        let coordinator = makeCoordinator()

        coordinator.handleMessage(["event": "clientSdkLoadFailed"])
        coordinator.handleMessage(["event": "clientSdkLoadFailed"])

        XCTAssertEqual(failures.count, 1)
        let error = webViewError(failures.first)
        XCTAssertEqual(error?.domain, Standalone3DSError.errorDomain)
        XCTAssertEqual(error?.code, Standalone3DSError.ErrorCode.clientSdkLoadFailed.rawValue)
        XCTAssertEqual(failures.first?.failingHost, "widget.paydock.com")
        XCTAssertEqual(failures.first?.charge3dsId, "token-charge-id")
        XCTAssertEqual(failures.first?.inBackground, false)
        XCTAssertTrue(coordinator.hasEnded)
    }

    func testHtml_reportsClientSdkLoadFailure() {
        MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: .sandbox))

        let html = Standalone3DSWidget.html("token")

        XCTAssertTrue(html.contains("onerror=\"onClientSdkLoadFailed()\""))
        XCTAssertTrue(html.contains("event: \"clientSdkLoadFailed\""))
        XCTAssertTrue(html.contains("/sdk/v1.150.stable/widget.umd.min.js"))
        XCTAssertTrue(html.contains("if (typeof window.paydock === \"undefined\")"))
    }

    // MARK: - Navigation failures

    func testNavigationFailure_keepsErrorAndAddsContext() {
        let coordinator = makeCoordinator()
        let url = URL(string: "https://paydock.com/sdk/path?t=secret")!
        let original = NSError(domain: NSURLErrorDomain,
                               code: NSURLErrorNotConnectedToInternet,
                               userInfo: [NSURLErrorFailingURLErrorKey: url])

        coordinator.webView(WKWebView(), didFailProvisionalNavigation: nil, withError: original)

        let error = webViewError(failures.first)
        XCTAssertEqual(error?.domain, NSURLErrorDomain)
        XCTAssertEqual(error?.code, NSURLErrorNotConnectedToInternet)
        XCTAssertEqual(failures.first?.failingHost, "paydock.com")
        XCTAssertEqual(failures.first?.charge3dsId, "token-charge-id")
        XCTAssertEqual(failures.first?.customMessage,
                       "The Internet connection appears to be offline. Please check your network.")
        XCTAssertFalse(coordinator.hasEnded)
    }

    func testNonWebViewErrors_haveNoContext() {
        XCTAssertNil(Standalone3DSError.invalidToken.charge3dsId)
        XCTAssertNil(Standalone3DSError.mappingFailed.inBackground)
        XCTAssertNil(Standalone3DSError.mappingFailed.failingHost)
    }

    // MARK: - Charge 3DS id from the token

    func testResolvedCharge3dsId_readsStandaloneTokenMeta() {
        // swiftlint:disable:next line_length
        let token = "eyJjb250ZW50IjoiZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBaQ0k2SWpZM1l6VmlNekUxTlRObE16aGlNV015WTJNMFl6YzNaQ0lzSW0xbGRHRWlPaUpsZVVwcVlVZEdlVm95Vm1aTk1sSjZXREpzYTBscWIybFphazVzVFdwbk5VMXFhM1JPUkUwMFRWTXdNRTVxWTNsTVZHaHFUV3ByZEUxSFZtMU5WMFpxVGpKT2EwNVVaek5KYVhkcFl6SldlV1J0YkdwYVZqa3daVmhDYkVscWIybFNNVUpvWlZjeGJHSnVVbnBKYVhkcFdsaG9NRnBZU25WWlYzaG1ZVmRSYVU5cFNUUk9la0pyVFVSVmVVOVRNSGxhYW1OM1RGUlNhRmxYUlhSUFIwa3lUV2t3TlU5SFZtMU9iVlpzVGtSQk1FNUVRV2xNUTBwd1ltMXNNR0ZYUm5OaFdIQm9aRWRzZG1Kc09URmpiWGRwVDJsS2IyUklVbmRqZW05MlRETkNhR1ZYVW5aWk1uTjBaRWRXZW1SRE5XaGpla1YxV2pOQ2FHVlhNV3hpYmxKNlRHMDFiR1JET1doalIydDJaR3BKZGxsdVNqTk1NazVvWWtkNGFWbFhUbkpRTTFKNVdWYzFlbE5YVVRsUFJHTjNXa1JCTVUxcWEzUk5iVmt6VFVNd01GbFhSbWhNVkdocFRtcEpkRTlVYUd4YWFscHNXbFJSZDA1RVVYZEtibEU1WTBWU1EwNVlTWGxQVjJoQ1RUSTVOVkpyYkUxa1ZWRjVaSHBrZUdReVNsZGFXR2hYVkRGR1UwNXJWbEpVYlRGMVlVZHdWMXBJUmtoYVJsVjRWMnN3TkU1R1pIaE5NWEJzV1RKNFJWZEhUalJqYkVaeVdtNUNZVmt6UW1GU1NFcG9TV2wzYVZsWVZqQmhSemw1WVZod2FHUkhiSFppYkRreFkyMTNhVTlwU205a1NGSjNZM3B2ZGt3elFtaGxWMUoyV1RKemRHUkhWbnBrUXpWb1kwZHJkVmxZVFhoTWJXUjNXVmhzZEZwWE5UQmplVFYxV2xoUmRsbFlRbkJNTTFsNVRESkdNV1JIWjNaWmJrb3pVRE5ST1UxNlRUSlphbFY2V1RKWk1rNUVRVEJhVkdoc1dsUnJlbGx0VFRGYWJWazBUbTFaZUZsVVNYaE9WR3R0WTBReFlWWkhZM2RVYkdSaFlXeHNkRlpZWkZCU1JrVjZWR3BLUjJKR2NGaFhiWFJhWWxac05sUlhNVnBOVlRsWVUyMTBUbFpHYXpGWGJURktaV3hzY1ZaVVNscFdSa1Y0VkcxamFVeERTbnBhVjA1MlltMVNhR051Ykdaa1dFcHpTV3B2YVdGSVVqQmpTRTAyVEhrNWQxbFliR3RpTWs1eVRGaFNiR016VVhWWldFMTRURzFrZDFsWWJIUmFWelV3WTNrMWRWcFlVWFpaV0VKd1RETlplVXd5U25sa2VUbHdZbTFzTUV3eU1YWmlhamt3VUZSbk0wMUhVWGRPVkVrMVRGUktiVTU2UVhST1IwWm9XVk13TkZscVdYbE1WR3MwV2xkWk1scFhWVEJOUkZFd1RVTktPU0lzSW1saGRDSTZNVGMwTVRBd09UWTROU3dpWlhod0lqb3hOelF4TURrMk1EZzFmUS5kMXRxSFQ0VjBTQ2JDOUdKLTBpSEpBSTdXT3ZLd2lza09HaWVaNkN5MVJjIiwiZm9ybWF0Ijoic3RhbmRhbG9uZV8zZHMifQ=="

        let decoded = Base64Decoder().decodeBase64(token, to: Decoded3DSToken.self)

        XCTAssertNil(decoded?.charge3dsId)
        XCTAssertEqual(decoded?.resolvedCharge3dsId, "b3e28929-4381-4672-8c29-0ef1ac7cd587")
    }
}
