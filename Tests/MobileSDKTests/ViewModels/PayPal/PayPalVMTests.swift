//
//  PayPalVMTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
import Combine
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataCharges
@testable import DataGateways

@MainActor
class PayPalVMTests: XCTestCase {

    var viewModel: PayPalVM!
    var mockChargesService: ChargesMockService!
    var mockGatewayService: GatewayMockService!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var eventDelegate: WidgetEventDelegateUtil!
    var config: PayPalWidgetConfig!
    var completionResult: Result<ChargeResponse, PayPalError>?
    var tokenRequestResult: Result<WalletTokenResult, WalletTokenError>?
    var cancellables = Set<AnyCancellable>()
    private let telemetry = RecordingTelemetry()

    override func setUp() {
        super.setUp()
        MobileSDK.shared.configureMobileSDK(config: .init(environment: .sandbox))
        mockChargesService = ChargesMockService()
        mockGatewayService = GatewayMockService()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()
        config = PayPalWidgetConfig(accessToken: "test_token", gatewayId: "test_gateway_id")
        completionResult = nil
        tokenRequestResult = nil

        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { [weak self] completion in
                if let result = self?.tokenRequestResult {
                    completion(result)
                } else {
                    completion(.success(WalletTokenResult(token: "test_token")))
                }
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
    }

    override func tearDown() {
        viewModel = nil
        mockChargesService = nil
        mockGatewayService = nil
        viewState = nil
        loadingDelegate = nil
        eventDelegate = nil
        config = nil
        completionResult = nil
        tokenRequestResult = nil
        cancellables.removeAll()
        RecordingTelemetry.unbind()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialisationWithOptionsStateNone() {
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    func testInitialisationWithOptionsStateDisabled() {
        viewModel = PayPalVM(
            config: config,
            viewState: ViewState(state: .disabled),
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testInitialisationWithDelegateShowLoader() {
        XCTAssertEqual(viewModel.showLoaders, false)
    }

    func testInitialisationWithoutDelegateShowLoader() {
        viewModel = PayPalVM(
            config: config,
            viewState: ViewState(state: .disabled),
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: nil,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        XCTAssertEqual(viewModel.showLoaders, true)
    }

    // MARK: - Loading State Tests

    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(loadingDelegate.isLoading, true)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToTrueWithoutDelegate() {
        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: nil,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )
        viewModel.isLoading = false
        loadingDelegate.isLoading = false

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(loadingDelegate.isLoading, false)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        viewModel.isLoading = false
        loadingDelegate.isLoading = true

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(loadingDelegate.isLoading, false)
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: nil,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )
        viewModel.isLoading = true
        loadingDelegate.isLoading = false

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(loadingDelegate.isLoading, false)
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    // MARK: - Token Request Tests

    func testHandleButtonTapWithSuccessfulTokenRequest() async {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "success_token"))

        // Mock successful services
        mockGatewayService.shouldReturnError = false

        // When
        viewModel.handleButtonTap()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
    }

    func testHandleButtonTapWithFailedTokenRequest() {
        // Given
        let expectation = self.expectation(description: "Completion handler called")
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: "Token error"))

        // When
        viewModel.handleButtonTap()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.completionResult)
            switch self.completionResult {
            case .failure(let error):
                switch error {
                case .initialisingWalletToken(let reason):
                    XCTAssertEqual(reason, "Token error")
                default:
                    XCTFail("Expected initialisingWalletToken error")
                }
            default:
                XCTFail("Expected failure result")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - GetClientId Tests

    func testGetClientIdSuccess() async {
        // Given
        mockGatewayService.shouldReturnError = false

        // When
        let clientId = await viewModel.getClientId()

        // Then
        XCTAssertNotNil(clientId)
        XCTAssertFalse(clientId?.isEmpty ?? true)
    }

    func testGetClientIdFailureWithRequestError() async {
        // Given
        mockGatewayService.shouldReturnError = true
        mockGatewayService.errorToReturn = ErrorRes(
            status: 500,
            error: .init(message: "Test Error", code: "TEST", details: nil),
            resource: nil,
            errorSummary: nil
        )
        // Error response is configured through shouldReturnError and errorToReturn

        // When
        let clientId = await viewModel.getClientId()

        // Then
        XCTAssertNil(clientId)
        XCTAssertNotNil(completionResult)
        switch completionResult {
        case .failure(let error):
            switch error {
            case .getPayPalClientId:
                XCTAssertTrue(true) // Expected error
            default:
                XCTFail("Expected getPayPalClientId error")
            }
        default:
            XCTFail("Expected failure result")
        }
    }

    // MARK: - GetOrderId Tests

    func testGetOrderIdSuccess() async {
        // Given
        let testToken = "test_token"

        // When
        let orderId = await viewModel.getOrderId(token: testToken)

        // Then
        XCTAssertNotNil(orderId)
    }

    // MARK: - CapturePayPalPayment Tests

    #if DEBUG
    /// Debug only: it sets the token through the debug-only `test_setToken`.
    func testCapturePayPalPaymentSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Capture payment success")

        // Reset mock service state
        mockChargesService.shouldReturnError = false
        mockChargesService.shouldThrowUnknownError = false

        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            }
        )

