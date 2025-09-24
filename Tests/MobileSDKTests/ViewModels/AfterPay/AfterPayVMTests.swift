//
//  AfterPayVMTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.09.2025..
//  Copyright © 2025 Paydock Ltd.
//

import XCTest
import Combine
import Afterpay
@testable import MobileSDK
@testable import NetworkingLib

@MainActor
class AfterPayVMTests: XCTestCase {

    var viewModel: AfterpayVM!
    var mockWalletService: WalletServiceMock!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var configuration: AfterpaySdkConfig!
    var completionResult: Result<ChargeResponse, AfterpayError>?
    var tokenRequestResult: Result<WalletTokenResult, WalletTokenError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockWalletService = WalletServiceMock()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()

        // Create test configuration
        let afterpayConfig = AfterpaySdkConfig.AfterpayConfiguration(
            minimumAmount: "10.00",
            maximumAmount: "1000.00",
            currency: "AUD",
            language: "en_AU",
            country: "AU"
        )
        let checkoutOptions = AfterpaySdkConfig.CheckoutOptions(
            pickup: false,
            buyNow: true,
            shippingOptionRequired: false,
            enableSingleShippingOptionUpdate: true
        )
        configuration = AfterpaySdkConfig(
            config: afterpayConfig,
            environment: .sandbox,
            options: checkoutOptions
        )

