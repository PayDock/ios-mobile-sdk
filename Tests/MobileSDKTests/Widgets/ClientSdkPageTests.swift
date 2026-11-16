//
//  ClientSdkPageTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

/// The load guard every Client SDK page carries, its handling in each widget, and the loaded-version read.
@MainActor
final class ClientSdkPageTests: XCTestCase {

    override func setUp() {
        super.setUp()
        MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: .sandbox))
    }

    // MARK: - Page

    func testScripts_guardThenScriptTagThenGatedInlineScript() throws {
        let page = ClientSdkPage.scripts(clientSdkUrl: "https://cdn/x.js", inlineScript: "widget.load();")

        let guardFunction = try XCTUnwrap(page.range(of: "function onClientSdkLoadFailed()"))
        let scriptTag = try XCTUnwrap(page.range(of: "<script src=\"https://cdn/x.js\" onerror=\"onClientSdkLoadFailed()\">"))
        let globalCheck = try XCTUnwrap(page.range(of: "if (typeof window.paydock === \"undefined\")"))
        let inline = try XCTUnwrap(page.range(of: "widget.load();"))

        XCTAssertLessThan(guardFunction.lowerBound, scriptTag.lowerBound)
        XCTAssertLessThan(scriptTag.lowerBound, globalCheck.lowerBound)
        XCTAssertLessThan(globalCheck.lowerBound, inline.lowerBound)
        XCTAssertTrue(page.contains("} else {"))
        XCTAssertTrue(page.contains("clientSdkLoadFailedReported"))
    }

    func testEveryWidgetPageIsGuarded() {
        let clickToPay = ClickToPayWidget(config: ClickToPayWidgetConfig(serviceId: "s", accessToken: "a", meta: nil),
                                          completion: { _ in })
            .html(serviceId: "s", accessToken: "a", meta: nil)
        let pages = [clickToPay, MPGS3DSWidget.html("token"), Standalone3DSWidget.html("token")]

        for page in pages {
            XCTAssertTrue(page.contains("onerror=\"onClientSdkLoadFailed()\""))
            XCTAssertTrue(page.contains("if (typeof window.paydock === \"undefined\")"))
            XCTAssertTrue(page.contains("/sdk/v1.150.stable/widget.umd.min.js"))
            XCTAssertEqual(page.components(separatedBy: "<script src=").count - 1, 1)
        }
    }

    func testIsLoadFailed() {
        XCTAssertTrue(ClientSdkPage.isLoadFailed(["event": "clientSdkLoadFailed"]))
        XCTAssertFalse(ClientSdkPage.isLoadFailed(["event": "checkoutReady"]))
        XCTAssertFalse(ClientSdkPage.isLoadFailed("clientSdkLoadFailed"))
    }

    // MARK: - Widgets

    func testClickToPay_loadFailedEndsOnceWithWebViewFailed() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) },
                                                       clientSdkHost: "widget.paydock.com")

        coordinator.handleMessage(["event": "clientSdkLoadFailed"])
        coordinator.handleMessage(["event": "clientSdkLoadFailed"])

        XCTAssertEqual(results.count, 1)
        guard case .failure(.webViewFailed(let error))? = results.first else {
            return XCTFail("expected webViewFailed, got \(String(describing: results.first))")
        }
        XCTAssertEqual(error.domain, ClientSdkPage.errorDomain)
        XCTAssertEqual(error.code, ClientSdkPage.loadFailedCode)
        XCTAssertEqual(error.userInfo["PaydockClientSdkHost"] as? String, "widget.paydock.com")
    }

    func testMPGS3DS_loadFailedEndsOnceWithWebViewFailed() {
        var results: [Result<MPGS3dsResult, MPGS3dsError>] = []
        let coordinator = MPGS3DSWidget.Coordinator(completion: { results.append($0) },
                                                    clientSdkHost: "widget.paydock.com")

        coordinator.handleMessage(["event": "clientSdkLoadFailed"])
        coordinator.handleMessage(["event": "clientSdkLoadFailed"])

        XCTAssertEqual(results.count, 1)
        guard case .failure(.webViewFailed(let error))? = results.first else {
            return XCTFail("expected webViewFailed, got \(String(describing: results.first))")
        }
        XCTAssertEqual(error.domain, ClientSdkPage.errorDomain)
    }

    func testClickToPay_otherEventsStillMapAsBefore() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "unknown"])

        guard case .success(let result)? = results.first else { return XCTFail("expected success") }
        XCTAssertEqual(result.event, .checkoutError)
    }

    // MARK: - Loaded version

    func testParse_keepsOnlyNonEmptyStrings() {
        XCTAssertEqual(ClientSdkVersionReader.parse("v1.150.2"), "v1.150.2")
        XCTAssertNil(ClientSdkVersionReader.parse(""))
        XCTAssertNil(ClientSdkVersionReader.parse(nil))
        XCTAssertNil(ClientSdkVersionReader.parse(NSNull()))
        XCTAssertNil(ClientSdkVersionReader.parse(1150))
    }

    func testRecord_nilKeepsTheLastVersion() {
        MobileSDK.shared.recordLoadedClientSdkVersion("v1.150.2")
        MobileSDK.shared.recordLoadedClientSdkVersion(nil)

        XCTAssertEqual(MobileSDK.shared.loadedClientSdkVersion, "v1.150.2")
    }
}
