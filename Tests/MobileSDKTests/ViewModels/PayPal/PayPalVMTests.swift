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

@MainActor
class PayPalVMTests: XCTestCase {

    var viewModel: PayPalVM!
    var mockWalletService: WalletServiceMock!
    var mockPayPalVaultService: PayPalVaultServiceMock!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var config: PayPalWidgetConfig!
    var completionResult: Result<ChargeResponse, PayPalError>?
    var tokenRequestResult: Result<WalletTokenResult, WalletTokenError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockWalletService = WalletServiceMock()
        mockPayPalVaultService = PayPalVaultServiceMock()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
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
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: loadingDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
    }

    override func tearDown() {
        viewModel = nil
        mockWalletService = nil
        mockPayPalVaultService = nil
        viewState = nil
        loadingDelegate = nil
        config = nil
        completionResult = nil
        tokenRequestResult = nil
        cancellables.removeAll()
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
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: loadingDelegate,
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
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: nil,
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
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: loadingDelegate,
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
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: nil,
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
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: loadingDelegate,
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
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: nil,
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
        mockPayPalVaultService.sendError = false

        // When
        viewModel.handleButtonTap()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
    }

    func testHandleButtonTapWithFailedTokenRequest() {
        // Given
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: "Token error"))

        // When
        viewModel.handleButtonTap()

        // Then
        XCTAssertNotNil(completionResult)
        switch completionResult {
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
    }

    // MARK: - GetClientId Tests

    func testGetClientIdSuccess() async {
        // Given
        mockPayPalVaultService.sendError = false

        // When
        let clientId = await viewModel.getClientId()

        // Then
        XCTAssertNotNil(clientId)
        XCTAssertFalse(clientId?.isEmpty ?? true)
    }

    func testGetClientIdFailureWithRequestError() async {
        // Given
        mockPayPalVaultService.sendError = true
        mockPayPalVaultService.responseFilename = .authFail

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

    func testCapturePayPalPaymentSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Capture payment success")

        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: loadingDelegate,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            }
        )

        // Simulate having a token
        viewModel.handleButtonTap()

        // When
        viewModel.capturePayPalPayment(paymentMethodId: "test_payment_method", payerId: "test_payer")

        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(completionResult)
        switch completionResult {
        case .success(let response):
            XCTAssertNotNil(response)
        default:
            XCTFail("Expected success result")
        }
    }

    func testCapturePayPalPaymentWithEmptyToken() {
        // Given
        let expectation = XCTestExpectation(description: "Capture payment with empty token")

        viewModel = PayPalVM(
            config: config,
            viewState: viewState,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "")))
            },
            walletService: mockWalletService,
            payPalVaultService: mockPayPalVaultService,
            loadingDelegate: loadingDelegate,
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
}
