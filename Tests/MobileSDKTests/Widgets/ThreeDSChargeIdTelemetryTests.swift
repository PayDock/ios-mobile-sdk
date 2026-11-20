//
//  ThreeDSChargeIdTelemetryTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import SwiftUI
import WebKit
@testable import MobileSDK
import PaydockTelemetry

/// D25 for the standalone and MPGS 3DS widgets: the start and the finish carry the token's charge ID, or else the first
/// message's; absent when neither is known (R_02). Only the standalone success and declined finishes carry the
/// authentication flow (R_03). While telemetry is inactive the charge ID is never read (R_07).
@MainActor
final class ThreeDSChargeIdTelemetryTests: XCTestCase {

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

    /// Drains the main run loop once the class is done, as `ThreeDSPaymentTests` does, so the web views these tests
    /// create leave no main-thread work for the next suites.
    override static func tearDown() {
        RunLoop.main.run(until: Date().addingTimeInterval(2.0))
        super.tearDown()
    }

    // MARK: - Standalone 3DS: the charge ID (R_02)

    /// A coordinator whose attempt is started as `makeUIView` starts it, with the token's charge ID.
    private func standalone(
        tokenId: String?,
        _ completion: @escaping (Result<Standalone3DSResult, Standalone3DSError>) -> Void = { _ in }
    ) -> Standalone3DSWidget.Coordinator {
        let coordinator = Standalone3DSWidget.Coordinator(completion: completion, charge3dsId: tokenId,
                                                          isAppInBackground: { false })
        coordinator.payment = SdkTelemetry.startPayment(.standalone3ds, charge3dsId: coordinator.tokenCharge3dsId)
        return coordinator
    }

    func testStandalone_TokenWithAnId_StartAndFinishCarryIt_ALaterMessageIdChangesNothing() {
        let coordinator = standalone(tokenId: "id_token")

        coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_other"])
        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_other"])

        XCTAssertEqual(telemetry.charge3dsIds, ["id_token", "id_token"])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testStandalone_TokenWithoutAnId_StartHasNone_TheFirstMessageIdIsOnTheFinish() {
        let coordinator = standalone(tokenId: nil)

        coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_a"])
        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_b"])

        XCTAssertEqual(telemetry.charge3dsIds, [nil, "id_a"])
    }

    func testStandalone_AnEmptyMessageId_IsNotNoted() {
        let coordinator = standalone(tokenId: "")

        coordinator.handleMessage(["event": "chargeAuthInfo", "charge3dsId": ""])
        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_a"])

        XCTAssertEqual(telemetry.charge3dsIds, [nil, "id_a"])
    }

    func testStandalone_NeitherId_IsAbsentOnBoth_OnASuccessAndOnAMappingFailure() {
        let success = standalone(tokenId: nil)
        success.handleMessage(["event": "chargeAuthInfo"])
        success.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": ""])
        standalone(tokenId: nil).handleMessage(["no-event": true])

        XCTAssertEqual(telemetry.charge3dsIds, [nil, nil, nil, nil])
        XCTAssertEqual(telemetry.finishes.map(\.outcome), [.success, .error])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testStandalone_ChargeError_CarriesTheChargeId() {
        standalone(tokenId: "id_token").handleMessage(["event": "error"])
        let noted = standalone(tokenId: nil)
        noted.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_a"])
        noted.handleMessage(["event": "error"])

        XCTAssertEqual(telemetry.payments.filter(\.isFinish), Array(repeating: .finished(.standalone3ds, .error, "CHARGE_ERROR"),
                                                                    count: 2))
        XCTAssertEqual(telemetry.finishes.map(\.charge3dsId), ["id_token", "id_a"])
    }

    func testStandalone_AWebViewFailure_CarriesTheChargeId() {
        standalone(tokenId: "id_token").webView(WKWebView(), didFail: nil, withError: timedOut)

        XCTAssertEqual(telemetry.finishes.map(\.charge3dsId), ["id_token"])
    }

    func testStandalone_ValidToken_MakeUIViewStartsWithTheTokensId() throws {
        let token = try Self.token(format: .standalone3ds, charge3dsId: "id_token")
        let window = host(Standalone3DSWidget(config: ThreeDSConfig(token: token)) { _ in })
        defer { window.isHidden = true }

        XCTAssertTrue(telemetry.events.contains(.widgetOpened(widget: "Standalone3DSWidget")), "makeUIView did not run")
        XCTAssertEqual(telemetry.charge3dsIds.first, "id_token")
    }

    // MARK: - Standalone 3DS: the flow (R_03)

    func testStandalone_ChallengeThenSuccess_GivesChallenge() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = standalone(tokenId: "id_1") { results.append($0) }

        coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_1"])

        XCTAssertEqual(telemetry.finishes.map(\.flow), [.challenge])
        assertFinishFlowEqualsTheDeliveredResults(results)
    }

    func testStandalone_SuccessAlone_GivesFrictionless() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        standalone(tokenId: "id_1") { results.append($0) }.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_1"])

        XCTAssertEqual(telemetry.finishes.map(\.flow), [.frictionless])
        assertFinishFlowEqualsTheDeliveredResults(results)
    }

