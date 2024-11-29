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

class PayPalSavePaymentSourceVMTests: XCTestCase {
    
    var viewModel: PayPalSavePaymentSourceVM!
    var mockService: PayPalVaultServiceMock!
    var viewState: ViewState!
    var config: PayPalVaultConfig!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var completionResult: Result<PayPalVaultResult, PayPalVaultError>?
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockService = PayPalVaultServiceMock()
        viewState = ViewState()
        config = PayPalVaultConfig(accessToken: "test_access_token", gatewayId: "test_gateway", actionText: "Custom Action Text")
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = PayPalSavePaymentSourceVM(
            viewState: ViewState(),
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: nil)
        { result in
            self.completionResult = result
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        viewState = nil
        completionResult = nil
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
            loadingDelegate: loadingDelegate)
        { result in
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
            loadingDelegate: loadingDelegate)
        { result in
            self.completionResult = result
        }
        
        XCTAssertEqual(viewModel.showLoaders, false)
    }
    
    func testInitializationSetsActionText() {
        XCTAssertEqual(viewModel.actionText, "Custom Action Text", "The actionText should match the provided config value.")
    }
    
    func testDefaultActionTextIfNil() {
        config = PayPalVaultConfig(accessToken: "test_access_token", gatewayId: "test_gateway", actionText: nil)
        viewModel = PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            payPalVaultService: mockService,
            loadingDelegate: nil
        ) { _ in }
        
        XCTAssertEqual(viewModel.actionText, "Link PayPal account", "The actionText should default to 'Link PayPal account' when nil.")
    }
    
    // MARK: - Positive service interaction
    
    func testGetClientIdSuccess() async {
        mockService.sendError = false
        mockService.responseFilename = .getClientId
        
        let clientId = await viewModel.getClientId()
        
        XCTAssertEqual(clientId, "AY-iOYV1QKAX6ZRomt-gXigd0-pToRMwdoLW4UxFSITOApI2jUa5UgM39MKC0qeip3SCbPozbAusuGO0")
        XCTAssertEqual(viewModel.isLoading, true)
    }
    
    func testGetAuthTokenSuccess() async {
        mockService.sendError = false
        mockService.responseFilename = .authSuccess
        
        let authToken = await viewModel.getAuthToken()
        
        XCTAssertEqual(authToken, "some_access_token")
        XCTAssertEqual(viewModel.isLoading, true)
    }
    
    func testGetSetupTokenSuccess() async {
        mockService.sendError = false
        mockService.responseFilename = .setupTokenSuccess
        
        let setupTokenData = await viewModel.getSetupTokenData(authToken: "some_auth_token")
        
        XCTAssertEqual(setupTokenData?.setupToken, "XObCsxdHXe")
        XCTAssertEqual(setupTokenData?.approveLink, URL(string: "www.something.com")!)
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
    
    func testGetAuthTokenSetsCompletionOnFailure() async {
        mockService.sendError = true
        mockService.responseFilename = .authFail
        
        let authToken = await viewModel.getAuthToken()
        
        XCTAssertNil(authToken, "Auth token should be nil on error.")
        if case .failure(let error) = completionResult {
            switch error {
            case .createSessionAuthToken: XCTAssert(true)
            default: XCTFail("Error message should always be createSessionAuthToken.")
            }
        } else {
            XCTFail("Expected completion to be called with a createSessionAuthToken failure.")
        }
        XCTAssertEqual(viewModel.isLoading, false)
    }
    
    func testGetSetupTokenIdSetsCompletionOnFailure() async {
        mockService.sendError = true
        mockService.responseFilename = .authFail
        
        let setupToken = await viewModel.getSetupTokenData(authToken: "auth_token")
        
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
            loadingDelegate: loadingDelegate)
        { result in
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
            loadingDelegate: nil)
        { result in
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
            loadingDelegate: loadingDelegate)
        { result in
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
            loadingDelegate: nil)
        { result in
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
}
