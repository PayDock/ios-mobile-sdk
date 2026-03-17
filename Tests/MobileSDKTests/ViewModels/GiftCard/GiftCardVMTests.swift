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
        XCTAssertEqual(viewModel.isLoading, false)
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
}
// swiftlint:enable all
