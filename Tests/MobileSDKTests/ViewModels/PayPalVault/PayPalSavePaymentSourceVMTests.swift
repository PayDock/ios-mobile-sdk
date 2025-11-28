//
//  PayPalSavePaymentSourceVMTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 30.10.2024..
//

import XCTest
import Combine
@testable import MobileSDK

@MainActor
class PayPalSavePaymentSourceVMTests: XCTestCase {

    var viewModel: PayPalSavePaymentSourceVM!
    var mockService: PayPalVaultServiceMock!
    var viewState: ViewState!
    var config: PayPalVaultConfig!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var eventDelegate: WidgetEventDelegateUtil!
    var completionResult: Result<PayPalVaultResult, PayPalVaultError>?
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockService = PayPalVaultServiceMock()
        viewState = ViewState()
        config = PayPalVaultConfig(accessToken: "test_access_token", gatewayId: "test_gateway")
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()
        completionResult = nil
        viewModel = PayPalSavePaymentSourceVM(
            viewState: ViewState(),
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: nil,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
            }
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        viewState = nil
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
        viewModel = PayPalSavePaymentSourceVM(
            viewState: ViewState(state: .disabled),
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
            }

        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testInitialisationWithoutDelegateShowLoader() {
        XCTAssertEqual(viewModel.showLoaders, true)
    }

    func testInitialisationWithDelegateShowLoader() {
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
            }

        XCTAssertEqual(viewModel.showLoaders, false)
    }

    // MARK: - Positive service interaction

    func testGetClientIdSuccess() async {
        mockService.sendError = false
        mockService.responseFilename = .getClientId

        let clientId = await viewModel.getClientId()

        XCTAssertEqual(clientId, "AY-iOYV1QKAX6ZRomt-gXigd0-pToRMwdoLW4UxFSITOApI2jUa5UgM39MKC0qeip3SCbPozbAusuGO0")
        XCTAssertEqual(viewModel.isLoading, true)
    }

    func testGetSetupTokenSuccess() async {
        mockService.sendError = false
        mockService.responseFilename = .setupTokenSuccess

        let setupTokenData = await viewModel.getSetupTokenData()

        XCTAssertEqual(setupTokenData?.setupToken, "XObCsxdHXe")
        XCTAssertEqual(viewModel.isLoading, true)
    }

    func testGetPaymentTokenSuccess() async {
        mockService.sendError = false
        mockService.responseFilename = .createPaymentToken

        await viewModel.createPaymentToken(setupToken: "some_setup_token")

        if case .success(let result) = completionResult {
            XCTAssertEqual(result.token, "8kk8451t")
            XCTAssertEqual(result.email, "someone@something.com")
        } else {
            XCTFail("Completion should return success.")
        }
        XCTAssertEqual(viewModel.isLoading, false)
    }

    // MARK: - Negative service interaction

    func testGetClientIdSetsCompletionOnFailure() async {
        mockService.sendError = true
        mockService.responseFilename = .authFail

        let clientId = await viewModel.getClientId()

        XCTAssertNil(clientId, "Client ID should be nil on error.")
        if case .failure(let error) = completionResult {
            switch error {
            case .getPayPalClientId: XCTAssert(true)
            default: XCTFail("Error message should always be initialisationClientId.")
            }
        } else {
            XCTFail("Expected completion to be called with a initialisationClientId failure.")
        }
    }

    func testGetSetupTokenIdSetsCompletionOnFailure() async {
        mockService.sendError = true
        mockService.responseFilename = .authFail

        let setupToken = await viewModel.getSetupTokenData()

        XCTAssertNil(setupToken, "Setup token should be nil on error.")
        if case .failure(let error) = completionResult {
            switch error {
            case .createSetupToken: XCTAssert(true)
            default: XCTFail("Error message should always be createSetupToken.")
            }
        } else {
            XCTFail("Expected completion to be called with a createSetupToken failure.")
        }
        XCTAssertEqual(viewModel.isLoading, false)
    }

    func testCreatePaymentTokenSetsCompletionOnFailure() async {
        mockService.sendError = true
        mockService.responseFilename = .authFail

        await viewModel.createPaymentToken(setupToken: "some_setup_token")

        if case .failure(let error) = completionResult {
            switch error {
            case .createPaymentToken: XCTAssert(true)
            default: XCTFail("Error message should always be createPaymentToken.")
            }
        } else {
            XCTFail("Expected completion to be called with a createPaymentToken failure.")
        }
        XCTAssertEqual(viewModel.isLoading, false)
    }

    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
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
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
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
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
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
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
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
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
            }

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(type: .button, properties: .button(WidgetEventButtonProperties(name: "PayPalVaultButton", action: .click)))
        viewModel.handleButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: loadingDelegate,
            eventDelegate: nil) { result in
                self.completionResult = result
            }

        // When - The view model should handle nil event delegate gracefully
        viewModel.initializePayPalSDK()

        // Then - No events should be recorded in our test delegate
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }
}
