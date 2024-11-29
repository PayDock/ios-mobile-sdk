//
//  CardDetailsVMTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
import Combine
@testable import MobileSDK

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
        config = SaveCardConfig(consentText: "Remember", privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(privacyPolicyText: "Policy test", privacyPolicyURL: "https://www.example.com"))
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
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
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
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
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
                                  loadingDelegate: nil) { result in
            self.completionResult = result
        }
        
        XCTAssertEqual(viewModel.showLoaders, true)
    }
    
    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
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
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
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
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
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
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
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
}
