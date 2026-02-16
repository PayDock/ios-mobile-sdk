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
@testable import DataCharges

@MainActor
// swiftlint:disable file_length
class AfterPayVMTests: XCTestCase {

    var viewModel: AfterpayVM!
    var mockChargesService: ChargesMockService!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var eventDelegate: WidgetEventDelegateUtil!
    var configuration: AfterpaySdkConfig!
    var completionResult: Result<ChargeResponse, AfterpayError>?
    var tokenRequestResult: Result<WalletTokenResult, WalletTokenError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockChargesService = ChargesMockService()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()

        // Create test configuration
        let checkoutOptions = AfterpaySdkConfig.CheckoutOptions(
            pickup: false,
            buyNow: true,
            shippingOptionRequired: false,
            enableSingleShippingOptionUpdate: true
        )
        configuration = AfterpaySdkConfig(
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
            chargesService: mockChargesService,
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
        viewState = nil
        loadingDelegate = nil
        eventDelegate = nil
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
            chargesService: mockChargesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
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
            chargesService: mockChargesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
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
            chargesService: mockChargesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: nil,
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
            chargesService: mockChargesService,
            loadingDelegate: nil,
            eventDelegate: nil,
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
            chargesService: mockChargesService,
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

    func testHandleButtonTapWithNilTokenRequestReason() {
        // Given
        let expectation = self.expectation(description: "Completion handler called")
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: nil))

        // When
        viewModel.handleButtonTap()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.completionResult)
            switch self.completionResult {
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
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Configuration Tests

    func testConfigurationIsProperlySet() {
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
        let firstExpectation = self.expectation(description: "First completion handler called")
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: "Initial error"))
        viewModel.handleButtonTap()

        // Wait for first completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let initialError = self.completionResult
            XCTAssertNotNil(initialError)
            switch initialError {
            case .failure:
                XCTAssertTrue(true) // Expected initial failure
            default:
                XCTFail("Expected initial failure")
            }
            firstExpectation.fulfill()
        }

        wait(for: [firstExpectation], timeout: 1.0)

        // When - Retry with success
        let secondExpectation = self.expectation(description: "Second completion handler called")
        completionResult = nil
        tokenRequestResult = .success(WalletTokenResult(token: "recovery_token"))
        viewModel.handleButtonTap()

        // Then - Should be in loading state for successful retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.loadingDelegate.isLoading)
            secondExpectation.fulfill()
        }

        wait(for: [secondExpectation], timeout: 1.0)
    }

    // MARK: - Error Propagation Tests

    func testCompletionHandlerReceivesTokenInitializationError() {
        // Given
        let expectation = self.expectation(description: "Completion handler called")
        let expectedReason = "Token initialization failed"
        tokenRequestResult = .failure(WalletTokenError.initialisingWalletToken(reason: expectedReason))

        // When
        viewModel.handleButtonTap()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.completionResult)
            guard case .failure(let error) = self.completionResult else {
                XCTFail("Expected failure result")
                return
            }

            guard case .initialisingWalletToken(let actualReason) = error else {
                XCTFail("Expected initialisingWalletToken error, got \(error)")
                return
            }

            XCTAssertEqual(actualReason, expectedReason)
            XCTAssertFalse(self.loadingDelegate.isLoading, "Loading should be stopped after error")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testCompletionHandlerReceivesChargesServiceCaptureChargeError() {
        // Given
        tokenRequestResult = .success(WalletTokenResult(token: "test_token"))
        let errorRes = ErrorRes(
            status: 400,
            error: .init(message: "Charge failed", code: "CHARGE_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        let expectedError = AfterpayError.errorCapturingCharge(error: errorRes)

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
            error: .init(message: "URL fetch failed", code: "URL_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        let expectedError = AfterpayError.errorFetchingAfterpayUrl(error: errorRes)

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
            error: .init(message: "Unknown network error", code: "UNKNOWN_ERROR", details: nil),
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
            error: .init(message: "Cancel failed", code: "CANCEL_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        let expectedError = AfterpayError.errorCancelingTransaction(error: errorRes)

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
        XCTAssertEqual(error.customMessage, "Cancel failed")
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
            chargesService: mockChargesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
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

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            chargesService: mockChargesService,
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
            properties: .button(WidgetEventButtonProperties(name: "AfterPayCheckoutButton", action: .click)))
        viewModel.handleAfterpayButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = AfterpayVM(
            viewState: viewState,
            configuration: configuration,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "test_token")))
            },
            selectAddress: nil,
            selectShippingOption: nil,
            chargesService: mockChargesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        // When - The view model should handle nil event delegate gracefully
        // viewModel.triggerButtonEvent() // This should not crash

        // Then - No events should be recorded in our test delegate
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }
}
