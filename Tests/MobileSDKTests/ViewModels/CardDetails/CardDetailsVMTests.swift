//
//  CardDetailsVMTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import Combine
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataPaymentSources

// swiftlint:disable all
@MainActor
class CardDetailsVMTests: XCTestCase {
    private var viewModel: CardDetailsVM!
    private var mockService: PaymentSourcesMockService!
    private var config: SaveCardConfig!
    private var viewState: ViewState!
    private var loadingDelegate: WidgetLoadingDelegateUtil!
    private var eventDelegate: WidgetEventDelegateUtil!
    private var completionResult: Result<CardResult, CardDetailsError>?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockService = PaymentSourcesMockService()
        config = SaveCardConfig(
            consentText: "Remember",
            privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                privacyPolicyText: "Policy test",
                privacyPolicyURL: "https://www.example.com"))
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()
        completionResult = nil
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config,
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
        }
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        completionResult = nil
        loadingDelegate = nil
        eventDelegate = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testInitialisationWithOptionsStateNone() {
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    func testInitialisationWithOptionsStateDisabled() {
        viewModel = CardDetailsVM(paymentSourcesService: mockService,
                                  viewState: ViewState(state: .disabled),
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  appearance: CardDetailsWidgetAppearance(),
                                  loadingDelegate: loadingDelegate,
                                  eventDelegate: nil) { result in
            self.completionResult = result
        }

        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testInitialisationWithDelegateShowLoader() {
        XCTAssertEqual(viewModel.showLoaders, false)
    }

    func testInitialisationWithoutDelegateShowLoader() {
        viewModel = CardDetailsVM(paymentSourcesService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  appearance: CardDetailsWidgetAppearance(),
                                  loadingDelegate: nil,
                                  eventDelegate: nil) { result in
            self.completionResult = result
        }

        XCTAssertEqual(viewModel.showLoaders, true)
    }

    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = CardDetailsVM(paymentSourcesService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  appearance: CardDetailsWidgetAppearance(),
                                  loadingDelegate: loadingDelegate,
                                  eventDelegate: nil) { result in
            self.completionResult = result
        }

        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(loadingDelegate.isLoading, true)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToTrueWithoutDelegate() {
        // Given
        viewModel = CardDetailsVM(paymentSourcesService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  appearance: CardDetailsWidgetAppearance(),
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
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = CardDetailsVM(paymentSourcesService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  appearance: CardDetailsWidgetAppearance(),
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
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = CardDetailsVM(paymentSourcesService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  appearance: CardDetailsWidgetAppearance(),
                                  loadingDelegate: loadingDelegate,
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
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    // MARK: - Helpers

    private func populateValidFormFields() {
        viewModel.cardDetailsFormManager.cardNumberText = "4111111111111111"
        viewModel.cardDetailsFormManager.expiryDateText = "12/30"
        viewModel.cardDetailsFormManager.securityCodeText = "123"
    }

    
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
            switch failure {

            case .connectionError(let urlError):
                throw RequestError.connectionError(urlError)

            case .genericError:
                throw CardDetailsError.unknownError(nil)

            default:
                throw CardDetailsError.unknownError(nil)
            }
        }

        func createApplePayToken(tokeniseApplePayReq: DataPaymentSources.CreateApplePayTokenReq, widgetAccessToken: String) async throws -> String {
            return ""
        }

        func createGiftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String) async throws -> String {
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

    /// Counts `createToken` invocations, to verify `tokeniseCardDetails()`'s re-entrancy guard.
    private class CountingPaymentSourcesServiceMock: PaymentSourcesService {
        private(set) var createTokenCallCount = 0

        func createToken(tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String) async throws -> String {
            createTokenCallCount += 1
            return "mock-card-token"
        }

        func createApplePayToken(tokeniseApplePayReq: DataPaymentSources.CreateApplePayTokenReq, widgetAccessToken: String) async throws -> String {
            return ""
        }

        func createGiftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String) async throws -> String {
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

    func testTokeniseCardDetails_CalledTwiceBeforeTaskStarts_OnlyCallsServiceOnce() async {
        // Regression test: a fast double-submit (e.g. the internal button and an external
        // submitTrigger racing) must not fire two tokenisation requests.
        let countingService = CountingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Completion called")

        viewModel = CardDetailsVM(
            paymentSourcesService: countingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(gatewayId: "gatewayId", accessToken: "accessToken", collectCardholderName: false),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: nil,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
        }
        populateValidFormFields()

        viewModel.tokeniseCardDetails()
        // isLoading is now true synchronously (set before the Task is dispatched), so this second
        // call must be a no-op rather than racing the first.
        XCTAssertTrue(viewModel.isLoading)
        viewModel.tokeniseCardDetails()

        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertEqual(countingService.createTokenCallCount, 1)
    }

    func testTokeniseCardDetails_CompletesWithUnknownError_OnConnectionError() async {
        // Given
        let urlError = URLError(.notConnectedToInternet)
        let failingService = ErroringPaymentSourcesServiceMock(failure: .connectionError(urlError))
        let expectation = XCTestExpectation(description: "Completion called with unknownError")

        viewModel = CardDetailsVM(
            paymentSourcesService: failingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

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

    func testEventDelegateReceivesToknisationEvent() {
        // Given
        let appearance = CardDetailsWidgetAppearance()
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config
            ),
            appearance: appearance,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
        }

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(
            type: .button,
            properties: .button(
                WidgetEventButtonProperties(name: "TokenisationButton", action: .click, text: appearance.actionButton.text, formState: .valid)))
        viewModel.handleTokenisationTapAnalytics(isFormValid: true)

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateReceivesTokenisationEvent_InvalidFormState() {
        // Given
        let appearance = CardDetailsWidgetAppearance()
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config
            ),
            appearance: appearance,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
        }

        // Reset any events from initialization
        eventDelegate.reset()

        // When the button is tapped while the form is invalid, the event carries formState .invalid
        let event = WidgetEvent(
            type: .button,
            properties: .button(
                WidgetEventButtonProperties(name: "TokenisationButton", action: .click, text: appearance.actionButton.text, formState: .invalid)))
        viewModel.handleTokenisationTapAnalytics(isFormValid: false)

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateReceivesLinkTapEvent() {
        // Given
        let appearance = CardDetailsWidgetAppearance()
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config
            ),
            appearance: appearance,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
            }

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(
            type: .linkText,
            properties: .linkText(WidgetEventLinkTextProperties(name: "PrivacyPolicyLink", action: .click, url: "Some url")))
        viewModel.handleLinkTapAnalytics(url: "Some url")

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .linkText))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .linkText), 1)
    }

    func testEventDelegateReceivesToggleFlipEvent() {
        func testEventDelegateReceivesEvents() {
            // Given
            let appearance = CardDetailsWidgetAppearance()
            viewModel = CardDetailsVM(
                paymentSourcesService: mockService,
                viewState: viewState,
                config: CardDetailsWidgetConfig(
                    gatewayId: "gatewayId",
                    accessToken: "accessToken",
                    collectCardholderName: false,
                    allowSaveCard: config
                ),
                appearance: appearance,
                loadingDelegate: loadingDelegate,
                eventDelegate: eventDelegate) { result in
                    self.completionResult = result
            }

            // Reset any events from initialization
            eventDelegate.reset()

            // When
            let event = WidgetEvent(
                type: .toggle,
                properties: .toggle(WidgetEventToggleProperties(name: "SaveCardToggle", action: .click, state: false)))
            viewModel.handleToggleFlipAnalytics()

            // Then
            XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
            XCTAssertEqual(eventDelegate.lastEvent, event)
            XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
            XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
        }
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
        }

        // Reset any events from initialization
        eventDelegate.reset()

        // For demonstration, we'll simulate what the view model would do:
        viewModel.tokeniseCardDetails()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }

    // MARK: - Store Security Code Tests

    private class CapturingPaymentSourcesServiceMock: PaymentSourcesService {

        var capturedRequest: CreatePaymentSourceTokenReq?
        var tokenToReturn: String = "mock-token-123"

        func createToken(tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String) async throws -> String {
            capturedRequest = tokeniseCardDetailsReq
            return tokenToReturn
        }

        func createGiftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String) async throws -> String {
            return ""
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

    func testTokeniseCardDetails_WithStoreSecurityCodeNil_PassesNilToRequest() async {
        // Given
        let capturingService = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Tokenization completes")
        
        viewModel = CardDetailsVM(
            paymentSourcesService: capturingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: nil,
                storeSecurityCode: nil
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(capturingService.capturedRequest)
        XCTAssertNil(capturingService.capturedRequest?.storeCcv, "storeCcv should be nil when storeSecurityCode is nil")
    }

    func testTokeniseCardDetails_WithStoreSecurityCodeTrue_PassesTrueToRequest() async {
        // Given
        let capturingService = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Tokenization completes")
        
        viewModel = CardDetailsVM(
            paymentSourcesService: capturingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: nil,
                storeSecurityCode: true
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(capturingService.capturedRequest)
        XCTAssertEqual(capturingService.capturedRequest?.storeCcv, true, "storeCcv should be true when storeSecurityCode is true")
    }

    func testTokeniseCardDetails_WithStoreSecurityCodeFalse_PassesFalseToRequest() async {
        // Given
        let capturingService = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Tokenization completes")
        
        viewModel = CardDetailsVM(
            paymentSourcesService: capturingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: nil,
                storeSecurityCode: false
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(capturingService.capturedRequest)
        XCTAssertEqual(capturingService.capturedRequest?.storeCcv, false, "storeCcv should be false when storeSecurityCode is false")
    }

    // MARK: - Save Card Consent Tests

    func testTokeniseCardDetails_WithAllowSaveCardNil_PassesNilToRequest() async {
        // Given
        let capturingService = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Tokenization completes")
        
        viewModel = CardDetailsVM(
            paymentSourcesService: capturingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: nil,
                storeSecurityCode: nil
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(capturingService.capturedRequest)
        XCTAssertNil(capturingService.capturedRequest?.savedCardConsentAccepted, "savedCardConsentAccepted should be nil when allowSaveCard is nil")
    }

    func testTokeniseCardDetails_WithSaveCardToggleOn_PassesTrueToRequest() async {
        // Given
        let capturingService = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Tokenization completes")
        
        viewModel = CardDetailsVM(
            paymentSourcesService: capturingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config,
                storeSecurityCode: nil
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()
        viewModel.policyAccepted = true

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(capturingService.capturedRequest)
        XCTAssertEqual(capturingService.capturedRequest?.savedCardConsentAccepted, true, "savedCardConsentAccepted should be true when save card toggle is on")
    }

    func testTokeniseCardDetails_WithSaveCardToggleOff_PassesFalseToRequest() async {
        // Given
        let capturingService = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "Tokenization completes")
        
        viewModel = CardDetailsVM(
            paymentSourcesService: capturingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                collectCardholderName: false,
                allowSaveCard: config,
                storeSecurityCode: nil
            ),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        populateValidFormFields()
        viewModel.policyAccepted = false

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(capturingService.capturedRequest)
        XCTAssertEqual(capturingService.capturedRequest?.savedCardConsentAccepted, false, "savedCardConsentAccepted should be false when save card toggle is off")
    }

    // MARK: - Helpers (Part A additions)

    private func makeConfig(collectName: Bool = false,
                            allowSaveCard saveCard: SaveCardConfig? = nil,
                            activePrimaryButton: Bool = true,
                            storeSecurityCode: Bool? = nil) -> CardDetailsWidgetConfig {
        CardDetailsWidgetConfig(
            gatewayId: "gatewayId",
            accessToken: "accessToken",
            collectCardholderName: collectName,
            allowSaveCard: saveCard,
            storeSecurityCode: storeSecurityCode,
            activePrimaryButton: activePrimaryButton)
    }

    private func makeVM(service: PaymentSourcesService,
                        config: CardDetailsWidgetConfig,
                        viewState: ViewState? = nil,
                        event: WidgetEventDelegateUtil? = nil) -> CardDetailsVM {
        CardDetailsVM(
            paymentSourcesService: service,
            viewState: viewState ?? ViewState(),
            config: config,
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: event) { result in
                self.completionResult = result
            }
    }

    // MARK: - Tokenisation result mapping

    func testTokeniseCardDetails_Success_CompletesWithCardResult() async {
        // Given
        mockService.tokenResult = "tok_success_123"
        let expectation = XCTestExpectation(description: "success")
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: makeConfig(allowSaveCard: nil),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .success(let cardResult) = completionResult else {
            return XCTFail("Expected success, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(cardResult.token, "tok_success_123")
        XCTAssertNil(cardResult.saveCard, "saveCard should be nil when allowSaveCard is nil")
        XCTAssertEqual(viewModel.isLoading, false)
    }

    func testTokeniseCardDetails_Success_SaveCardOn_ResultSaveCardTrue() async {
        mockService.tokenResult = "tok_1"
        let expectation = XCTestExpectation(description: "success")
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: makeConfig(allowSaveCard: config),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        populateValidFormFields()
        viewModel.policyAccepted = true

        viewModel.tokeniseCardDetails()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .success(let cardResult) = completionResult else {
            return XCTFail("Expected success")
        }
        XCTAssertEqual(cardResult.saveCard, true)
    }

    func testTokeniseCardDetails_Success_SaveCardOff_ResultSaveCardFalse() async {
        mockService.tokenResult = "tok_1"
        let expectation = XCTestExpectation(description: "success")
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: makeConfig(allowSaveCard: config),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        populateValidFormFields()
        viewModel.policyAccepted = false

        viewModel.tokeniseCardDetails()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .success(let cardResult) = completionResult else {
            return XCTFail("Expected success")
        }
        XCTAssertEqual(cardResult.saveCard, false)
    }

    func testTokeniseCardDetails_RequestError_MapsToErrorTokenisingCard() async {
        // Given a structured API error from the service
        mockService.shouldReturnError = true
        mockService.errorToReturn = ErrorRes(
            status: 400,
            error: .init(message: "Card declined", code: "E123", details: nil),
            resource: nil,
            errorSummary: nil)
        let expectation = XCTestExpectation(description: "failure")
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: makeConfig(),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(let error) = completionResult,
              case .errorTokenisingCard(let errorRes) = error else {
            return XCTFail("Expected errorTokenisingCard, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(errorRes.error?.message, "Card declined")
        XCTAssertEqual(error.code, "CARD_TOKENISE_ERROR")
    }

    func testTokeniseCardDetails_ResponseDecodeFailure_IsIdentifiable() async {
        // Given the networking layer surfaces a response-schema mismatch as RequestError.decode
        mockService.cardTokenErrorToThrow = RequestError.decode(nil)
        let expectation = XCTestExpectation(description: "failure")
        viewModel = CardDetailsVM(
            paymentSourcesService: mockService,
            viewState: viewState,
            config: makeConfig(),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        populateValidFormFields()

        // When
        viewModel.tokeniseCardDetails()

        // Then — maps to unknownError, preserving the decode class via a stable, identifiable code
        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(let error) = completionResult,
              case .unknownError(let requestError) = error else {
            return XCTFail("Expected unknownError, got: \(String(describing: completionResult))")
        }
        guard case .decode = requestError else {
            return XCTFail("Expected wrapped RequestError.decode")
        }
        XCTAssertEqual(error.code, "CARD_RESPONSE_DECODE")
    }

    func testTokeniseCardDetails_RequestMapping_StripsPanSpaces_SplitsExpiry_TrimsName() async {
        // Given
        let capturing = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "completes")
        viewModel = CardDetailsVM(
            paymentSourcesService: capturing,
            viewState: viewState,
            config: makeConfig(collectName: true),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        viewModel.cardDetailsFormManager.cardholderNameText = "  John Doe  "
        viewModel.cardDetailsFormManager.cardNumberText = "4111 1111 1111 1111"
        viewModel.cardDetailsFormManager.expiryDateText = "12/30"
        viewModel.cardDetailsFormManager.securityCodeText = "123"

        // When
        viewModel.tokeniseCardDetails()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        let req = capturing.capturedRequest
        XCTAssertEqual(req?.cardNumber, "4111111111111111", "spaces should be stripped from PAN")
        XCTAssertEqual(req?.expireMonth, "12")
        XCTAssertEqual(req?.expireYear, "30")
        XCTAssertEqual(req?.cardName, "John Doe", "cardholder name should be trimmed")
        XCTAssertEqual(req?.gatewayId, "gatewayId")
    }

    func testTokeniseCardDetails_EmptyName_PassesNilCardName() async {
        let capturing = CapturingPaymentSourcesServiceMock()
        let expectation = XCTestExpectation(description: "completes")
        viewModel = CardDetailsVM(
            paymentSourcesService: capturing,
            viewState: viewState,
            config: makeConfig(collectName: true),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
                expectation.fulfill()
            }
        viewModel.cardDetailsFormManager.cardholderNameText = "   " // whitespace only
        viewModel.cardDetailsFormManager.cardNumberText = "4111111111111111"
        viewModel.cardDetailsFormManager.expiryDateText = "12/30"
        viewModel.cardDetailsFormManager.securityCodeText = "123"

        viewModel.tokeniseCardDetails()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNil(capturing.capturedRequest?.cardName, "blank cardholder name should map to nil")
    }

    // MARK: - ctaButtonTapped

    func testCtaButtonTapped_InvalidForm_ReturnsFalse_DoesNotTokenise_FiresInvalidAnalytics() {
        // Given an empty (invalid) form
        let capturing = CapturingPaymentSourcesServiceMock()
        eventDelegate.reset()
        viewModel = makeVM(service: capturing, config: makeConfig(), event: eventDelegate)

        // When
        let started = viewModel.ctaButtonTapped()

        // Then
        XCTAssertFalse(started, "should return false for an invalid form")
        XCTAssertNil(capturing.capturedRequest, "tokenisation must not run for an invalid form")
        guard case .button(let props)? = eventDelegate.lastEvent?.properties else {
            return XCTFail("Expected a button analytics event")
        }
        XCTAssertEqual(props.formState, .invalid)
    }

    func testCtaButtonTapped_ValidForm_ReturnsTrue_FiresValidAnalytics() {
        eventDelegate.reset()
        viewModel = makeVM(service: mockService, config: makeConfig(), event: eventDelegate)
        populateValidFormFields()

        let started = viewModel.ctaButtonTapped()

        XCTAssertTrue(started, "should return true for a valid form")
        guard case .button(let props)? = eventDelegate.lastEvent?.properties else {
            return XCTFail("Expected a button analytics event")
        }
        XCTAssertEqual(props.formState, .valid)
    }

    // MARK: - isActionButtonDisabled

    func testIsActionButtonDisabled_ActivePrimaryButtonTrue_AlwaysEnabled() {
        viewModel = makeVM(service: mockService, config: makeConfig(activePrimaryButton: true))
        // Even with an empty/invalid form the button stays enabled.
        XCTAssertFalse(viewModel.isActionButtonDisabled())
    }

    func testIsActionButtonDisabled_ActivePrimaryFalse_InvalidForm_Disabled() {
        viewModel = makeVM(service: mockService, config: makeConfig(activePrimaryButton: false))
        XCTAssertTrue(viewModel.isActionButtonDisabled(), "invalid form should disable the button")
    }

    func testIsActionButtonDisabled_ActivePrimaryFalse_ValidForm_Enabled() {
        viewModel = makeVM(service: mockService, config: makeConfig(activePrimaryButton: false))
        populateValidFormFields()
        XCTAssertFalse(viewModel.isActionButtonDisabled(), "valid form should enable the button")
    }

    func testIsActionButtonDisabled_ActivePrimaryFalse_ViewStateDisabled_Disabled() {
        viewModel = makeVM(service: mockService,
                           config: makeConfig(activePrimaryButton: false),
                           viewState: ViewState(state: .disabled))
        populateValidFormFields()
        XCTAssertTrue(viewModel.isActionButtonDisabled(), "disabled view state should disable the button even when valid")
    }

    // MARK: - isValidURLString

    func testIsValidURLString() {
        viewModel = makeVM(service: mockService, config: makeConfig())
        XCTAssertTrue(viewModel.isValidURLString("https://www.example.com"))
        XCTAssertTrue(viewModel.isValidURLString("http://example.com/policy"))
        XCTAssertFalse(viewModel.isValidURLString("not a url"))
        XCTAssertFalse(viewModel.isValidURLString(""))
        XCTAssertFalse(viewModel.isValidURLString(nil))
    }
}
// swiftlint:enable all