        // Set token directly for testing (bypasses async token request)
        viewModel.test_setToken("test_token")

        // When
        viewModel.capturePayPalPayment(paymentMethodId: "test_payment_method", payerId: "test_payer")

        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(completionResult)
        switch completionResult {
        case .success(let response):
            XCTAssertNotNil(response)
            XCTAssertEqual(response.status, "complete")
            XCTAssertEqual(response.amount, 50.0)
            XCTAssertEqual(response.currency, "AUD")
        default:
            XCTFail("Expected success result, got: \(String(describing: completionResult))")
        }
    }
    #endif

    func testCapturePayPalPaymentWithEmptyToken() {
        // Given
        let expectation = XCTestExpectation(description: "Capture payment with empty token")

        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            }
        )

        // When
        viewModel.capturePayPalPayment(paymentMethodId: "test_payment_method", payerId: "test_payer")

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(completionResult)
        switch completionResult {
        case .failure(let error):
            switch error {
            case .unknownError:
                XCTAssertTrue(true) // Expected error
            default:
                XCTFail("Expected unknownError")
            }
        default:
            XCTFail("Expected failure result")
        }
    }

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "PayPalCheckoutButton", action: .click)))
        viewModel.handleButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        // When
        viewModel.handleButtonTap()

        // Then - No events should be recorded in our test delegate
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }

    // MARK: - Telemetry (R_05, R_06)

    private func makeTelemetryVM(token: String = "test_token",
                                 tokenResult: Result<WalletTokenResult, WalletTokenError>? = nil,
                                 expectation: XCTestExpectation? = nil) -> PayPalVM {
        PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(tokenResult ?? .success(WalletTokenResult(token: token)))
            },
            chargesService: mockChargesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
                expectation?.fulfill()
            }
        )
    }

    func testTelemetry_WalletTokenFailure_DeliversAsBefore_AndReportsNoSdkError() async {
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(tokenResult: .failure(.initialisingWalletToken(reason: "Token error")),
                                    expectation: expectation)

        viewModel.handleButtonTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.initialisingWalletToken(let reason)) = completionResult else {
            return XCTFail("Expected initialisingWalletToken, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(reason, "Token error")
        XCTAssertEqual(telemetry.sdkErrors, [])
    }

    func testTelemetry_CaptureWithoutToken_ReportsOneSdkError_AndDeliversAsBefore() {
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(token: "")

        viewModel.capturePayPalPayment(paymentMethodId: "test_payment_method", payerId: "test_payer")

        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("PAYPAL_UNKNOWN", .payPal)])
    }

    func testTelemetry_OrderIdNonRequestFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        telemetry.bindAsCurrent()
        mockChargesService.shouldThrowUnknownError = true
        viewModel = makeTelemetryVM()

        let orderId = await viewModel.getOrderId(token: "test_token")

        XCTAssertNil(orderId)
        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("PAYPAL_UNKNOWN", .payPal)])
    }

    func testTelemetry_ClientIdRequestFailure_DeliversAsBefore_AndReportsNothing() async {
        telemetry.bindAsCurrent()
        mockGatewayService.shouldReturnError = true
        mockGatewayService.errorToReturn = ErrorRes(status: 500, error: .init(message: "Test Error", code: "TEST", details: nil),
                                                    resource: nil, errorSummary: nil)
        viewModel = makeTelemetryVM()

        let clientId = await viewModel.getClientId()

        XCTAssertNil(clientId)
        guard case .failure(.getPayPalClientId) = completionResult else {
            return XCTFail("Expected getPayPalClientId, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }
}
