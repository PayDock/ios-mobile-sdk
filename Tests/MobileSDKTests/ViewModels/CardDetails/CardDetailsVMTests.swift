//
//  CardDetailsVMTests.swift
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
                allowSaveCard: config
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
                WidgetEventButtonProperties(name: "TokenisationButton", action: .click, text: appearance.actionButton.text)))
        viewModel.handleTokenisationTapAnalytics()

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
}
// swiftlint:enable all