        completionResult = nil
        tokenRequestResult = nil

        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { [weak self] completion in
                if let result = self?.tokenRequestResult {
                    completion(result)
                } else {
                    completion(.success(WalletTokenResult(token: "test_token")))
                }
            },
            selectAddress: {_, _ in
            },
            selectShippingOption: {_, _ in
            },
            walletService: mockWalletService,
            loadingDelegate: loadingDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
    }

    override func tearDown() {
        viewModel = nil
        mockWalletService = nil
        viewState = nil
        loadingDelegate = nil
        configuration = nil
        completionResult = nil
        tokenRequestResult = nil
        //        selectAddressResult = nil
        //        selectShippingOptionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithDefaultState() {
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.afterPayOrderId, "")
    }

    func testInitializationWithDisabledState() {
        viewModel = AfterpayVM(
            viewState: ViewState(state: .disabled),
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            walletService: mockWalletService,
            loadingDelegate: loadingDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testInitializationWithoutLoadingDelegate() {
        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            walletService: mockWalletService,
            loadingDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        XCTAssertNotNil(viewModel)
    }

    func testInitializationWithoutShippingHandlers() {
        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            walletService: mockWalletService,
            loadingDelegate: loadingDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        XCTAssertNotNil(viewModel)
    }

    // MARK: - Loading State Tests

    func testUpdateLoadingStateToTrueWithDelegate() {
        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertEqual(loadingDelegate.isLoading, true)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToTrueWithoutDelegate() {
        // Given
        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            walletService: mockWalletService,
            loadingDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel.updateLoadingState(isLoading: true)

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(loadingDelegate.isLoading, false)
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            walletService: mockWalletService,
            loadingDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )
        viewModel.updateLoadingState(isLoading: true)

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    // MARK: - Button Tap Tests

    func testHandleButtonTapWithSuccessfulTokenRequest() {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "success_token"))

        // When
        viewModel.handleButtonTap()

        // Then
        XCTAssertEqual(loadingDelegate.isLoading, true)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
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

    func testHandleButtonTapWithNilTokenRequestReason() {
        // Given
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: nil))

        // When
        viewModel.handleButtonTap()

        // Then
        XCTAssertNotNil(completionResult)
        switch completionResult {
        case .failure(let error):
            switch error {
            case .initialisingWalletToken(let reason):
                XCTAssertEqual(reason, "An unexpected error occurred while retrieving token.")
            default:
                XCTFail("Expected initialisingWalletToken error")
            }
        default:
            XCTFail("Expected failure result")
        }
    }

    // MARK: - Configuration Tests

    func testConfigurationIsProperlySet() {
        XCTAssertEqual(viewModel.configuration.config.currency, "AUD")
        XCTAssertEqual(viewModel.configuration.config.country, "AU")
        XCTAssertEqual(viewModel.configuration.config.maximumAmount, "1000.00")
        XCTAssertEqual(viewModel.configuration.config.minimumAmount, "10.00")
        XCTAssertEqual(viewModel.configuration.options.buyNow, true)
        XCTAssertEqual(viewModel.configuration.options.pickup, false)
    }

    // MARK: - WebView State Tests

    func testShowWebViewInitiallyFalse() {
        XCTAssertFalse(viewModel.showWebView)
    }

    func testShowWebViewCanBeUpdated() {
        // Given
        XCTAssertFalse(viewModel.showWebView)

        // When
        viewModel.showWebView = true

        // Then
        XCTAssertTrue(viewModel.showWebView)
    }

    // MARK: - Error Recovery Tests

    func testErrorRecoveryAfterFailedTokenRequest() {
        // Given - Initial failure
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: "Initial error"))
        viewModel.handleButtonTap()

        let initialError = completionResult

        // When - Retry with success
        completionResult = nil
        tokenRequestResult = .success(WalletTokenResult(token: "recovery_token"))
        viewModel.handleButtonTap()

        // Then
        XCTAssertNotNil(initialError)
        switch initialError {
        case .failure:
            XCTAssertTrue(true) // Expected initial failure
        default:
            XCTFail("Expected initial failure")
        }

        // Should be in loading state for successful retry
        XCTAssertTrue(loadingDelegate.isLoading)
    }

    // MARK: - Error Propagation Tests

    func testCompletionHandlerReceivesTokenInitializationError() {
        // Given
        let expectedReason = "Token initialization failed"
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: expectedReason))

        // When
        viewModel.handleButtonTap()

        // Then
        XCTAssertNotNil(completionResult)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .initialisingWalletToken(let actualReason) = error else {
            XCTFail("Expected initialisingWalletToken error, got \(error)")
            return
        }

        XCTAssertEqual(actualReason, expectedReason)
        XCTAssertFalse(loadingDelegate.isLoading, "Loading should be stopped after error")
    }

    func testCompletionHandlerReceivesWalletServiceCaptureChargeError() {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "test_token"))
        let errorRes = ErrorRes(
            status: 400,
            error: ErrorRes.ErrorObj(message: "Charge failed", code: "CHARGE_ERROR"),
            resource: nil,
            errorSummary: nil
        )
        let expectedError = AfterpayError.errorCapturingCharge(error: errorRes)
        mockWalletService.shouldReturnError = true
        mockWalletService.errorToReturn = expectedError

        // When
        viewModel.handleButtonTap()

        // Simulate error during charge capture by calling completion directly
        viewModel.completion(.failure(expectedError))

        // Then
        XCTAssertNotNil(completionResult)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .errorCapturingCharge(let actualErrorRes) = error else {
            XCTFail("Expected errorCapturingCharge error, got \(error)")
            return
        }

        XCTAssertEqual(actualErrorRes.error?.message, "Charge failed")
        XCTAssertEqual(actualErrorRes.status, 400)
    }

    func testCompletionHandlerReceivesAfterpayURLFetchError() {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "test_token"))
        let errorRes = ErrorRes(
            status: 500,
            error: ErrorRes.ErrorObj(message: "URL fetch failed", code: "URL_ERROR"),
            resource: nil,
            errorSummary: nil
        )
        let expectedError = AfterpayError.errorFetchingAfterpayUrl(error: errorRes)
        mockWalletService.shouldReturnError = true
        mockWalletService.errorToReturn = expectedError

        // When
        viewModel.handleButtonTap()

        // Simulate URL fetch failure by calling completion directly
        viewModel.completion(.failure(expectedError))

        // Then
        XCTAssertNotNil(completionResult)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .errorFetchingAfterpayUrl(let actualErrorRes) = error else {
            XCTFail("Expected errorFetchingAfterpayUrl error, got \(error)")
            return
        }

        XCTAssertEqual(actualErrorRes.error?.message, "URL fetch failed")
        XCTAssertEqual(actualErrorRes.status, 500)
    }

    func testCompletionHandlerReceivesUnknownError() {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "test_token"))
        let errorRes = ErrorRes(
            status: 500,
            error: ErrorRes.ErrorObj(message: "Unknown network error", code: "UNKNOWN_ERROR"),
            resource: nil,
            errorSummary: nil
        )
        let requestError = RequestError.requestError(errorRes)
        let expectedError = AfterpayError.unknownError(requestError)

        // When - Simulate unknown error scenario
        viewModel.handleButtonTap()
        viewModel.completion(.failure(expectedError))

        // Then
        XCTAssertNotNil(completionResult)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .unknownError(let actualRequestError) = error else {
            XCTFail("Expected unknownError, got \(error)")
            return
        }

        XCTAssertNotNil(actualRequestError)
        if case .requestError(let actualErrorRes) = actualRequestError {
            XCTAssertEqual(actualErrorRes.error?.message, "Unknown network error")
            XCTAssertEqual(actualErrorRes.status, 500)
        } else {
            XCTFail("Expected requestError case")
        }
    }

    func testCompletionHandlerReceivesUnknownErrorWithNilRequestError() {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "test_token"))
        let expectedError = AfterpayError.unknownError(nil)

        // When
        viewModel.handleButtonTap()
        viewModel.completion(.failure(expectedError))

        // Then
        XCTAssertNotNil(completionResult)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .unknownError(let requestError) = error else {
            XCTFail("Expected unknownError, got \(error)")
            return
        }

        XCTAssertNil(requestError)
        XCTAssertEqual(error.customMessage, "Unknown error")
    }

    func testCompletionHandlerReceivesErrorCancelingTransactionError() {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "test_token"))
        let errorRes = ErrorRes(
            status: 400,
            error: ErrorRes.ErrorObj(message: "Cancel failed", code: "CANCEL_ERROR"),
            resource: nil,
            errorSummary: nil
        )
        let expectedError = AfterpayError.errorCancelingTransaction(error: errorRes)
        mockWalletService.shouldReturnError = true
        mockWalletService.errorToReturn = expectedError

        // When
        viewModel.handleButtonTap()

        // Simulate cancellation failure by calling completion directly
        viewModel.completion(.failure(expectedError))

        // Then
        XCTAssertNotNil(completionResult)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .errorCancelingTransaction(let actualErrorRes) = error else {
            XCTFail("Expected errorCancelingTransaction error, got \(error)")
            return
        }

        XCTAssertEqual(actualErrorRes.error?.message, "Cancel failed")
        XCTAssertEqual(actualErrorRes.status, 400)
        XCTAssertEqual(error.customMessage, "Unable to cancel transaction")
    }

    // MARK: - Success Case Tests

    func testCompletionHandlerReceivesSuccessResult() {
        // Given
        let expectedChargeResponse = ChargeResponse(status: "completed", amount: 100.0, currency: "AUD")

        // When
        viewModel.completion(.success(expectedChargeResponse))

        // Then
        XCTAssertNotNil(completionResult)
        guard case .success(let chargeResponse) = completionResult else {
            XCTFail("Expected success result")
            return
        }

        XCTAssertEqual(chargeResponse.status, "completed")
        XCTAssertEqual(chargeResponse.amount, 100.0)
        XCTAssertEqual(chargeResponse.currency, "AUD")
    }

    func testCompletionHandlerCalledOnlyOncePerError() {
        // Given
        var completionCallCount = 0
        let expectation = self.expectation(description: "Completion called once")

        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            walletService: mockWalletService,
            loadingDelegate: loadingDelegate,
            completion: { _ in
                completionCallCount += 1
                expectation.fulfill()
            }
        )

        // When
        viewModel.completion(.failure(.transactionCanceled))

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(completionCallCount, 1)
    }
}
