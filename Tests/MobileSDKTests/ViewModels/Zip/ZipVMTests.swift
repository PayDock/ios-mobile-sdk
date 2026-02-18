//
//  ZipVMTests.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//

// swiftlint:disable file_length
import XCTest
import Combine
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataPaymentSources

@MainActor
class ZipVMTests: XCTestCase {

    var viewModel: ZipVM!
    var mockPaymentSourcesService: PaymentSourcesMockService!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var eventDelegate: WidgetEventDelegateUtil!
    var config: ZipWidgetConfig!
    var completionResult: Result<String, ZipError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockPaymentSourcesService = PaymentSourcesMockService()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()
        completionResult = nil

        // Create test configuration
        config = ZipWidgetConfig(
            accessToken: "test_access_token",
            gatewayId: "test_gateway_id",
            amount: 100.00,
            currency: "AUD",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+1234567890",
            tokenize: true,
            billing: ZipWidgetConfig.Address(
                firstName: "John",
                lastName: "Doe",
                line1: "123 Main St",
                city: "Sydney",
                state: "NSW",
                postcode: "2000",
                country: "AU"
            ),
            items: [
                ZipWidgetConfig.Item(
                    name: "Test Product",
                    amount: "100.00",
                    quantity: 1,
                    reference: "ITEM-001"
                )
            ]
        )

        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
    }

    override func tearDown() {
        viewModel = nil
        mockPaymentSourcesService = nil
        viewState = nil
        loadingDelegate = nil
        eventDelegate = nil
        config = nil
        completionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithDefaultState() {
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showLoaders) // False because loadingDelegate is present
        XCTAssertFalse(viewModel.showCancelConfirmation)
        XCTAssertNil(viewModel.zipUrl)
    }

    func testInitializationWithDisabledState() {
        viewModel = ZipVM(
            viewState: ViewState(state: .disabled),
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testInitializationWithLoadingDelegate() {
        XCTAssertFalse(viewModel.showLoaders) // False because loadingDelegate is present
        XCTAssertNotNil(loadingDelegate)
    }

    func testInitializationWithoutLoadingDelegate() {
        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            loadingDelegate: nil,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        XCTAssertTrue(viewModel.showLoaders)
    }

    func testInitializationWithoutEventDelegate() {
        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
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
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertEqual(loadingDelegate.isLoading, true)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel.updateLoadingState(isLoading: true)

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(loadingDelegate.isLoading, false)
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    func testUpdateLoadingStateWithoutDelegate() {
        // Given
        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            loadingDelegate: nil,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    // MARK: - Create Zip Checkout Tests

    func testCreateZipCheckoutSuccess() async {
        // Given
        let expectedUrl = "https://test.zip.co/checkout?token=test_token"
        let expectedCheckoutToken = "checkout_token_123"
        mockPaymentSourcesService.externalCheckoutResult = (link: expectedUrl, checkoutToken: expectedCheckoutToken)

        // When
        viewModel.createZipCheckout()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showWebView)
        XCTAssertEqual(viewModel.zipUrl?.absoluteString, expectedUrl)
    }

    func testCreateZipCheckoutUnknownError() async {
        // Given
        mockPaymentSourcesService.shouldThrowUnknownError = true

        // When
        viewModel.createZipCheckout()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNotNil(completionResult)

        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .unknownError = error else {
            XCTFail("Expected unknownError")
            return
        }
    }

    func testCreateZipCheckoutFailsWithInvalidUrl() async {
        // Given - API returns a malformed URL missing "://" (scheme is "httpsandbox" not "https")
        let malformedUrl = "httpsandbox.zip.co/checkout?co=co_test&m=1234"
        mockPaymentSourcesService.externalCheckoutResult = (link: malformedUrl, checkoutToken: "token")

        // When
        viewModel.createZipCheckout()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNil(viewModel.zipUrl)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure")
            return
        }
        guard case .invalidCheckoutUrl = error else {
            XCTFail("Expected invalidCheckoutUrl, got \(error)")
            return
        }
    }

    func testCreateZipCheckoutFailsWithBlankUrl() async {
        // Given - API returns blank URL (URL(string:) returns nil)
        mockPaymentSourcesService.externalCheckoutResult = (link: "", checkoutToken: "token")

        // When
        viewModel.createZipCheckout()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNil(viewModel.zipUrl)
        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure")
            return
        }
        guard case .invalidCheckoutUrl = error else {
            XCTFail("Expected invalidCheckoutUrl, got \(error)")
            return
        }
    }

    // MARK: - Handle Button Tap Tests

    func testHandleButtonTap() async {
        // Given
        mockPaymentSourcesService.externalCheckoutResult = (link: "https://test.zip.co/checkout", checkoutToken: "checkout_token")

        // When
        viewModel.handleButtonTap()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertTrue(viewModel.showWebView)
    }

    // MARK: - Handle Zip Confirmation Tests

    func testHandleZipConfirmationSuccess() async {
        // Given - First create checkout to get checkout token
        mockPaymentSourcesService.externalCheckoutResult = (link: "https://test.zip.co/checkout", checkoutToken: "checkout_token_123")
        mockPaymentSourcesService.paymentSourceTokenResult = "payment_source_token_456"

        viewModel.createZipCheckout()
        try? await Task.sleep(nanoseconds: 100_000_000)

        let callbackData = ZipCallbackData(
            status: .approved,
            checkoutId: "checkout_id_789",
            orderId: "order_id_101"
        )

        // When
        viewModel.handleZipConfirmation(callbackData: callbackData)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNotNil(completionResult)

        guard case .success(let token) = completionResult else {
            XCTFail("Expected success result")
            return
        }

        XCTAssertEqual(token, "payment_source_token_456")
    }

    func testHandleZipConfirmationWithoutCheckoutToken() {
        // Given - No checkout token (createZipCheckout not called)
        let callbackData = ZipCallbackData(
            status: .approved,
            checkoutId: "checkout_id_789",
            orderId: nil
        )

        // When
        viewModel.handleZipConfirmation(callbackData: callbackData)

        // Then
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNotNil(completionResult)

        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .unknownError = error else {
            XCTFail("Expected unknownError")
            return
        }
    }

    func testHandleZipConfirmationRequestError() async {
        // Given - Setup checkout token first
        mockPaymentSourcesService.externalCheckoutResult = (link: "https://test.zip.co/checkout", checkoutToken: "checkout_token_123")

        viewModel.createZipCheckout()
        try? await Task.sleep(nanoseconds: 100_000_000)

        let errorRes = ErrorRes(
            status: 500,
            error: .init(message: "Payment source creation failed", code: "TOKEN_ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = errorRes

        let callbackData = ZipCallbackData(
            status: .approved,
            checkoutId: "checkout_id_789",
            orderId: nil
        )

        // When
        viewModel.handleZipConfirmation(callbackData: callbackData)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNotNil(completionResult)

        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .errorCapturingCharge(let actualErrorRes) = error else {
            XCTFail("Expected errorCapturingCharge error")
            return
        }

        XCTAssertEqual(actualErrorRes.status, 500)
    }

    func testHandleZipConfirmationUnknownPaymentTokenError() async {
        // Given - Setup checkout token first
        mockPaymentSourcesService.externalCheckoutResult = (link: "https://test.zip.co/checkout", checkoutToken: "checkout_token_123")

        viewModel.createZipCheckout()
        try? await Task.sleep(nanoseconds: 100_000_000)

        mockPaymentSourcesService.shouldThrowUnknownError = true

        let callbackData = ZipCallbackData(
            status: .approved,
            checkoutId: "checkout_id_789",
            orderId: nil
        )

        // When
        viewModel.handleZipConfirmation(callbackData: callbackData)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNotNil(completionResult)

        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .unknownError = error else {
            XCTFail("Expected unknownError")
            return
        }
    }

    // MARK: - Handle WebView Failure Tests

    func testHandleWebViewFailure() {
        // Given
        let error = ZipError.webViewFailed(error: NSError(domain: "test", code: -1, userInfo: nil))

        // When
        viewModel.handleWebViewFailure(error)

        // Then
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNotNil(completionResult)

        guard case .failure(let actualError) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .webViewFailed = actualError else {
            XCTFail("Expected webViewFailed error")
            return
        }
    }

    func testHandleWebViewFailureTransactionCanceled() {
        // Given
        let error = ZipError.transactionCanceled(checkoutId: "checkout_123")

        // When
        viewModel.handleWebViewFailure(error)

        // Then
        XCTAssertFalse(viewModel.showWebView)
        XCTAssertNotNil(completionResult)

        guard case .failure(let actualError) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .transactionCanceled(let checkoutId) = actualError else {
            XCTFail("Expected transactionCanceled error")
            return
        }

        XCTAssertEqual(checkoutId, "checkout_123")
    }

    // MARK: - Handle Sheet Cancellation Tests

    func testHandleSheetCancellation() {
        // When
        viewModel.handleSheetCancellation()

        // Then
        XCTAssertNotNil(completionResult)

        guard case .failure(let error) = completionResult else {
            XCTFail("Expected failure result")
            return
        }

        guard case .transactionCanceled(let checkoutId) = error else {
            XCTFail("Expected transactionCanceled error")
            return
        }

        XCTAssertNil(checkoutId, "Manual cancellation should not have checkoutId")
    }

    // MARK: - Configuration Tests

    func testConfigurationIsProperlySet() {
        XCTAssertEqual(config.gatewayId, "test_gateway_id")
        XCTAssertEqual(config.accessToken, "test_access_token")
        XCTAssertEqual(config.amount, 100.00)
        XCTAssertEqual(config.currency, "AUD")
        XCTAssertEqual(config.firstName, "John")
        XCTAssertEqual(config.lastName, "Doe")
        XCTAssertEqual(config.email, "john.doe@example.com")
        XCTAssertEqual(config.items?.count, 1)
        XCTAssertEqual(config.items?[0].name, "Test Product")
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

    func testShowCancelConfirmationInitiallyFalse() {
        XCTAssertFalse(viewModel.showCancelConfirmation)
    }

    func testShowCancelConfirmationCanBeUpdated() {
        // Given
        XCTAssertFalse(viewModel.showCancelConfirmation)

        // When
        viewModel.showCancelConfirmation = true

        // Then
        XCTAssertTrue(viewModel.showCancelConfirmation)
    }

    // MARK: - Error Recovery Tests

    func testErrorRecoveryAfterFailedCheckout() async {
        // Given - Initial failure
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = ErrorRes(
            status: 400,
            error: .init(message: "Initial error", code: "ERROR", details: nil),
            resource: nil,
            errorSummary: nil
        )

        viewModel.createZipCheckout()
        try? await Task.sleep(nanoseconds: 100_000_000)

        let initialError = completionResult

        // When - Retry with success
        completionResult = nil
        mockPaymentSourcesService.shouldReturnError = false
        mockPaymentSourcesService.externalCheckoutResult = (link: "https://test.zip.co/checkout", checkoutToken: "checkout_token")

        viewModel.createZipCheckout()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(initialError)
        guard case .failure = initialError else {
            XCTFail("Expected initial failure")
            return
        }

        // Should be successful on retry
        XCTAssertTrue(viewModel.showWebView)
        XCTAssertNotNil(viewModel.zipUrl)
    }

    // MARK: - Completion Handler Tests

    func testCompletionHandlerCalledOnlyOncePerError() {
        // Given
        var completionCallCount = 0
        let expectation = self.expectation(description: "Completion called once")

        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { _ in
                completionCallCount += 1
                expectation.fulfill()
            }
        )

        // When
        viewModel.handleSheetCancellation()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(completionCallCount, 1)
    }

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
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
            properties: .button(WidgetEventButtonProperties(name: "ZipCheckoutButton", action: .click)))
        viewModel.handleZipButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        // When - The view model should handle nil event delegate gracefully
        viewModel.handleZipButtonTapAnalytics()

        // Then - No events should be recorded in our test delegate
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }

    func testEventDelegateButtonTapEventDetails() {
        // Given
        viewModel = ZipVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )

        eventDelegate.reset()

        // When
        viewModel.handleZipButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)

        guard let event = eventDelegate.lastEvent else {
            XCTFail("Expected event to be recorded")
            return
        }

        XCTAssertEqual(event.type, .button)

        if case .button(let properties) = event.properties {
            XCTAssertEqual(properties.name, "ZipCheckoutButton")
            XCTAssertEqual(properties.action, .click)
        } else {
            XCTFail("Expected button event properties")
        }
    }
}
