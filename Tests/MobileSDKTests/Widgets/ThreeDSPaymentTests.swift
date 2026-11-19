//
//  ThreeDSPaymentTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import SwiftUI
import WebKit
@testable import MobileSDK
import PaydockTelemetry

/// D24 for the standalone and MPGS 3DS widgets: the attempt `makeUIView` starts is finished once by the flow's final
/// event or failure, an intermediate event finishes nothing, and an invalid token is one failed attempt per token.
@MainActor
final class ThreeDSPaymentTests: XCTestCase {

    private let telemetry = RecordingTelemetry()
    private let timedOut = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)

    override func setUp() {
        super.setUp()
        // `makeUIView` and `makeCoordinator` read the configured environment.
        MobileSDK.shared.configureMobileSDK(config: .init(environment: .sandbox))
        telemetry.bindAsCurrent()
    }

    override func tearDown() {
        RecordingTelemetry.unbind()
        super.tearDown()
    }

    /// Drains the main run loop once the class is done: the web views these tests create (the delegate calls' and the
    /// hosted widgets') leave main-thread work behind, which otherwise runs during the next suites and delays tests
    /// that wait a fixed time (ZipVMTests' 100 ms checkout waits).
    override static func tearDown() {
        RunLoop.main.run(until: Date().addingTimeInterval(2.0))
        super.tearDown()
    }

    // MARK: - Standalone 3DS

    private func standaloneWithAttempt(
        _ completion: @escaping (Result<Standalone3DSResult, Standalone3DSError>) -> Void = { _ in }
    ) -> Standalone3DSWidget.Coordinator {
        let coordinator = Standalone3DSWidget.Coordinator(completion: completion, isAppInBackground: { false })
        coordinator.payment = SdkTelemetry.startPayment(.standalone3ds)
        return coordinator
    }

    func testStandalone_EachFinalEvent_FinishesWithItsOutcome() {
        struct Case {
            let message: [String: Any]
            let outcome: TelemetryOutcome
            let code: String?
        }
        let cases = [
            Case(message: ["event": "chargeAuthSuccess", "charge3dsId": "id_1"], outcome: .success, code: nil),
            Case(message: ["event": "chargeAuthReject", "charge3dsId": "id_1"], outcome: .declined, code: nil),
            Case(message: ["event": "error"], outcome: .error, code: "CHARGE_ERROR")
        ]

        for testCase in cases {
            standaloneWithAttempt().handleMessage(testCase.message)
        }

        XCTAssertEqual(telemetry.payments, cases.flatMap {
            [.started(.standalone3ds), .finished(.standalone3ds, $0.outcome, $0.code)]
        })
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testStandalone_ChargeError_FinishesAsAnErrorWithCodeChargeError_AndDeliversAsBefore() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = standaloneWithAttempt { results.append($0) }

        coordinator.handleMessage(["event": "error", "charge3dsId": "id_1"])

        guard case .success(let result)? = results.first else { return XCTFail("expected success") }
        XCTAssertEqual(result.event, .chargeError)
        XCTAssertEqual(telemetry.payments.last, .finished(.standalone3ds, .error, "CHARGE_ERROR"))
        XCTAssertEqual(telemetry.sdkErrors, [])
        XCTAssertNil(coordinator.payment)
    }

    func testStandalone_IntermediateEvents_FinishNothing_UntilTheFinalOne() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = standaloneWithAttempt { results.append($0) }

        coordinator.handleMessage(["event": "chargeAuthInfo"])
        coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "chargeAuthChallengeLoaded"])
        coordinator.handleMessage(["event": "chargeAuthChallengeCompleted"])
        coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "id_1"])
        XCTAssertEqual(telemetry.payments, [.started(.standalone3ds)])
        XCTAssertNotNil(coordinator.payment)

        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_1"])

        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(telemetry.payments, [.started(.standalone3ds), .finished(.standalone3ds, .success, nil)])
    }

    func testStandalone_MappingFailures_FinishAsAnErrorWithItsCode() {
        standaloneWithAttempt().handleMessage(["no-event": true])
        standaloneWithAttempt().handleMessage(["event": "chargeAuthSuccess"])

        let finish = RecordingTelemetry.PaymentReport.finished(.standalone3ds, .error, "STANDALONE_3DS_RESPONSE_MAPPING_FAILED")
        XCTAssertEqual(telemetry.payments, [.started(.standalone3ds), finish, .started(.standalone3ds), finish])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testStandalone_WebViewFailures_FinishAsAnErrorWithItsCode() {
        standaloneWithAttempt().webView(WKWebView(), didFail: nil, withError: timedOut)
        standaloneWithAttempt().webView(WKWebView(), didFailProvisionalNavigation: nil, withError: timedOut)
        standaloneWithAttempt().webViewWebContentProcessDidTerminate(WKWebView())
        standaloneWithAttempt().handleMessage(["event": "clientSdkLoadFailed"])

        let finish = RecordingTelemetry.PaymentReport.finished(.standalone3ds, .error, "STANDALONE_3DS_WEBVIEW_FAILED")
        XCTAssertEqual(telemetry.payments, Array(repeating: [.started(.standalone3ds), finish], count: 4).flatMap { $0 })
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testStandalone_ALaterEndAfterAFinish_ReportsNothing() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = standaloneWithAttempt { results.append($0) }

        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "chargeAuthReject", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "error"])
        coordinator.webView(WKWebView(), didFail: nil, withError: timedOut)

        XCTAssertEqual(results.count, 4, "the merchant receives every event as before")
        XCTAssertEqual(telemetry.payments, [.started(.standalone3ds), .finished(.standalone3ds, .success, nil)])
    }

    func testStandalone_NoAttempt_FinishesNothing() {
        let coordinator = Standalone3DSWidget.Coordinator(completion: { _ in })

        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_1"])

        XCTAssertEqual(telemetry.payments, [])
    }

    func testStandalone_InvalidToken_OverTwoInits_IsOneFailedAttempt_AndMakeUIViewStartsNone() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let token = "invalid-\(UUID().uuidString)"

        _ = Standalone3DSWidget(config: ThreeDSConfig(token: token)) { results.append($0) }
        let widget = Standalone3DSWidget(config: ThreeDSConfig(token: token)) { results.append($0) }
        let window = host(widget)
        defer { window.isHidden = true }

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(telemetry.events.contains(.widgetOpened(widget: "Standalone3DSWidget")), "makeUIView did not run")
        XCTAssertEqual(telemetry.payments, [
            .started(.standalone3ds), .finished(.standalone3ds, .error, "STANDALONE_3DS_INVALID_TOKEN")
        ])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testStandalone_ValidToken_MakeUIViewStartsOneAttempt() throws {
        let token = try Self.token(format: .standalone3ds)
        let window = host(Standalone3DSWidget(config: ThreeDSConfig(token: token)) { _ in })
        defer { window.isHidden = true }

        XCTAssertTrue(telemetry.events.contains(.widgetOpened(widget: "Standalone3DSWidget")), "makeUIView did not run")
        XCTAssertEqual(telemetry.payments.first, .started(.standalone3ds))
        XCTAssertEqual(telemetry.payments.filter { $0 == .started(.standalone3ds) }.count, 1)
    }

    // MARK: - MPGS 3DS

    private func mpgsWithAttempt(
        _ completion: @escaping (Result<MPGS3dsResult, MPGS3dsError>) -> Void = { _ in }
    ) -> MPGS3DSWidget.Coordinator {
        let coordinator = MPGS3DSWidget.Coordinator(completion: completion)
        coordinator.payment = SdkTelemetry.startPayment(.mpgs3ds)
        return coordinator
    }

    func testMPGS_EachFinalEvent_FinishesWithItsOutcome() {
        let cases: [(String, TelemetryOutcome)] = [
            ("chargeAuthSuccess", .success),
            ("chargeAuthReject", .declined),
            ("additionalDataCollectReject", .declined),
            ("chargeAuthCancelled", .cancelled)
        ]

        for (event, _) in cases {
            mpgsWithAttempt().handleMessage(["event": event, "charge3dsId": "id_1"])
        }

        XCTAssertEqual(telemetry.payments, cases.flatMap { [.started(.mpgs3ds), .finished(.mpgs3ds, $0.1, nil)] })
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testMPGS_IntermediateEvents_FinishNothing_UntilTheFinalOne() {
        var results: [Result<MPGS3dsResult, MPGS3dsError>] = []
        let coordinator = mpgsWithAttempt { results.append($0) }

        coordinator.handleMessage(["event": "chargeAuth", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "additionalDataCollectSuccess", "charge3dsId": "id_1"])
        XCTAssertEqual(telemetry.payments, [.started(.mpgs3ds)])
        XCTAssertNotNil(coordinator.payment)

        coordinator.handleMessage(["event": "chargeAuthCancelled", "charge3dsId": "id_1"])

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(telemetry.payments, [.started(.mpgs3ds), .finished(.mpgs3ds, .cancelled, nil)])
    }

    func testMPGS_MappingFailures_FinishAsAnErrorWithItsCode() {
        mpgsWithAttempt().handleMessage(["event": "chargeAuthSuccess"])
        mpgsWithAttempt().handleMessage(["event": "somethingNew", "charge3dsId": "id_1"])
        mpgsWithAttempt().handleMessage("not a dictionary")

        let finish = RecordingTelemetry.PaymentReport.finished(.mpgs3ds, .error, "MPGS_3DS_RESPONSE_MAPPING_FAILED")
        XCTAssertEqual(telemetry.payments, Array(repeating: [.started(.mpgs3ds), finish], count: 3).flatMap { $0 })
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testMPGS_WebViewFailures_FinishAsAnErrorWithItsCode() {
        mpgsWithAttempt().handleMessage(["event": "clientSdkLoadFailed"])
        mpgsWithAttempt().webView(WKWebView(), didFail: nil, withError: timedOut)
        mpgsWithAttempt().webView(WKWebView(), didFailProvisionalNavigation: nil, withError: timedOut)

        let finish = RecordingTelemetry.PaymentReport.finished(.mpgs3ds, .error, "MPGS_3DS_WEBVIEW_FAILED")
        XCTAssertEqual(telemetry.payments, Array(repeating: [.started(.mpgs3ds), finish], count: 3).flatMap { $0 })
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testMPGS_ALaterEndAfterAFinish_ReportsNothing() {
        var results: [Result<MPGS3dsResult, MPGS3dsError>] = []
        let coordinator = mpgsWithAttempt { results.append($0) }

        coordinator.handleMessage(["event": "chargeAuthReject", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "chargeAuthSuccess"])
        coordinator.webView(WKWebView(), didFailProvisionalNavigation: nil, withError: timedOut)

        XCTAssertEqual(results.count, 4, "the merchant receives every event as before")
        XCTAssertEqual(telemetry.payments, [.started(.mpgs3ds), .finished(.mpgs3ds, .declined, nil)])
    }

    func testMPGS_InvalidToken_OverTwoInits_IsOneFailedAttempt_AndMakeUIViewStartsNone() {
        var results: [Result<MPGS3dsResult, MPGS3dsError>] = []
        let token = "invalid-\(UUID().uuidString)"

        _ = MPGS3DSWidget(config: ThreeDSConfig(token: token)) { results.append($0) }
        let widget = MPGS3DSWidget(config: ThreeDSConfig(token: token)) { results.append($0) }
        let window = host(widget)
        defer { window.isHidden = true }

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(telemetry.events.contains(.widgetOpened(widget: "MPGS3dsWidget")), "makeUIView did not run")
        XCTAssertEqual(telemetry.payments, [.started(.mpgs3ds), .finished(.mpgs3ds, .error, "MPGS_3DS_INVALID_TOKEN")])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testMPGS_ValidToken_MakeUIViewStartsOneAttempt() throws {
        let token = try Self.token(format: .html)
        let window = host(MPGS3DSWidget(config: ThreeDSConfig(token: token)) { _ in })
        defer { window.isHidden = true }

        XCTAssertTrue(telemetry.events.contains(.widgetOpened(widget: "MPGS3dsWidget")), "makeUIView did not run")
        XCTAssertEqual(telemetry.payments.first, .started(.mpgs3ds))
        XCTAssertEqual(telemetry.payments.filter { $0 == .started(.mpgs3ds) }.count, 1)
    }

    // MARK: - Helpers

    private typealias TelemetryOutcome = TelemetryEvent.PaymentOutcome

    /// Shows `view` in a window and lays it out, so SwiftUI runs `makeUIView`.
    private func host<V: View>(_ view: V) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = UIHostingController(rootView: view)
        window.isHidden = false
        window.layoutIfNeeded()
        window.rootViewController?.view.layoutIfNeeded()
        return window
    }

    /// A base64 token of `format`, as the 3DS widgets decode it.
    private static func token(format: Decoded3DSToken.ThreeDsFormat) throws -> String {
        let decoded = Decoded3DSToken(content: "<div></div>", format: format, charge3dsId: "id_1")
        return try JSONEncoder().encode(decoded).base64EncodedString()
    }
}
