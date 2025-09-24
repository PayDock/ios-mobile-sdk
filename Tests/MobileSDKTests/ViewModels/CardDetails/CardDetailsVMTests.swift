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
    var viewModel: CardDetailsVM!
    var mockService: CardServiceMock!
    var config: SaveCardConfig!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var completionResult: Result<CardResult, CardDetailsError>?
    var cancellables = Set<AnyCancellable>()

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
        completionResult = nil
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  config: CardDetailsWidgetConfig(
                                    gatewayId: "gatewayId",
                                    accessToken: "accessToken",
                                    actionText: "actionText",
                                    showCardTitle: true,
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  loadingDelegate: loadingDelegate) { result in
            self.completionResult = result
        }
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        completionResult = nil
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
                                    actionText: "actionText",
                                    showCardTitle: true,
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  loadingDelegate: nil) { result in
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
                                    actionText: "actionText",
                                    showCardTitle: true,
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  loadingDelegate: nil) { result in
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
                                    actionText: "actionText",
                                    showCardTitle: true,
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  loadingDelegate: loadingDelegate) { result in
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
                                    actionText: "actionText",
                                    showCardTitle: true,
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  loadingDelegate: nil) { result in
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
                                    actionText: "actionText",
                                    showCardTitle: true,
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  loadingDelegate: loadingDelegate) { result in
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
                                    actionText: "actionText",
                                    showCardTitle: true,
                                    collectCardholderName: false,
                                    allowSaveCard: config
                                  ),
                                  loadingDelegate: nil) { result in
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
                actionText: "actionText",
                showCardTitle: true,
                collectCardholderName: false,
                allowSaveCard: config
            ),
            loadingDelegate: loadingDelegate
        ) { result in
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
}
// swiftlint:enable all
