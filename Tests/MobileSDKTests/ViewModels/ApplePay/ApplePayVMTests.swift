//
//  ApplePayVMTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.09.2025..
//  Copyright © 2025 Paydock Ltd.
//

import XCTest
import PassKit
import Combine
@testable import MobileSDK

@MainActor
class ApplePayVMTests: XCTestCase {

    var viewModel: ApplePayVM!
    var mockWalletService: WalletServiceMock!
    var completionResult: Result<ChargeResponse, ApplePayError>?
    var createPaymentRequestResult: Result<ApplePayRequestResult, ApplePayRequestError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockWalletService = WalletServiceMock()
        completionResult = nil
        createPaymentRequestResult = nil
        setupViewModel()
    }

    override func tearDown() {
        viewModel = nil
        mockWalletService = nil
        completionResult = nil
        createPaymentRequestResult = nil
        cancellables.removeAll()
        super.tearDown()
    }

    private func setupViewModel() {
        viewModel = ApplePayVM(
            createPaymentRequest: { completion in
                if let result = self.createPaymentRequestResult {
                    completion(result)
                } else {
                    // Default success case
                    let mockPaymentRequest = PKPaymentRequest()
                    let result = ApplePayRequestResult(request: mockPaymentRequest, token: "test_token")
                    completion(.success(result))
                }
            },
            walletService: mockWalletService,
            completion: { result in
                self.completionResult = result

            })
    }

    // MARK: - Initialization Tests

    func testInitializationSetsPropertiesCorrectly() {
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.paymentSummaryItems.isEmpty)
        XCTAssertEqual(viewModel.paymentStatus, .failure)
        XCTAssertNil(viewModel.paymentController)
        XCTAssertNil(viewModel.chargeData)
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Handle Button Tap Tests

    func testHandleButtonTapWithSuccessfulPaymentRequest() {
        // Given
        let mockPaymentRequest = PKPaymentRequest()
        mockPaymentRequest.merchantIdentifier = "test.merchant.id"
        mockPaymentRequest.countryCode = "US"
        mockPaymentRequest.currencyCode = "USD"
        mockPaymentRequest.supportedNetworks = [.visa, .masterCard]
        mockPaymentRequest.merchantCapabilities = .threeDSecure

        let successResult = ApplePayRequestResult(request: mockPaymentRequest, token: "test_token")
        createPaymentRequestResult = .success(successResult)
        setupViewModel()

        // When
        viewModel.handleButtonTap()

        // Then
        XCTAssertNotNil(viewModel.paymentController)
        XCTAssertNil(viewModel.error)
    }

    func testHandleButtonTapWithFailedPaymentRequest() {
        // Given
        let error = ApplePayRequestError.initialisingWalletToken(reason: "Test error")
        createPaymentRequestResult = .failure(error)
        setupViewModel()

        // When
        viewModel.handleButtonTap()

        // Then
        XCTAssertNil(viewModel.paymentController)
        XCTAssertNil(viewModel.error) // Error is not set on viewModel, only passed to completion
        if case .failure(let applePayError) = completionResult {
            if case .creatingPaymentRequest(let reason) = applePayError {
                XCTAssertEqual(reason, "Test error") // This matches the customMessage from ApplePayRequestError
            } else {
                XCTFail("Expected creatingPaymentRequest error")
            }
        } else {
            XCTFail("Expected failure completion result")
        }
    }

    func testHandleButtonTapWithInvalidPaymentRequest() async {
        // Given
        let invalidPaymentRequest = PKPaymentRequest() // Missing required fields
        let successResult = ApplePayRequestResult(request: invalidPaymentRequest, token: "test_token")
        createPaymentRequestResult = .success(successResult)
        setupViewModel()

        // When
        viewModel.handleButtonTap()

        // Then
        // The controller is created but presentation fails
        XCTAssertNotNil(viewModel.paymentController)

        // Wait for the async presentation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // After presentation failure, error should be set
        if let error = viewModel.error,
           case .unableToPresentPaymentSheet = error {
            XCTAssert(true, "Error correctly set to unableToPresentPaymentSheet")
        } else {
            XCTFail("Expected unableToPresentPaymentSheet error, got \(String(describing: viewModel.error))")
        }

        // No completion should be called yet since the controller wasn't dismissed
        XCTAssertNil(completionResult)
    }

    // MARK: - Payment Authorization Delegate Tests

    func testPaymentAuthorizationWithSuccessfulCapture() async {
        // Given
        setupViewModelWithValidRequest()
        let mockPayment = createMockPayment()
        mockWalletService.shouldReturnError = false

        let expectation = XCTestExpectation(description: "Payment authorization completion")

        // When
        viewModel.paymentAuthorizationController(
            PKPaymentAuthorizationController(),
            didAuthorizePayment: mockPayment
        ) { status in
            // Then
            XCTAssertEqual(status, .success)
            XCTAssertEqual(self.viewModel.paymentStatus, .success)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Verify the completion was called with success during captureCharge
        if case .success(let result) = completionResult {
            XCTAssertEqual(result.status, "")
            XCTAssertEqual(result.amount, 1.0)
            XCTAssertEqual(result.currency, "")
        } else {
            XCTFail("Expected success completion result from captureCharge")
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithSuccess() {
        // Given
        setupViewModelWithValidRequest()
        viewModel.paymentStatus = .success
        // Set chargeData to simulate successful payment
        viewModel.chargeData = ChargeResponse(status: "success", amount: 100.0, currency: "USD")

        // Reset completion result to test didFinish behavior
        completionResult = nil

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Then
        // Now it should succeed since we have chargeData
        if case .success(let result) = completionResult {
            XCTAssertEqual(result.status, "success")
            XCTAssertEqual(result.amount, 100.0)
            XCTAssertEqual(result.currency, "USD")
        } else {
            XCTFail("Expected success completion result")
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithUserCancellation() {
        // Given
        setupViewModelWithValidRequest()
        viewModel.paymentStatus = .failure
        viewModel.error = .userCanceledPayment

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Then
        if case .failure(let error) = completionResult {
            if case .userCanceledPayment = error {
                XCTAssert(true)
            } else {
                XCTFail("Expected userCanceledPayment error")
            }
        } else {
            XCTFail("Expected failure completion result")
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithPaymentError() {
        // Given
        setupViewModelWithValidRequest()
        viewModel.paymentStatus = .failure
        viewModel.error = .unknownError(.connectionError(URLError(.networkConnectionLost)))

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Then
        if case .failure(let error) = completionResult {
            if case .unknownError = error {
                XCTAssert(true, "Expected unknownError to be passed through")
            } else {
                XCTFail("Expected unknownError, got \(error)")
            }
        } else {
            XCTFail("Expected failure completion result")
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithUnknownError() {
        // Given
        setupViewModelWithValidRequest()
        viewModel.paymentStatus = .failure
        viewModel.error = nil

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Then
        if case .failure(let error) = completionResult {
            if case .userCanceledPayment = error {
                XCTAssert(true, "Expected userCanceledPayment when error is nil")
            } else {
                XCTFail("Expected userCanceledPayment, got \(error)")
            }
        } else {
            XCTFail("Expected failure completion result")
        }
    }

    // MARK: - Helper Methods

    private func setupViewModelWithValidRequest() {
        let mockPaymentRequest = PKPaymentRequest()
        mockPaymentRequest.merchantIdentifier = "test.merchant.id"
        mockPaymentRequest.countryCode = "US"
        mockPaymentRequest.currencyCode = "USD"
        mockPaymentRequest.supportedNetworks = [.visa, .masterCard]
        mockPaymentRequest.merchantCapabilities = .threeDSecure

        let successResult = ApplePayRequestResult(request: mockPaymentRequest, token: "test_token")
        createPaymentRequestResult = .success(successResult)
        setupViewModel()
        viewModel.handleButtonTap()
    }

    private func createMockPayment() -> PKPayment {
        return PKPayment()
    }

    private struct MockErrorRes: Error {
        var uiMessage: String {
            return "Mock error message"
        }
    }
}
