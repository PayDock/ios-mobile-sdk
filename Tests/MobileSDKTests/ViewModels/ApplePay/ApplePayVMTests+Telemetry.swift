//
//  ApplePayVMTests+Telemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import PassKit
@testable import MobileSDK
@testable import DataPaymentSources
@testable import NetworkingLib

/// R_05, R_06: a non-request failure reports one SDK error and is delivered as before; the request path and the
/// user's cancellation report nothing. `tearDown` rebinds the no-op.
extension ApplePayVMTests {

    func testTelemetry_PresentFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "present-fail completion")
        viewModel = makeTelemetryVM(presentSuccess: false) { result in
            self.completionResult = result
            expectation.fulfill()
        }

        viewModel.startPayment()
        await fulfillment(of: [expectation], timeout: 2.0)

        guard case .failure(.unableToPresentPaymentSheet)? = completionResult else {
            return XCTFail("expected .unableToPresentPaymentSheet")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("APPLE_PAY_PRESENT_FAILED", .applePay)])
    }

    func testTelemetry_StoredNonRequestFailure_ReportsOnceAtDelivery_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        mockPaymentSourcesService.shouldThrowUnknownError = true
        viewModel = makeTelemetryVM(presentSuccess: true) { result in self.completionResult = result }

        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")
        XCTAssertEqual(telemetry.reports, [], "a stored error is reported only when it is delivered")
        viewModel.finishAndComplete()

        guard case .failure(.unknownError(nil))? = completionResult else {
            return XCTFail("expected .unknownError(nil), got \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("APPLE_PAY_UNKNOWN", .applePay)])
    }

    func testTelemetry_RequestFailure_DeliversAsBefore_AndReportsNothing() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = ErrorRes(status: 400, error: .init(message: "boom", code: "E", details: nil),
                                                           resource: nil, errorSummary: nil)
        viewModel = makeTelemetryVM(presentSuccess: true) { result in self.completionResult = result }

        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")
        viewModel.finishAndComplete()

        guard case .failure(.errorCreatingToken)? = completionResult else {
            return XCTFail("expected .errorCreatingToken, got \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }

    func testTelemetry_UserCancellation_DeliversAsBefore_AndReportsNothing() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(presentSuccess: true) { result in self.completionResult = result }

        viewModel.startPayment()
        viewModel.finishAndComplete()

        guard case .failure(.userCanceledPayment)? = completionResult else {
            return XCTFail("expected .userCanceledPayment, got \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [])
    }

    // MARK: - Payment attempts (D24)

    func testPayment_AToken_FinishesAsASuccess_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(presentSuccess: true) { result in self.completionResult = result }

        viewModel.startPayment()
        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "visa", refToken: "")
        viewModel.finishAndComplete()

        guard case .success? = completionResult else {
            return XCTFail("expected success, got \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.payments, [.started(.applePay), .finished(.applePay, .success, nil)])
        XCTAssertTrue(telemetry.paymentsArePaired)
        XCTAssertNil(viewModel.payment)
    }

    func testPayment_ClosingTheSheet_FinishesAsCancelled() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(presentSuccess: true) { result in self.completionResult = result }

        viewModel.startPayment()
        viewModel.finishAndComplete()

        XCTAssertEqual(telemetry.payments, [.started(.applePay), .finished(.applePay, .cancelled, nil)])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testPayment_PresentFailure_FinishesAsAnError_WithItsCode() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "present-fail completion")
        viewModel = makeTelemetryVM(presentSuccess: false) { result in
            self.completionResult = result
            expectation.fulfill()
        }

        viewModel.startPayment()
        await fulfillment(of: [expectation], timeout: 2.0)

        guard case .failure(.unableToPresentPaymentSheet)? = completionResult else {
            return XCTFail("expected .unableToPresentPaymentSheet")
        }
        XCTAssertEqual(telemetry.payments, [
            .started(.applePay), .finished(.applePay, .error, "APPLE_PAY_PRESENT_FAILED")
        ])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testPayment_AFailedTokenRequestThenClose_FinishesAsAnError_WithItsCode() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(presentSuccess: true) { result in self.completionResult = result }

        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = ErrorRes(status: 400, error: .init(message: "boom", code: "E", details: nil),
                                                           resource: nil, errorSummary: nil)
        viewModel.startPayment()
        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")
        viewModel.finishAndComplete()
        guard case .failure(.errorCreatingToken)? = completionResult else { return XCTFail("expected .errorCreatingToken") }

        mockPaymentSourcesService.shouldReturnError = false
        mockPaymentSourcesService.shouldThrowUnknownError = true
        viewModel.startPayment()
        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")
        viewModel.finishAndComplete()
        guard case .failure(.unknownError(nil))? = completionResult else { return XCTFail("expected .unknownError(nil)") }

        XCTAssertEqual(telemetry.payments, [
            .started(.applePay), .finished(.applePay, .error, "APPLE_PAY_TOKEN_ERROR"),
            .started(.applePay), .finished(.applePay, .error, "APPLE_PAY_UNKNOWN")
        ])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testPayment_AFailedThenSuccessfulRequestInOneSheet_IsOneAttempt_Success() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(presentSuccess: true) { result in self.completionResult = result }

        viewModel.startPayment()
        mockPaymentSourcesService.shouldThrowUnknownError = true
        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")
        mockPaymentSourcesService.shouldThrowUnknownError = false
        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "visa", refToken: "")
        viewModel.finishAndComplete()

        guard case .success? = completionResult else {
            return XCTFail("expected success, got \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.payments, [.started(.applePay), .finished(.applePay, .success, nil)])
    }

    func testPayment_HookDeclinesTheSheet_StartsNothing() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = ApplePayVM(
            config: ApplePayWidgetConfig(serviceId: "test-service-id", accessToken: "test-widget-token",
                                         pkPaymentRequest: PKPaymentRequest()),
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            presenterFactory: TelemetryPresenterFactory(presentSuccess: true),
            onShouldPresentPaymentSheet: { false },
            completion: { result in self.completionResult = result })

        viewModel.handleButtonTap()
        let deadline = Date().addingTimeInterval(2.0)
        while viewModel.isProcessing, Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertNil(completionResult)
        XCTAssertNil(viewModel.payment)
        XCTAssertEqual(telemetry.payments, [])
    }

    private func makeTelemetryVM(presentSuccess: Bool,
                                 completion: @escaping (Result<ApplePayResult, ApplePayError>) -> Void) -> ApplePayVM {
        ApplePayVM(
            config: ApplePayWidgetConfig(serviceId: "test-service-id", accessToken: "test-widget-token",
                                         pkPaymentRequest: PKPaymentRequest()),
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            presenterFactory: TelemetryPresenterFactory(presentSuccess: presentSuccess),
            completion: completion)
    }
}

private final class TelemetryPaymentPresenter: PaymentAuthorizationPresenting {
    var delegate: PKPaymentAuthorizationControllerDelegate?
    private let presentSuccess: Bool
    init(presentSuccess: Bool) { self.presentSuccess = presentSuccess }
    func present(completion: @escaping (Bool) -> Void) { completion(presentSuccess) }
}

private struct TelemetryPresenterFactory: PaymentAuthorizationPresenterFactory {
    let presentSuccess: Bool
    func makePresenter(for request: PKPaymentRequest) -> PaymentAuthorizationPresenting {
        TelemetryPaymentPresenter(presentSuccess: presentSuccess)
    }
}
