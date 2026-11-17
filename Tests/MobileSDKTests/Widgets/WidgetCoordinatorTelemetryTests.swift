//
//  WidgetCoordinatorTelemetryTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import WebKit
@testable import MobileSDK

/// R_05, R_06 for the UIKit-backed widgets (Click to Pay, MPGS 3DS, Standalone 3DS): a failure reports one SDK error
/// and is delivered as before; a swallowed one is reported under its code and still delivers what it did.
@MainActor
final class WidgetCoordinatorTelemetryTests: XCTestCase {

    private let telemetry = RecordingTelemetry()

    override func setUp() {
        super.setUp()
        telemetry.bindAsCurrent()
    }

    override func tearDown() {
        RecordingTelemetry.unbind()
        super.tearDown()
    }

    // MARK: - Click to Pay

    func testClickToPay_UnreadableMessage_ReportsItsCode_AndDeliversSuccessAsBefore() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "unknown"])

        guard case .success(let result)? = results.first else { return XCTFail("expected success") }
        XCTAssertEqual(result.event, .checkoutError)
        XCTAssertEqual(result.mastercardToken, "")
        XCTAssertEqual(telemetry.sdkErrors, [.reported("CLICK_TO_PAY_MESSAGE_UNREADABLE", .clickToPay)])
    }

    func testClickToPay_TokenMissing_ReportsItsCode_AndDeliversNothing() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "checkoutCompleted", "data": ["data": [:] as [String: Any]]])

        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(telemetry.sdkErrors, [.reported("CLICK_TO_PAY_TOKEN_MISSING", .clickToPay)])
    }

    func testClickToPay_CheckoutReadyWithoutData_ReportsNothing_AndDeliversNothing() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "checkoutReady"])
        coordinator.handleMessage(["event": "checkoutReady", "data": NSNull()])

        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(telemetry.sdkErrors.isEmpty)
    }

    func testClickToPay_CriticalCheckoutError_ReportsItsOwnCode_WithoutItsText_AndDeliversNothing() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) })
        let text = TelemetrySensitiveText.text

        coordinator.handleMessage(["event": "checkoutError", "data": ["type": "CriticalError", "data": text]])

        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(telemetry.sdkErrors, [.reported("CLICK_TO_PAY_CHECKOUT_ERROR", .clickToPay)])
        for forbidden in TelemetrySensitiveText.forbidden {
            XCTAssertFalse(String(describing: telemetry.events).contains(forbidden))
        }
    }

    func testClickToPay_UserCheckoutError_ReportsNothing_AndDeliversNothing() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "checkoutError", "data": ["type": "UserError", "data": "wrong code"]])

        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(telemetry.sdkErrors.isEmpty)
    }

    func testClickToPay_LoadFailed_ReportsOnce_AndDeliversAsBefore() {
        var results: [Result<ClickToPayResult, ClickToPayError>] = []
        let coordinator = ClickToPayWidget.Coordinator(completion: { results.append($0) },
                                                       clientSdkHost: "widget.paydock.com")

        coordinator.handleMessage(["event": "clientSdkLoadFailed"])
        coordinator.handleMessage(["event": "clientSdkLoadFailed"])

        XCTAssertEqual(results.count, 1)
        guard case .failure(.webViewFailed)? = results.first else { return XCTFail("expected webViewFailed") }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("CLICK_TO_PAY_WEBVIEW_FAILED", .clickToPay)])
    }

    // MARK: - 3DS invalid token (re-created on every redraw)

    func testMPGS3DS_InvalidToken_RecreatedOnRedraw_DeliversEachTime_AndReportsOnce() {
        var results: [Result<MPGS3dsResult, MPGS3dsError>] = []
        let token = "invalid-\(UUID().uuidString)"

        for _ in 0..<3 {
            _ = MPGS3DSWidget(config: ThreeDSConfig(token: token)) { results.append($0) }
        }

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(telemetry.sdkErrors, [.reported("MPGS_3DS_INVALID_TOKEN", .mpgs3ds)])
    }

    func testStandalone3DS_InvalidToken_RecreatedOnRedraw_DeliversEachTime_AndReportsOnce() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let token = "invalid-\(UUID().uuidString)"

        for _ in 0..<3 {
            _ = Standalone3DSWidget(config: ThreeDSConfig(token: token)) { results.append($0) }
        }

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(telemetry.sdkErrors, [.reported("STANDALONE_3DS_INVALID_TOKEN", .standalone3ds)])
    }

    func test3DS_InvalidToken_Inactive_ClaimsNothing_SoALaterActiveReportStillGoesOut() {
        let token = "invalid-\(UUID().uuidString)"
        RecordingTelemetry.unbind()
        _ = MPGS3DSWidget(config: ThreeDSConfig(token: token)) { _ in }

        telemetry.bindAsCurrent()
        _ = MPGS3DSWidget(config: ThreeDSConfig(token: token)) { _ in }

        XCTAssertEqual(telemetry.sdkErrors, [.reported("MPGS_3DS_INVALID_TOKEN", .mpgs3ds)])
    }

    // MARK: - MPGS 3DS

    func testMPGS3DS_MappingFailed_ReportsOneSdkError_AndDeliversAsBefore() {
        var results: [Result<MPGS3dsResult, MPGS3dsError>] = []
        let coordinator = MPGS3DSWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "chargeAuthSuccess"])

        guard case .failure(.mappingFailed)? = results.first else { return XCTFail("expected mappingFailed") }
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(telemetry.sdkErrors, [.reported("MPGS_3DS_RESPONSE_MAPPING_FAILED", .mpgs3ds)])
    }

    func testMPGS3DS_Success_ReportsNothing() {
        var results: [Result<MPGS3dsResult, MPGS3dsError>] = []
        let coordinator = MPGS3DSWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_1"])

        guard case .success? = results.first else { return XCTFail("expected success") }
        XCTAssertEqual(telemetry.reports, [])
    }

    // MARK: - Standalone 3DS

    func testStandalone3DS_MappingFailed_ReportsOneSdkError_AndDeliversAsBefore() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = Standalone3DSWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["no-event": true])

        guard case .failure(.mappingFailed)? = results.first else { return XCTFail("expected mappingFailed") }
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(telemetry.sdkErrors, [.reported("STANDALONE_3DS_RESPONSE_MAPPING_FAILED", .standalone3ds)])
    }

    func testStandalone3DS_EndedSession_ReportsOncePerDeliveredFailure() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = Standalone3DSWidget.Coordinator(completion: { results.append($0) },
                                                          isAppInBackground: { false })

        coordinator.webViewWebContentProcessDidTerminate(WKWebView())
        coordinator.webViewWebContentProcessDidTerminate(WKWebView())

        XCTAssertEqual(results.count, 1)
        guard case .failure(.webViewFailed)? = results.first else { return XCTFail("expected webViewFailed") }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("STANDALONE_3DS_WEBVIEW_FAILED", .standalone3ds)])
    }

    func testStandalone3DS_UnknownEvent_ReportsNothing() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = Standalone3DSWidget.Coordinator(completion: { results.append($0) })

        coordinator.handleMessage(["event": "somethingNew"])

        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(telemetry.reports, [])
    }
}
