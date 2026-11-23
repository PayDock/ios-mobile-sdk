//
//  PayPalVMTests+Payment.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataCharges
@testable import DataGateways
import PayPalWebPayments

/// D24: the button tap starts the attempt; the capture finishes it as a success, a cancellation (the checkout's, or
/// the app not active) as cancelled, and every failure path as an error with its code. In a file of its own:
/// `PayPalWebPayments` declares a `PayPalError` of its own. `tearDown` rebinds the no-op.
extension PayPalVMTests {

    /// A view model whose token request gives `tokenResult` (a token by default). With `withAttempt`, its payment
    /// attempt is open, as after `handleButtonTap()`.
    private func makePaymentVM(gatewayService: GatewayService? = nil,
                               tokenResult: Result<WalletTokenResult, WalletTokenError> = .success(.init(token: "test_token")),
                               withAttempt: Bool = true,
                               expectation: XCTestExpectation? = nil) -> PayPalVM {
        let viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in completion(tokenResult) },
            chargesService: mockChargesService,
            gatewayService: gatewayService ?? mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
                expectation?.fulfill()
            }
        )
        if withAttempt {
            viewModel.payment = SdkTelemetry.startPayment(.payPal)
        }
        return viewModel
    }

    private static let serverError = ErrorRes(status: 500, error: .init(message: "Test Error", code: "TEST", details: nil),
                                              resource: nil, errorSummary: nil)

    func testPayment_ButtonTap_StartsAnAttempt_AndAWalletTokenFailureFinishesItWithItsCode() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makePaymentVM(tokenResult: .failure(.initialisingWalletToken(reason: "Token error")),
                                  withAttempt: false, expectation: expectation)

        viewModel.handleButtonTap()
        await fulfillment(of: [expectation], timeout: 2.0)

        guard case .failure(.initialisingWalletToken) = completionResult else {
            return XCTFail("Expected initialisingWalletToken, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.payments, [.started(.payPal), .finished(.payPal, .error, "PAYPAL_WALLET_TOKEN_ERROR")])
        XCTAssertEqual(telemetry.sdkErrors, [])
        XCTAssertTrue(telemetry.paymentsArePaired)
        XCTAssertNil(viewModel.payment)
    }

    #if DEBUG
    /// Debug only: it sets the token through the debug-only `test_setToken`.
    func testPayment_Capture_FinishesAsASuccess_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "success")
        viewModel = makePaymentVM(expectation: expectation)
        viewModel.test_setToken("test_token")

        viewModel.capturePayPalPayment(paymentMethodId: "test_payment_method", payerId: "test_payer")
        await fulfillment(of: [expectation], timeout: 2.0)

        guard case .success(let response) = completionResult else {
            return XCTFail("Expected success, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(response.status, "complete")
        XCTAssertEqual(telemetry.payments, [.started(.payPal), .finished(.payPal, .success, nil)])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    /// Debug only: it sets the token through the debug-only `test_setToken`.
    func testPayment_CaptureFailures_FinishAsAnErrorWithTheirCodes() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let configure: [(ChargesMockService) -> Void] = [
            { $0.shouldReturnError = true; $0.errorToReturn = Self.serverError },
            { $0.shouldThrowUnknownError = true }
        ]

        for setUp in configure {
            mockChargesService = ChargesMockService()
            setUp(mockChargesService)
            let expectation = XCTestExpectation(description: "failure")
            viewModel = makePaymentVM(expectation: expectation)
            viewModel.test_setToken("test_token")

            viewModel.capturePayPalPayment(paymentMethodId: "test_payment_method", payerId: "test_payer")
            await fulfillment(of: [expectation], timeout: 2.0)

            guard case .failure = completionResult else { return XCTFail("Expected a failure") }
        }

        XCTAssertEqual(telemetry.payments, [
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_CAPTURE_CHARGE_ERROR"),
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_UNKNOWN")
        ])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }
    #endif

    func testPayment_CaptureWithAnEmptyToken_FinishesAsAnError() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makePaymentVM()

        viewModel.capturePayPalPayment(paymentMethodId: "test_payment_method", payerId: "test_payer")

        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.payments, [.started(.payPal), .finished(.payPal, .error, "PAYPAL_UNKNOWN")])
    }

    func testPayment_ClientIdFailures_FinishAsAnErrorWithTheirCodes() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        mockGatewayService.shouldReturnError = true
        mockGatewayService.errorToReturn = Self.serverError

        viewModel = makePaymentVM()
        _ = await viewModel.getClientId()
        viewModel = makePaymentVM(gatewayService: FailingGatewayService())
        _ = await viewModel.getClientId()

        XCTAssertEqual(telemetry.payments, [
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_CLIENT_ID_ERROR"),
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_UNKNOWN")
        ])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    func testPayment_OrderIdFailures_FinishAsAnErrorWithTheirCodes() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()

        mockChargesService.shouldReturnError = true
        mockChargesService.errorToReturn = Self.serverError
        viewModel = makePaymentVM()
        _ = await viewModel.getOrderId(token: "test_token")
        mockChargesService = ChargesMockService()
        mockChargesService.shouldThrowUnknownError = true
        viewModel = makePaymentVM()
        _ = await viewModel.getOrderId(token: "test_token")

        XCTAssertEqual(telemetry.payments, [
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_FETCH_ORDER_ERROR"),
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_UNKNOWN")
        ])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }

    /// The app-not-active path is reachable only when the test host is not active.
    func testPayment_AppNotActive_FinishesAsCancelled() async throws {
        try XCTSkipIf(UIApplication.shared.applicationState == .active,
                      "the test host is active: the checkout would open")
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "cancelled")
        viewModel = makePaymentVM(withAttempt: false, expectation: expectation)

        viewModel.handleButtonTap()
        await fulfillment(of: [expectation], timeout: 2.0)

        guard case .failure(.userCancelled) = completionResult else {
            return XCTFail("Expected userCancelled, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.payments, [.started(.payPal), .finished(.payPal, .cancelled, nil)])
    }

    func testPayment_CheckoutCancelled_FinishesAsCancelled_AndDeliversAsBefore() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makePaymentVM()

        viewModel.handlePayPalError(PayPalWebPayments.PayPalError.checkoutCanceledError)

        guard case .failure(.userCancelled) = completionResult else {
            return XCTFail("Expected userCancelled, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.payments, [.started(.payPal), .finished(.payPal, .cancelled, nil)])
    }

    func testPayment_CheckoutErrors_FinishAsAnErrorWithTheirCodes() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()

        viewModel = makePaymentVM()
        viewModel.handlePayPalError(PayPalWebPayments.PayPalError.payPalURLError)
        guard case .failure(.sdkException) = completionResult else { return XCTFail("Expected sdkException") }
        viewModel = makePaymentVM()
        viewModel.handlePayPalError(NSError(domain: "Other", code: 1))
        guard case .failure(.unknownError(nil)) = completionResult else { return XCTFail("Expected unknownError(nil)") }

        XCTAssertEqual(telemetry.payments, [
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_SDK_EXCEPTION"),
            .started(.payPal), .finished(.payPal, .error, "PAYPAL_UNKNOWN")
        ])
        XCTAssertTrue(telemetry.paymentsArePaired)
    }
}

/// A gateway service whose client ID request fails without a request error.
private struct FailingGatewayService: GatewayService {
    func getClientId(gatewayId: String, widgetAccessToken: String) async throws -> String {
        throw NSError(domain: "MockError", code: -1)
    }
}
