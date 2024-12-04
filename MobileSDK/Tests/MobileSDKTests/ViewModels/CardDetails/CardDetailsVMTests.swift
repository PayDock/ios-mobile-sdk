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
<<<<<<< HEAD
    var options: WidgetOptions!
=======
    var viewState: ViewState!
>>>>>>> main
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var completionResult: Result<CardResult, CardDetailsError>?
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockService = CardServiceMock()
        config = SaveCardConfig(consentText: "Remember", privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(privacyPolicyText: "Policy test", privacyPolicyURL: "https://www.example.com"))
<<<<<<< HEAD
        options = WidgetOptions()
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = CardDetailsVM(cardService: mockService,
                                  options: options,
=======
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = CardDetailsVM(cardService: mockService,
                                  viewState: viewState,
>>>>>>> main
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
<<<<<<< HEAD
        XCTAssertEqual(viewModel.options.isDisabled, false)
=======
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
>>>>>>> main
    }
    
    func testInitialisationWithOptionsStateDisabled() {
        viewModel = CardDetailsVM(cardService: mockService,
<<<<<<< HEAD
                                  options: WidgetOptions(state: .disabled),
=======
                                  viewState: ViewState(state: .disabled),
>>>>>>> main
                                  gatewayId: "gatewayId",
                                  accessToken: "accessToken",
                                  actionText: "actionText",
                                  showCardTitle: true,
                                  collectCardholderName: false,
                                  allowSaveCard: config,
                                  loadingDelegate: nil) { result in
            self.completionResult = result
        }
        
<<<<<<< HEAD
        XCTAssertEqual(viewModel.options.isDisabled, true)
=======
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
>>>>>>> main
    }
    
    func testInitialisationWithDelegateShowLoader() {
        XCTAssertEqual(viewModel.showLoaders, false)
    }
    
    func testInitialisationWithoutDelegateShowLoader() {
        viewModel = CardDetailsVM(cardService: mockService,
<<<<<<< HEAD
                                  options: options,
=======
                                  viewState: viewState,
>>>>>>> main
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
<<<<<<< HEAD
                                  options: options,
=======
                                  viewState: viewState,
>>>>>>> main
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
<<<<<<< HEAD
        XCTAssertEqual(viewModel.options.isDisabled, true)
=======
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
>>>>>>> main
    }
    
    func testUpdateLoadingStateToTrueWithoutDelegate() {
        // Given
        viewModel = CardDetailsVM(cardService: mockService,
<<<<<<< HEAD
                                  options: options,
=======
                                  viewState: viewState,
>>>>>>> main
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
<<<<<<< HEAD
        XCTAssertEqual(viewModel.options.isDisabled, true)
=======
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
>>>>>>> main
    }
    
    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = CardDetailsVM(cardService: mockService,
<<<<<<< HEAD
                                  options: options,
=======
                                  viewState: viewState,
>>>>>>> main
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
<<<<<<< HEAD
        XCTAssertEqual(viewModel.options.isDisabled, false)
=======
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
>>>>>>> main
    }
    
    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = CardDetailsVM(cardService: mockService,
<<<<<<< HEAD
                                  options: options,
=======
                                  viewState: viewState,
>>>>>>> main
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
<<<<<<< HEAD
        XCTAssertEqual(viewModel.options.isDisabled, false)
=======
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
>>>>>>> main
    }
}
