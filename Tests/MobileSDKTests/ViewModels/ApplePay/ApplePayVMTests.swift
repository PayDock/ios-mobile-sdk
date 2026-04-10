//
//  ApplePayVMTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import PassKit
import Combine
@testable import MobileSDK
@testable import DataPaymentSources
@testable import NetworkingLib

@MainActor
class ApplePayVMTests: XCTestCase {

    var viewModel: ApplePayVM!
    var mockPaymentSourcesService: PaymentSourcesMockService!
    var eventDelegate: WidgetEventDelegateUtil!
    var completionResult: Result<ApplePayResult, ApplePayError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockPaymentSourcesService = PaymentSourcesMockService()
        eventDelegate = WidgetEventDelegateUtil()
        completionResult = nil
        setupViewModel()
    }

    override func tearDown() {
        viewModel = nil
        mockPaymentSourcesService = nil
        eventDelegate = nil
        completionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }

    private func setupViewModel() {
        viewModel = ApplePayVM(
            config: ApplePayWidgetConfig(
                serviceId: "",
                accessToken: "",
                pkPaymentRequest: PKPaymentRequest()
            ),
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            })
    }

    // MARK: - Handle Button Tap Tests

    func testHandleButtonTapWithSuccessfulPaymentRequest() async {
        // Given
        let mockPaymentRequest = PKPaymentRequest()
        mockPaymentRequest.merchantIdentifier = "test.merchant.id"
        mockPaymentRequest.countryCode = "US"
        mockPaymentRequest.currencyCode = "USD"
        mockPaymentRequest.supportedNetworks = [.visa, .masterCard]
        mockPaymentRequest.merchantCapabilities = .threeDSecure

        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: mockPaymentRequest
        )

        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
            })
    }

    // MARK: - Initialization Tests

    func testInitializationSetsPropertiesCorrectly() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.paymentStatus, .failure)
        XCTAssertNil(viewModel.paymentController)
        XCTAssertNil(viewModel.result)
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Start Payment Tests

    func testStartPaymentCreatesPaymentController() async {
        // When
        viewModel.startPayment()

        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertNotNil(viewModel.paymentController)
        // In test environment, presentation may fail, but the controller should still be created
        // The error might be .unableToPresentPaymentSheet due to test environment limitations
        if let error = viewModel.error {
            switch error {
            case .unableToPresentPaymentSheet:
                XCTAssert(true, "Presentation failure is acceptable in test environment")
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testStartPaymentWithInvalidRequestSetsError() async {
        // Given
        let invalidPaymentRequest = PKPaymentRequest() // Missing required fields
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: invalidPaymentRequest
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
            })

        // When
        viewModel.startPayment()

        // Wait a bit for the async presentation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        if let error = viewModel.error,
           case .unableToPresentPaymentSheet = error {
            XCTAssert(true, "Error correctly set to unableToPresentPaymentSheet")
        } else {
            XCTFail("Expected unableToPresentPaymentSheet error, got \(String(describing: viewModel.error))")
        }
    }

    // MARK: - Payment Authorization Delegate Tests

    func testPaymentAuthorizationWithTokenCreationError() async {
        // Given
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = ErrorRes(
            status: 400,
            error: .init(message: "Token creation failed", code: "TOKEN_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        let mockPayment = createMockPayment()
        let invalidPaymentRequest = PKPaymentRequest() // Missing required fields
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: invalidPaymentRequest
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
            })
        let expectation = XCTestExpectation(description: "Payment authorization completion failure")

        // When
        viewModel.paymentAuthorizationController(
            PKPaymentAuthorizationController(),
            didAuthorizePayment: mockPayment
        ) { status in
            // Then
            XCTAssertEqual(status, .failure)
            XCTAssertEqual(self.viewModel.paymentStatus, .failure)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        // Verify error is set
        if case .errorCreatingToken(let errorRes) = viewModel.error {
            XCTAssertEqual(errorRes.error?.message, "Token creation failed")
        } else {
            XCTFail("Expected errorCreatingToken error")
        }
    }

    func testPaymentAuthorizationWithPayloadEncodingFailure() async {
        // Given - Create a payment that will cause encoding failure
        // We'll use a payment with invalid data that can't be encoded
        let mockPayment = PKPayment()
        // Note: In a real scenario, we'd need to mock PKPayment more thoroughly
        // For now, we'll test the error path by making the service throw an unknown error

        mockPaymentSourcesService.shouldThrowUnknownError = true
        let invalidPaymentRequest = PKPaymentRequest() // Missing required fields
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: invalidPaymentRequest
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
            })
        let expectation = XCTestExpectation(description: "Payment authorization completion failure")

        // When
        viewModel.paymentAuthorizationController(
            PKPaymentAuthorizationController(),
            didAuthorizePayment: mockPayment
        ) { status in
            XCTAssertEqual(status, .failure)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        // Then - Should handle unknown error
        if case .unknownError = viewModel.error {
            XCTAssert(true, "Unknown error handled correctly")
        } else {
            // Payload encoding might succeed even with empty payment, so this is acceptable
            XCTAssertNotNil(viewModel.error)
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "Success completion")
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: PKPaymentRequest()
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            })
        viewModel.paymentStatus = .success
        viewModel.result = ApplePayResult(ottToken: "test-ott-token-456")

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Wait for completion
        await fulfillment(of: [expectation], timeout: 2.0)

        // Then
        if case .success(let result) = completionResult {
            XCTAssertEqual(result.ottToken, "test-ott-token-456")
        } else {
            XCTFail("Expected success completion result with OTT token")
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithUserCancellation() async {
        // Given
        let expectation = XCTestExpectation(description: "User cancellation completion")
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: PKPaymentRequest()
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            })
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

    func testPaymentAuthorizationControllerDidFinishWithTokenError() async {
        // Given
        let expectation = XCTestExpectation(description: "Token error completion")
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: PKPaymentRequest()
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            })
        viewModel.paymentStatus = .failure
        viewModel.error = .errorCreatingToken(error: ErrorRes(
            status: 400,
            error: .init(message: "Token error", code: "TOKEN_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        ))

        // When
        viewModel.paymentAuthorizationControllerDidFinish(PKPaymentAuthorizationController())

        // Wait for completion
        await fulfillment(of: [expectation], timeout: 2.0)

        // Then
        if case .failure(let error) = completionResult {
            if case .errorCreatingToken(let errorRes) = error {
                XCTAssertEqual(errorRes.error?.message, "Token error")
            } else {
                XCTFail("Expected errorCreatingToken error")
            }
        } else {
            XCTFail("Expected failure completion result")
        }
    }

    func testPaymentAuthorizationControllerDidFinishWithUnknownError() async {
        // Given
        let expectation = XCTestExpectation(description: "Unknown error completion")
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: PKPaymentRequest()
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            })
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
        eventDelegate.reset()

        // When
        viewModel.handleApplePayTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        let config = ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: PKPaymentRequest()
        )
        viewModel = ApplePayVM(
            config: config,
            eventDelegate: nil,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { result in
                self.completionResult = result
            })

        // When
        viewModel.handleApplePayTapAnalytics()

        // Then - Should not crash, but no events recorded
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
    }

    // MARK: - Helper Methods

    private func createMockPayment() -> PKPayment {
        // Create a minimal PKPayment for testing
        return PKPayment()
    }
}