    func testStandalone_DecoupledThenReject_GivesDecoupled() {
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        let coordinator = standalone(tokenId: "id_1") { results.append($0) }

        coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "id_1"])
        coordinator.handleMessage(["event": "chargeAuthReject", "charge3dsId": "id_1"])

        XCTAssertEqual(telemetry.finishes.map(\.outcome), [.declined])
        XCTAssertEqual(telemetry.finishes.map(\.flow), [.decoupled])
        assertFinishFlowEqualsTheDeliveredResults(results)
    }

    func testStandalone_ChallengeThenAnErrorFinish_HasNoFlow() {
        let chargeError = standalone(tokenId: "id_1")
        chargeError.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_1"])
        chargeError.handleMessage(["event": "error", "charge3dsId": "id_1"])
        let mappingFailure = standalone(tokenId: "id_1")
        mappingFailure.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_1"])
        mappingFailure.handleMessage(["event": "chargeAuthSuccess"])

        XCTAssertEqual(telemetry.finishes.map(\.outcome), [.error, .error])
        XCTAssertEqual(telemetry.finishes.map(\.flow), [nil, nil])
        XCTAssertEqual(telemetry.finishes.map(\.charge3dsId), ["id_1", "id_1"])
    }

    // MARK: - MPGS 3DS (R_02, R_03)

    /// A coordinator whose attempt is started with `tokenId`, the ID `makeUIView` decodes from the token.
    private func mpgs(tokenId: String?,
                      _ completion: @escaping (Result<MPGS3dsResult, MPGS3dsError>) -> Void = { _ in }) -> MPGS3DSWidget.Coordinator {
        let coordinator = MPGS3DSWidget.Coordinator(completion: completion)
        coordinator.payment = SdkTelemetry.startPayment(.mpgs3ds, charge3dsId: tokenId)
        return coordinator
    }

    func testMPGS_TokenWithAnId_StartAndFinishCarryIt_ALaterMessageIdChangesNothing() {
        let coordinator = mpgs(tokenId: "id_token")

        coordinator.handleMessage(["event": "chargeAuth", "charge3dsId": "id_other"])
        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_other"])

        XCTAssertEqual(telemetry.charge3dsIds, ["id_token", "id_token"])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testMPGS_TokenWithoutAnId_StartHasNone_TheFirstMessageIdIsOnTheFinish() {
        let coordinator = mpgs(tokenId: nil)

        coordinator.handleMessage(["event": "chargeAuth", "charge3dsId": "id_a"])
        coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_b"])

        XCTAssertEqual(telemetry.charge3dsIds, [nil, "id_a"])
    }

    func testMPGS_AMessageThatFailsTheMapping_StillNotesItsId() {
        mpgs(tokenId: nil).handleMessage(["event": "somethingNew", "charge3dsId": "id_a"])

        XCTAssertEqual(telemetry.charge3dsIds, [nil, "id_a"])
        XCTAssertEqual(telemetry.payments.last, .finished(.mpgs3ds, .error, "MPGS_3DS_RESPONSE_MAPPING_FAILED"))
    }

    func testMPGS_NeitherId_IsAbsentOnBoth_OnASuccessAndOnAMappingFailure() {
        mpgs(tokenId: nil).handleMessage(["event": "chargeAuthSuccess", "charge3dsId": ""])
        mpgs(tokenId: nil).handleMessage(["event": "somethingNew"])

        XCTAssertEqual(telemetry.charge3dsIds, [nil, nil, nil, nil])
        XCTAssertEqual(telemetry.finishes.map(\.outcome), [.success, .error])
    }

    func testMPGS_CancelledAndAWebViewFailure_CarryTheChargeId() {
        mpgs(tokenId: "id_token").handleMessage(["event": "chargeAuthCancelled", "charge3dsId": "id_token"])
        let noted = mpgs(tokenId: nil)
        noted.handleMessage(["event": "chargeAuth", "charge3dsId": "id_a"])
        noted.webView(WKWebView(), didFail: nil, withError: timedOut)

        XCTAssertEqual(telemetry.finishes.map(\.outcome), [.cancelled, .error])
        XCTAssertEqual(telemetry.finishes.map(\.charge3dsId), ["id_token", "id_a"])
    }

    func testMPGS_FinishesNeverCarryAFlow() {
        for event in ["chargeAuthSuccess", "chargeAuthReject", "additionalDataCollectReject", "chargeAuthCancelled", "nothing"] {
            mpgs(tokenId: "id_1").handleMessage(["event": event, "charge3dsId": "id_1"])
        }
        mpgs(tokenId: "id_1").webView(WKWebView(), didFail: nil, withError: timedOut)

        XCTAssertEqual(telemetry.finishes.count, 6)
        XCTAssertTrue(telemetry.finishes.allSatisfy { $0.flow == nil })
    }

    func testMPGS_ValidToken_MakeUIViewStartsWithTheTokensId() throws {
        let token = try Self.token(format: .html, charge3dsId: "id_token")
        let window = host(MPGS3DSWidget(config: ThreeDSConfig(token: token)) { _ in })
        defer { window.isHidden = true }

        XCTAssertTrue(telemetry.events.contains(.widgetOpened(widget: "MPGS3dsWidget")), "makeUIView did not run")
        XCTAssertEqual(telemetry.charge3dsIds.first, "id_token")
    }

    func testMPGS_ValidTokenWithoutAnId_MakeUIViewStartsWithNone() throws {
        let token = try Self.token(format: .html, charge3dsId: nil)
        let window = host(MPGS3DSWidget(config: ThreeDSConfig(token: token)) { _ in })
        defer { window.isHidden = true }

        XCTAssertTrue(telemetry.events.contains(.widgetOpened(widget: "MPGS3dsWidget")), "makeUIView did not run")
        XCTAssertEqual(telemetry.charge3dsIds.first, .some(nil))
    }

    // MARK: - Inactive (R_07)

    func testInactive_StartPayment_ReturnsNil_AndNeverReadsTheChargeId() {
        let inactive = RecordingTelemetry(isActive: false)
        var reads = 0
        func chargeId() -> String? {
            reads += 1
            return "id_1"
        }

        XCTAssertNil(SdkTelemetry.startPayment(.standalone3ds, charge3dsId: chargeId(), telemetry: inactive))
        XCTAssertNil(SdkTelemetry.startPayment(.mpgs3ds, charge3dsId: chargeId(), telemetry: inactive))
        XCTAssertEqual(reads, 0)
        XCTAssertEqual(inactive.events, [])

        _ = SdkTelemetry.startPayment(.payPal, charge3dsId: chargeId(), telemetry: telemetry)
        XCTAssertEqual(reads, 0, "a widget other than the two 3DS widgets never reads it")
        _ = SdkTelemetry.startPayment(.mpgs3ds, charge3dsId: chargeId(), telemetry: telemetry)
        XCTAssertEqual(reads, 1)
    }

    // MARK: - Helpers

    private func assertFinishFlowEqualsTheDeliveredResults(_ results: [Result<Standalone3DSResult, Standalone3DSError>],
                                                           file: StaticString = #filePath, line: UInt = #line) {
        guard case let .success(last)? = results.last else {
            return XCTFail("expected a delivered result", file: file, line: line)
        }
        XCTAssertEqual(telemetry.finishes.last?.flow?.rawValue, last.authenticationFlow?.rawValue, file: file, line: line)
        XCTAssertNotNil(last.authenticationFlow, file: file, line: line)
    }

    /// Shows `view` in a window and lays it out, so SwiftUI runs `makeUIView`.
    private func host<V: View>(_ view: V) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = UIHostingController(rootView: view)
        window.isHidden = false
        window.layoutIfNeeded()
        window.rootViewController?.view.layoutIfNeeded()
        return window
    }

    /// A base64 token of `format` with `charge3dsId`, as the 3DS widgets decode it.
    private static func token(format: Decoded3DSToken.ThreeDsFormat, charge3dsId: String?) throws -> String {
        let decoded = Decoded3DSToken(content: "<div></div>", format: format, charge3dsId: charge3dsId)
        return try JSONEncoder().encode(decoded).base64EncodedString()
    }
}

/// The D25 values of the payment events a `RecordingTelemetry` received.
private extension RecordingTelemetry {
    struct Finish: Equatable {
        let outcome: TelemetryEvent.PaymentOutcome
        let charge3dsId: String?
        let flow: TelemetryEvent.ThreeDSFlow?
    }

    /// The charge ID of every start and finish, in order.
    var charge3dsIds: [String?] {
        events.compactMap { event -> String?? in
            switch event {
            case let .paymentStarted(_, _, charge3dsId):
                return .some(charge3dsId)
            case let .paymentFinished(_, _, _, _, _, charge3dsId, _):
                return .some(charge3dsId)
            default:
                return nil
            }
        }
    }

    /// Every finish, in order.
    var finishes: [Finish] {
        events.compactMap { event in
            guard case let .paymentFinished(_, _, outcome, _, _, charge3dsId, flow) = event else {
                return nil
            }
            return Finish(outcome: outcome, charge3dsId: charge3dsId, flow: flow)
        }
    }
}

private extension RecordingTelemetry.PaymentReport {
    var isFinish: Bool {
        if case .finished = self {
            return true
        }
        return false
    }
}
