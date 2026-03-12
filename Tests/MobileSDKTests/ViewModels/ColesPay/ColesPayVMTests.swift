//
//  ColesPayVMTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.09.2025..
//

import XCTest
import Combine
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataCharges

// swiftlint:disable all
@MainActor
class ColesPayVMTests: XCTestCase {

    var viewModel: ColesPayVM!

    private var chargesService: ChargesMockService!
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var eventDelegate: WidgetEventDelegateUtil!
    var config: ColesPayConfig!

    var completionResult: Result<String, ColesPayError>?

    override func setUp() {
        super.setUp()
        chargesService = ChargesMockService()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        eventDelegate = WidgetEventDelegateUtil()
        config = ColesPayConfig(clientId: "client_123")
        completionResult = nil

        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "wallet_token")))
            },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            })
    }

    override func tearDown() {
        viewModel = nil
        chargesService = nil
        viewState = nil
        loadingDelegate = nil
        eventDelegate = nil
        config = nil
        completionResult = nil
        super.tearDown()
    }

    // MARK: - Initialisation

    func testInitialisationWithDelegateShowLoader() {
        XCTAssertEqual(viewModel.showLoaders, false)
    }

    func testInitialisationWithoutDelegateShowLoader() {
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "wallet_token")))
            },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: nil,
            eventDelegate: nil) { result in
                self.completionResult = result
            }

        XCTAssertEqual(viewModel.showLoaders, true)
    }

    // MARK: - Loading state updates

    func testUpdateLoadingStateToTrueWithDelegate() {
        // When
        viewModel.updateLoadingState(isLoading: true)

        // Then
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(loadingDelegate.isLoading, true)
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testUpdateLoadingStateToTrueWithoutDelegate() {
        // Given
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "wallet_token")))
            },
            chargesService: chargesService,
            viewState: viewState,
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
        viewModel.isLoading = true
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
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "wallet_token")))
            },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
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

    // MARK: - Button tap / token request

    func testHandleButtonTap_SetsLoadingAndShowsWebView_OnSuccess() async {
        // Given: wallet service will return a valid order id
        chargesService.colesPayCallbackResult = "order_123"

        // When
        viewModel.handleButtonTap()

        // Then: wait briefly for async Task in getColesPayURL
        let exp = expectation(description: "WebView shown after fetching URL")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.showWebView, true)
        XCTAssertEqual(viewModel.colesPayOrderId, "order_123")
        // Note: viewState remains disabled while WebView is shown
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }

    func testHandleButtonTap_CompletesWithInitialisingWalletToken_OnTokenFailure() async {
        // Given: token request fails
        let expectation = expectation(description: "Completion called with token failure")
        
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.failure(.initialisingWalletToken(reason: "Token init failed")))
            },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
                expectation.fulfill()
            }

        // When
        viewModel.handleButtonTap()

        // Then - Wait for the async task to complete
        await fulfillment(of: [expectation], timeout: 1.0)
        
        switch completionResult {
        case .failure(let error):
            switch error {
            case .initialisingWalletToken(let reason):
                XCTAssertEqual(reason, "Token init failed")
            default:
                XCTFail("Expected initialisingWalletToken error, got: \(error)")
            }
        default:
            XCTFail("Expected failure result")
        }

        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.showWebView, false)
    }

    func testGetColesPayURL_CompletesWithUnknownError_OnOtherError() async {
        // Given: service throws an unknown error (non-RequestError)
        chargesService.shouldThrowUnknownError = true

        let exp = expectation(description: "Completion called with unknownError")
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "wallet_token")))
            },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
                exp.fulfill()
            }

        // When
        viewModel.getColesPayURL(token: "wallet_token")

        // Then
        await fulfillment(of: [exp], timeout: 1.0)
        switch completionResult {
        case .failure(let error):
            switch error {
            case .unknownError:
                XCTAssert(true)
            default:
                XCTFail("Expected unknownError, got: \(error)")
            }
        default:
            XCTFail("Expected failure result")
        }

        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.showWebView, false)
    }

    // MARK: - Handlers

    func testHandleSuccess_CompletesWithOrderId_AndHidesWebView() {
        // Given
        chargesService.colesPayCallbackResult = "order_123"
        viewModel.getColesPayURL(token: "wallet_token")

        // Wait briefly for showWebView to be set
        let exp = expectation(description: "URL fetched")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        // When
        let completionExp = expectation(description: "Completion called with success")
        completionResult = nil
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { $0(.success(WalletTokenResult(token: "wallet_token"))) },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
                completionExp.fulfill()
            }
        // Manually set order id to simulate fetched state
        viewModel.getColesPayURL(token: "wallet_token")
        let exp2 = expectation(description: "URL fetched 2")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)

        viewModel.handleSuccess()

        wait(for: [completionExp], timeout: 1.0)
        switch completionResult {
        case .success(let orderId):
            XCTAssertFalse(orderId.isEmpty)
        default:
            XCTFail("Expected success result")
        }
        XCTAssertEqual(viewModel.showWebView, false)
        XCTAssertEqual(viewModel.isLoading, false)
    }

    func testHandleFailure_CompletesWithError_AndHidesWebView() {
        // Given
        let errorRes = ErrorRes(status: 500, error: .init(message: "Server error", code: "ServerError", details: nil), resource: nil, errorSummary: nil)
        let error = ColesPayError.errorFetchingColesPayOrder(error: errorRes)
        let exp = expectation(description: "Completion called with failure")

        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { $0(.success(WalletTokenResult(token: "wallet_token"))) },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
                exp.fulfill()
            }

        // When
        viewModel.handleFailure(error: error)

        // Then
        wait(for: [exp], timeout: 1.0)
        switch completionResult {
        case .failure(let e):
            switch e {
            case .errorFetchingColesPayOrder(let err):
                XCTAssertEqual(err.error?.message, "Server error")
            default:
                XCTFail("Expected errorFetchingColesPayOrder, got: \(e)")
            }
        default:
            XCTFail("Expected failure result")
        }
        XCTAssertEqual(viewModel.showWebView, false)
        XCTAssertEqual(viewModel.isLoading, false)
    }

    func testHandleSheetCancellation_CompletesWithTransactionCanceled() {
        // Given
        let exp = expectation(description: "Completion called with transactionCanceled")
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { $0(.success(WalletTokenResult(token: "wallet_token"))) },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate) { result in
                self.completionResult = result
                exp.fulfill()
            }

        // When
        viewModel.handleSheetCancellation()

        // Then
        wait(for: [exp], timeout: 1.0)
        switch completionResult {
        case .failure(let error):
            switch error {
            case .transactionCanceled: XCTAssertTrue(true)
            default: XCTFail("Expected transactionCanceled, got: \(error)")
            }
        default:
            XCTFail("Expected failure result")
        }
        XCTAssertEqual(viewModel.isLoading, false)
    }

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Given
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "wallet_token")))
            },
            chargesService: chargesService,
            viewState: viewState,
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
            properties: .button(WidgetEventButtonProperties(name: "ColesPayCheckoutButton", action: .click)))
        viewModel.handleaButtonTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = ColesPayVM(
            config: config,
            tokenRequest: { completion in
                completion(.success(WalletTokenResult(token: "wallet_token")))
            },
            chargesService: chargesService,
            viewState: viewState,
            loadingDelegate: loadingDelegate,
            eventDelegate: nil,
            completion: { result in
                self.completionResult = result
            }
        )

        viewModel.handleButtonTap()

        // Then - No events should be recorded in our test delegate
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }
}
// swiftlint:enable all
