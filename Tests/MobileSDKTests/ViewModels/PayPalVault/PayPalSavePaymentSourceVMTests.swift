//
//  PayPalSavePaymentSourceVMTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 11.12.2025..
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
import Combine
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataPaymentSources
@testable import DataGateways

@MainActor
// swiftlint:disable file_length
class PayPalSavePaymentSourceVMTests: XCTestCase {

    // MARK: - Properties

    var viewModel: PayPalSavePaymentSourceVM!
    var mockPaymentSourcesService: PaymentSourcesMockService!
    var mockGatewayService: GatewayMockService!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var eventDelegate: WidgetEventDelegateUtil!
    var config: PayPalVaultConfig!
    var completionResult: Result<PayPalVaultResult, PayPalVaultError>?
    var cancellables = Set<AnyCancellable>()

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockPaymentSourcesService = PaymentSourcesMockService()
        mockGatewayService = GatewayMockService()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()
        config = PayPalVaultConfig(accessToken: "test_access_token", gatewayId: "test_gateway_id")
        completionResult = nil
    }

    override func tearDown() {
        viewModel = nil
        mockPaymentSourcesService = nil
        mockGatewayService = nil
        viewState = nil
        loadingDelegate = nil
        eventDelegate = nil
        config = nil
        completionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialisationWithOptionsStateNone() {
        // Given
        viewState = ViewState(state: .none)

        // When
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // Then
        XCTAssertFalse(viewState.isDisabled, "View state should not be disabled")
        XCTAssertFalse(viewModel.isLoading, "View model should not be loading")
        XCTAssertFalse(viewModel.showLoaders, "Should not show loaders when delegate is present")
    }

    func testInitialisationWithOptionsStateDisabled() {
        // Given
        viewState = ViewState(state: .disabled)

        // When
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // Then
        XCTAssertTrue(viewState.isDisabled, "View state should be disabled")
        XCTAssertFalse(viewModel.isLoading, "View model should not be loading")
    }

    func testInitialisationWithDelegateShowLoader() {
        // When
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // Then
        XCTAssertFalse(viewModel.showLoaders, "Should not show loaders when delegate is present")
    }

    func testInitialisationWithoutDelegateShowLoader() {
        // When
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: nil,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        // Then
        XCTAssertTrue(viewModel.showLoaders, "Should show loaders when delegate is not present")
    }

    // MARK: - Loading State Tests

    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
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
        XCTAssertTrue(viewModel.isLoading, "View model should be loading")
        XCTAssertTrue(viewState.isDisabled, "View state should be disabled")
        XCTAssertTrue(loadingDelegate.isLoading, "Loading delegate should be notified")
    }

    func testUpdateLoadingStateToTrueWithoutDelegate() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: nil,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertTrue(viewModel.isLoading, "View model should be loading")
        XCTAssertTrue(viewState.isDisabled, "View state should be disabled")
    }

    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        viewModel.updateLoadingState(isLoading: true)

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertFalse(viewModel.isLoading, "View model should not be loading")
        XCTAssertFalse(viewState.isDisabled, "View state should not be disabled")
        XCTAssertFalse(loadingDelegate.isLoading, "Loading delegate should be notified")
    }

    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: nil,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )
        viewModel.updateLoadingState(isLoading: true)

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertFalse(viewModel.isLoading, "View model should not be loading")
        XCTAssertFalse(viewState.isDisabled, "View state should not be disabled")
    }

    // MARK: - Get Client ID Tests

    func testGetClientIdSuccess() async {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        mockGatewayService.clientIdResult = "test_client_id_123"

        // When
        let clientId = await viewModel.getClientId()

        // Then
        XCTAssertNotNil(clientId, "Client ID should not be nil")
        XCTAssertEqual(clientId, "test_client_id_123", "Client ID should match")
    }

    func testGetClientIdFailureWithRequestError() async {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        let testError = ErrorRes(
            status: 400,
            error: .init(message: "Client ID not found", code: "CLIENT_ID_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        mockGatewayService.shouldReturnError = true
        mockGatewayService.errorToReturn = testError

        // When
        let clientId = await viewModel.getClientId()

        // Then
        XCTAssertNil(clientId, "Client ID should be nil")
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }
        if case .getPayPalClientId(let errorRes) = error {
            XCTAssertEqual(errorRes.status, 400, "Error status should match")
            XCTAssertEqual(errorRes.error?.message, "Client ID not found", "Error message should match")
        } else {
            XCTFail("Expected getPayPalClientId error")
        }
    }

    // MARK: - Get Setup Token Tests

    func testGetSetupTokenDataSuccess() async {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        mockPaymentSourcesService.setupTokenResult = SetupTokenData(
            setupToken: "test_setup_token_456"
        )

        // When
        let setupTokenData = await viewModel.getSetupTokenData()

        // Then
        XCTAssertNotNil(setupTokenData, "Setup token data should not be nil")
        XCTAssertEqual(setupTokenData?.setupToken, "test_setup_token_456", "Setup token should match")
    }

    func testGetSetupTokenDataFailureWithRequestError() async {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        let testError = ErrorRes(
            status: 400,
            error: .init(message: "Setup token creation failed", code: "SETUP_TOKEN_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = testError

        // When
        let setupTokenData = await viewModel.getSetupTokenData()

        // Then
        XCTAssertNil(setupTokenData, "Setup token data should be nil")
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }
        if case .createSetupToken(let errorRes) = error {
            XCTAssertEqual(errorRes.status, 400, "Error status should match")
            XCTAssertEqual(errorRes.error?.message, "Setup token creation failed", "Error message should match")
        } else {
            XCTFail("Expected createSetupToken error")
        }
    }

    // MARK: - Create Payment Token Tests

    func testCreatePaymentTokenSuccess() async {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        mockPaymentSourcesService.paymentTokenResult = PaymentTokenData(
            token: "test_payment_token_789",
            email: "user@test.com"
        )

        // When
        await viewModel.createPaymentToken(setupToken: "test_setup_token")

        // Then
        guard case .success(let result) = completionResult else {
            XCTFail("Expected success result")
            return
        }
        XCTAssertEqual(result.token, "test_payment_token_789", "Payment token should match")
        XCTAssertEqual(result.email, "user@test.com", "Email should match")
        XCTAssertFalse(viewModel.isLoading, "View model should not be loading after completion")
    }

    func testCreatePaymentTokenFailureWithRequestError() async {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        let testError = ErrorRes(
            status: 400,
            error: .init(message: "Payment token creation failed", code: "PAYMENT_TOKEN_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = testError

        // When
        await viewModel.createPaymentToken(setupToken: "test_setup_token")

        // Then
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }
        if case .createPaymentToken(let errorRes) = error {
            XCTAssertEqual(errorRes.status, 400, "Error status should match")
            XCTAssertEqual(errorRes.error?.message, "Payment token creation failed", "Error message should match")
        } else {
            XCTFail("Expected createPaymentToken error")
        }
        XCTAssertFalse(viewModel.isLoading, "View model should not be loading after error")
    }

    // MARK: - Event Delegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // When
        viewModel.handleButtonTapAnalytics()

        // Then
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button), "Event delegate should receive button event")
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1, "Should receive exactly one button event")

        if case .button(let properties) = eventDelegate.lastEvent?.properties {
            XCTAssertEqual(properties.name, "PayPalVaultButton", "Button name should match")
            XCTAssertEqual(properties.action, .click, "Button action should be click")
        } else {
            XCTFail("Expected button event properties")
        }
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: nil,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        // When - This should not crash
        viewModel.handleButtonTapAnalytics()

        // Then - No assertion needed, just verifying no crash
    }

    // MARK: - Multiple Event Tests

    func testMultipleButtonTapEvents() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // When
        viewModel.handleButtonTapAnalytics()
        viewModel.handleButtonTapAnalytics()
        viewModel.handleButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 3, "Should receive three events")
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 3, "Should receive exactly three button events")
    }

    // MARK: - Config Tests

    func testViewModelUsesCorrectConfig() {
        // Given
        let customConfig = PayPalVaultConfig(
            accessToken: "custom_access_token",
            gatewayId: "custom_gateway_id"
        )

        // When
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: customConfig,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // Then
        XCTAssertEqual(viewModel.config.accessToken, "custom_access_token", "Access token should match config")
        XCTAssertEqual(viewModel.config.gatewayId, "custom_gateway_id", "Gateway ID should match config")
    }

    // MARK: - View State Tests

    func testViewStateDisabledDuringLoading() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
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
        XCTAssertTrue(viewState.isDisabled, "View state should be disabled during loading")
        XCTAssertTrue(viewModel.isLoading, "View model should be loading")
    }

    func testViewStateEnabledAfterLoadingComplete() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
        viewModel.updateLoadingState(isLoading: true)

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertFalse(viewState.isDisabled, "View state should be enabled after loading")
        XCTAssertFalse(viewModel.isLoading, "View model should not be loading")
    }

    // MARK: - Action Text Tests

    func testActionTextInitialization() {
        // When
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // Then
        XCTAssertEqual(viewModel.actionText, "", "Action text should be empty on initialization")
    }
}
