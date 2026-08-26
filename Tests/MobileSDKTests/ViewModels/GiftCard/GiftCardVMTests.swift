//
//  GiftCardVMTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
import Combine
import NetworkingLib
@testable import MobileSDK
@testable import DataPaymentSources

// swiftlint:disable all
@MainActor
class GiftCardVMTests: XCTestCase {

    var viewModel: GiftCardVM!
    var mockService: PaymentSourcesMockService!
    var viewState: ViewState!
    var config: GiftCardWidgetConfig!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var eventDelegate: WidgetEventDelegateUtil!
    var completionResult: Result<GiftCardResult, GiftCardError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockService = PaymentSourcesMockService()
        viewState = ViewState()
        config = GiftCardWidgetConfig(accessToken: "")
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()
        completionResult = nil
        viewModel = GiftCardVM(appearance: GiftCardWidgetAppearance(),
                               viewState: viewState,
                               paymentSourcesService: mockService,
                               config: config,
                               loadingDelegate: loadingDelegate,
                               eventDelegate: nil) { result in
            self.completionResult = result
        }
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        loadingDelegate = nil
        eventDelegate = nil
        completionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testInitialisationWithDelegateShowLoader() {
        XCTAssertEqual(viewModel.showLoaders, false)
    }

    func testInitialisationWithoutDelegateShowLoader() {
        viewModel = GiftCardVM(appearance: GiftCardWidgetAppearance(),
                               viewState: viewState,
                               paymentSourcesService: mockService,
                               config: config,
                               loadingDelegate: nil,
                               eventDelegate: nil) { result in
            self.completionResult = result
        }

        XCTAssertEqual(viewModel.showLoaders, true)
    }

    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = GiftCardVM(appearance: GiftCardWidgetAppearance(),
                               viewState: viewState,
                               paymentSourcesService: mockService,
                               config: config,
                               loadingDelegate: loadingDelegate,
                               eventDelegate: nil) { result in
            self.completionResult = result
        }

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        // isLoading is always kept accurate regardless of delegate presence, so it remains usable
        // as a re-entrancy guard; `showLoaders` (not this) is what suppresses the internal button's
        // own spinner when a delegate is supplied — see testShowLoadersFalseWithDelegate.
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(loadingDelegate.isLoading, true)
    }

    func testUpdateLoadingStateToTrueWithoutDelegate() {
        // Given
        viewModel = GiftCardVM(appearance: GiftCardWidgetAppearance(),
                               viewState: viewState,
                               paymentSourcesService: mockService,
                               config: config,
                               loadingDelegate: nil,
                               eventDelegate: nil) { result in
            self.completionResult = result
        }
        viewModel.isLoading = false
        loadingDelegate.isLoading = false

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(loadingDelegate.isLoading, false)
    }

    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = GiftCardVM(appearance: GiftCardWidgetAppearance(),
                               viewState: viewState,
                               paymentSourcesService: mockService,
                               config: config,
                               loadingDelegate: loadingDelegate,
                               eventDelegate: nil) { result in
            self.completionResult = result
        }
        viewModel.isLoading = false
        loadingDelegate.isLoading = true

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(loadingDelegate.isLoading, false)
    }

    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = GiftCardVM(appearance: GiftCardWidgetAppearance(),
                               viewState: viewState,
                               paymentSourcesService: mockService,
                               config: config,
                               loadingDelegate: nil,
                               eventDelegate: nil) { result in
            self.completionResult = result
        }
        viewModel.isLoading = true
        loadingDelegate.isLoading = false

        // When
        viewModel.updateLoadingState(isLoading: false)

        // Then
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(loadingDelegate.isLoading, false)
    }

    // MARK: - Helpers

    private func populateValidFormFields() {
        viewModel.giftCardFormManager.cardNumberText = "6034880000000018"
        viewModel.giftCardFormManager.pinText = "1234"
    }

    // swiftlint:disable:next nesting
    private class ErroringPaymentSourcesServiceMock: PaymentSourcesService {
        enum FailureType {
            case requestError(message: String, code: String)
            case connectionError(URLError)
            case genericError
        }

        var failure: FailureType

        init(failure: FailureType) {
            self.failure = failure
        }

        func createToken(tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String) async throws -> String {
            return ""
        }

        func createGiftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String) async throws -> String {
            switch failure {

            case .connectionError(let urlError):
                throw RequestError.connectionError(urlError)

            case .genericError:
                throw GiftCardError.unknownError(nil)

            default:
                throw GiftCardError.unknownError(nil)
            }
        }

        func createApplePayToken(tokeniseApplePayReq: DataPaymentSources.CreateApplePayTokenReq, widgetAccessToken: String) async throws -> String {
            return ""
        }

        func createSetupTokenData(req: CreatePayPalVaultSetupTokenReq, widgetAccessToken: String) async throws -> SetupTokenData {
            fatalError("Not implemented")
        }

        func createPaymentToken(request: CreatePayPalVaultPaymentTokenReq, setupToken: String, widgetAccessToken: String) async throws -> PaymentTokenData {
            fatalError("Not implemented")
        }

        func initialiseExternalCheckout(widgetAccessToken: String, request: CreateExternalCheckoutReq) async throws -> (link: String, checkoutToken: String) {
            fatalError("Not implemented")
        }

        func createPaymentSourceToken(checkoutToken: String, gatewayId: String, widgetAccessToken: String) async throws -> String {
            fatalError("Not implemented")
        }
    }

    // swiftlint:disable:next nesting
    /// Counts `createGiftCardToken` invocations, to verify `tokeniseGiftCard()`'s re-entrancy guard.
    private class CountingPaymentSourcesServiceMock: PaymentSourcesService {
        private(set) var createGiftCardTokenCallCount = 0

        func createToken(tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String) async throws -> String {
            return ""
        }

        func createGiftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String) async throws -> String {
            createGiftCardTokenCallCount += 1
            return "mock-gift-card-token"
        }

        func createApplePayToken(tokeniseApplePayReq: DataPaymentSources.CreateApplePayTokenReq, widgetAccessToken: String) async throws -> String {
            return ""
        }

        func createSetupTokenData(req: CreatePayPalVaultSetupTokenReq, widgetAccessToken: String) async throws -> SetupTokenData {
            fatalError("Not implemented")
        }

        func createPaymentToken(request: CreatePayPalVaultPaymentTokenReq, setupToken: String, widgetAccessToken: String) async throws -> PaymentTokenData {
            fatalError("Not implemented")
        }

        func initialiseExternalCheckout(widgetAccessToken: String, request: CreateExternalCheckoutReq) async throws -> (link: String, checkoutToken: String) {
            fatalError("Not implemented")
        }

        func createPaymentSourceToken(checkoutToken: String, gatewayId: String, widgetAccessToken: String) async throws -> String {
            fatalError("Not implemented")
        }
    }

    // MARK: - Re-entrancy

    func testTokeniseGiftCard_CalledTwiceBeforeTaskStarts_OnlyCallsServiceOnce() async {
        // Regression test: a fast double-submit (e.g. the internal button and an external
        // submitTrigger racing) must not fire two tokenisation requests.
        let countingService = CountingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Completion called")

        viewModel = GiftCardVM(
            appearance: GiftCardWidgetAppearance(),
            viewState: viewState,
            paymentSourcesService: countingService,
            config: config,
            loadingDelegate: nil,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        populateValidFormFields()

        viewModel.tokeniseGiftCard()
        // isLoading is now true synchronously (set before the Task is dispatched), so this second
        // call must be a no-op rather than racing the first.
        XCTAssertTrue(viewModel.isLoading)
        viewModel.tokeniseGiftCard()

        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertEqual(countingService.createGiftCardTokenCallCount, 1)
    }

    // MARK: - Completion Error Tests

    func testTokeniseGiftCard_CompletesWithUnknownError_OnConnectionError() async {
        // Given
        let urlError = URLError(.notConnectedToInternet)
        let failingService = ErroringPaymentSourcesServiceMock(failure: .connectionError(urlError))
        let expectation = XCTestExpectation(description: "Completion called with unknownError")

        viewModel = GiftCardVM(
            appearance: GiftCardWidgetAppearance(),
            viewState: viewState,
            paymentSourcesService: failingService,
            config: config,
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()

        // When
        viewModel.tokeniseGiftCard()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        switch completionResult {
        case .failure(let error):
            switch error {
            case .unknownError(let requestError):
                XCTAssertNotNil(requestError, "Expected wrapped RequestError in unknownError")
            default:
                XCTFail("Expected unknownError, got: \(error)")
            }
        default:
            XCTFail("Expected failure result")
        }

        // Loading state should be reset
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        let appearance = GiftCardWidgetAppearance()
        viewModel = GiftCardVM(
            appearance: appearance,
            viewState: viewState,
            paymentSourcesService: mockService,
            config: config,
            loadingDelegate: nil,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
            }

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "TokenisationButton", action: .click, text: appearance.actionButton.text))
        )
        viewModel.handleButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = GiftCardVM(
            appearance: GiftCardWidgetAppearance(),
            viewState: viewState,
            paymentSourcesService: mockService,
            config: config,
            loadingDelegate: nil,
            eventDelegate: nil) { result in
                self.completionResult = result
            }

        // Reset any events from initialization
        eventDelegate.reset()

        // For demonstration, we'll simulate what the view model would do:
        viewModel.tokeniseGiftCard()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }

    // MARK: - activePrimaryButton / isActionButtonDisabled

    private func makeVM(config: GiftCardWidgetConfig) -> GiftCardVM {
        GiftCardVM(
            appearance: GiftCardWidgetAppearance(),
            viewState: viewState,
            paymentSourcesService: mockService,
            config: config,
            loadingDelegate: nil,
            eventDelegate: nil) { result in
                self.completionResult = result
            }
    }

    func testConfig_activePrimaryButton_defaultsTrue() {
        XCTAssertTrue(GiftCardWidgetConfig(accessToken: "").activePrimaryButton)
        XCTAssertFalse(GiftCardWidgetConfig(accessToken: "", activePrimaryButton: false).activePrimaryButton)
    }

    func testIsActionButtonDisabled_ActivePrimaryTrue_InvalidForm_Enabled() {
        viewModel = makeVM(config: GiftCardWidgetConfig(accessToken: "", activePrimaryButton: true))
        // Empty/invalid form but the button stays enabled so validation runs on tap.
        XCTAssertFalse(viewModel.isActionButtonDisabled())
    }

    func testIsActionButtonDisabled_ActivePrimaryTrue_LoadingDisables() {
        viewModel = makeVM(config: GiftCardWidgetConfig(accessToken: "", activePrimaryButton: true))
        viewModel.updateLoadingState(isLoading: true)
        // Even in active mode, a re-tap is blocked while a request is in flight.
        XCTAssertTrue(viewModel.isActionButtonDisabled())
    }

    func testIsActionButtonDisabled_ActivePrimaryFalse_InvalidForm_Disabled() {
        viewModel = makeVM(config: GiftCardWidgetConfig(accessToken: "", activePrimaryButton: false))
        XCTAssertTrue(viewModel.isActionButtonDisabled())
    }

    func testIsActionButtonDisabled_ActivePrimaryFalse_ValidForm_Enabled() {
        viewModel = makeVM(config: GiftCardWidgetConfig(accessToken: "", activePrimaryButton: false))
        viewModel.giftCardFormManager.cardNumberText = "12345678901234"
        viewModel.giftCardFormManager.pinText = "1234"
        XCTAssertFalse(viewModel.isActionButtonDisabled())
    }

    // MARK: - Validation passthroughs

    func testValidationPassthroughs_MirrorFormManager() {
        viewModel = makeVM(config: GiftCardWidgetConfig(accessToken: "", activePrimaryButton: true))

        _ = viewModel.giftCardFormManager.validateForm() // invalid empty form

        XCTAssertEqual(viewModel.numberOfValidationErrors, viewModel.giftCardFormManager.numberOfValidationFailures)
        XCTAssertEqual(viewModel.numberOfValidationErrors, 2)
        XCTAssertEqual(viewModel.firstTextFieldWithError, viewModel.giftCardFormManager.firstFieldWithError)
        XCTAssertEqual(viewModel.firstTextFieldWithError, .cardNumber)
    }
}
// swiftlint:enable all
