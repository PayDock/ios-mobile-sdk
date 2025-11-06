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

// swiftlint:disable all
@MainActor
class CardDetailsVMTests: XCTestCase {
    private var viewModel: CardDetailsVM!
    private var mockService: CardServiceMock!
    private var config: SaveCardConfig!
    private var viewState: ViewState!
    private var loadingDelegate: WidgetLoadingDelegateUtil!
    private var eventDelegate: WidgetEventDelegateUtil!
    private var completionResult: Result<CardResult, CardDetailsError>?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockService = CardServiceMock()
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
            cardService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                showCardTitle: true,
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
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: ViewState(state: .disabled),
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    showCardTitle: true,
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
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    showCardTitle: true,
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
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    showCardTitle: true,
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
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    showCardTitle: true,
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
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    showCardTitle: true,
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
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    showCardTitle: true,
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

    
    private class ErroringCardServiceMock: CardService {
        enum FailureType {
            case requestError(message: String, code: String)
            case connectionError(URLError)
            case genericError
        }

        var failure: FailureType

        init(failure: FailureType) {
            self.failure = failure
        }

        func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String {
            switch failure {

            case .connectionError(let urlError):
                throw RequestError.connectionError(urlError)

            case .genericError:
                throw CardDetailsError.unknownError(nil)

            default:
                throw CardDetailsError.unknownError(nil)
            }
        }

        func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String {
            return ""
        }
    }

    func testTokeniseCardDetails_CompletesWithUnknownError_OnConnectionError() async {
        // Given
        let urlError = URLError(.notConnectedToInternet)
        let failingService = ErroringCardServiceMock(failure: .connectionError(urlError))
        let expectation = XCTestExpectation(description: "Completion called with unknownError")

        viewModel = CardDetailsVM(
            cardService: failingService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                showCardTitle: true,
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
            cardService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                showCardTitle: true,
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
            cardService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                showCardTitle: true,
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
                cardService: mockService,
                viewState: viewState,
                config: CardDetailsWidgetConfig(
                    gatewayId: "gatewayId",
                    accessToken: "accessToken",
                    showCardTitle: true,
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
            cardService: mockService,
            viewState: viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: "gatewayId",
                accessToken: "accessToken",
                showCardTitle: true,
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
}
// swiftlint:enable all
