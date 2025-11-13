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
    var eventDelegate: WidgetEventDelegateUtil!
    var completionResult: Result<ChargeResponse, ApplePayError>?
    var createPaymentRequestResult: Result<ApplePayRequestResult, ApplePayRequestError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockWalletService = WalletServiceMock()
        eventDelegate = WidgetEventDelegateUtil()
        completionResult = nil
        createPaymentRequestResult = nil
        setupViewModel()
    }

    override func tearDown() {
        viewModel = nil
        mockWalletService = nil
        eventDelegate = nil
        completionResult = nil
        createPaymentRequestResult = nil
        cancellables.removeAll()
        super.tearDown()
    }

    private func setupViewModel() {
        viewModel = ApplePayVM(
            eventDelegate: eventDelegate,
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

    func testHandleButtonTapWithFailedPaymentRequest() async {
        // Given
        let error = ApplePayRequestError.initialisingWalletToken(reason: "Test error")
        createPaymentRequestResult = .failure(error)

        let expectation = XCTestExpectation(description: "Payment request failure completion")
        setupViewModelWithExpectation(expectation: expectation)

        // When
        viewModel.handleButtonTap()

        // Wait for completion
        await fulfillment(of: [expectation], timeout: 2.0)

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

        // Wait a bit for the async presentation to complete
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

    func testPaymentAuthorizationControllerDidFinishWithSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "Success completion")
        setupViewModelForDidFinishTest(expectation: expectation)

        viewModel.paymentStatus = .success
        viewModel.chargeData = ChargeResponse(status: "success", amount: 100.0, currency: "USD")

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Wait for completion
        await fulfillment(of: [expectation], timeout: 2.0)

        // Then
        if case .success(let result) = completionResult {
            XCTAssertEqual(result.status, "success")
            XCTAssertEqual(result.amount, 100.0)
            XCTAssertEqual(result.currency, "USD")
        } else {
            XCTFail("Expected success completion result")
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithUserCancellation() async {
        // Given
        let expectation = XCTestExpectation(description: "User cancellation completion")
        setupViewModelForDidFinishTest(expectation: expectation)

        viewModel.paymentStatus = .failure
        viewModel.error = .userCanceledPayment

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Wait for completion
        await fulfillment(of: [expectation], timeout: 2.0)

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

    func testPaymentAuthorizationControllerDidFinishWithPaymentError() async {
        // Given
        let expectation = XCTestExpectation(description: "Payment error completion")
        setupViewModelWithExpectation(expectation: expectation)

        viewModel.paymentStatus = .failure
        viewModel.error = .unknownError(.connectionError(URLError(.networkConnectionLost)))

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Wait for completion with proper timeout
        await fulfillment(of: [expectation], timeout: 2.0)

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

    func testPaymentAuthorizationControllerDidFinishWithUnknownError() async {
        // Given
        let expectation = XCTestExpectation(description: "Unknown error completion")
        setupViewModelForDidFinishTest(expectation: expectation)

        viewModel.paymentStatus = .failure
        viewModel.error = nil

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Wait for completion
        await fulfillment(of: [expectation], timeout: 2.0)

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

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        viewModel = ApplePayVM(
            eventDelegate: eventDelegate,
            createPaymentRequest: { completion in
                let mockPaymentRequest = PKPaymentRequest()
                let result = ApplePayRequestResult(request: mockPaymentRequest, token: "test_token")
                completion(.success(result))
            },
            walletService: mockWalletService,
            completion: { result in
                self.completionResult = result
            }
        )

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "ApplePayCheckoutButton", action: .click)))
        viewModel.handleApplePayTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = ApplePayVM(
            eventDelegate: nil,
            createPaymentRequest: { completion in
                let mockPaymentRequest = PKPaymentRequest()
                let result = ApplePayRequestResult(request: mockPaymentRequest, token: "test_token")
                completion(.success(result))
            },
            walletService: mockWalletService,
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

    private func setupViewModelWithExpectation(expectation: XCTestExpectation) {
        viewModel = ApplePayVM(
            eventDelegate: eventDelegate,
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
                expectation.fulfill()
            })
    }

    private func setupViewModelForDidFinishTest(expectation: XCTestExpectation) {
        viewModel = ApplePayVM(
            eventDelegate: eventDelegate,
            createPaymentRequest: { completion in
                let mockPaymentRequest = PKPaymentRequest()
                let result = ApplePayRequestResult(request: mockPaymentRequest, token: "test_token")
                completion(.success(result))
            },
            walletService: mockWalletService,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            }
        )
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
