//
//  PayPalVMTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
import Combine
@testable import MobileSDK

@MainActor
class PayPalVMTests: XCTestCase {
    
    var viewModel: PayPalVM!
    var mockService: WalletServiceMock!
<<<<<<< HEAD
    var options: WidgetOptions!
=======
    var viewState: ViewState!
>>>>>>> main
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var completionResult: Result<ChargeResponse, PayPalError>?
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockService = WalletServiceMock()
<<<<<<< HEAD
        options = WidgetOptions()
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
=======
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
>>>>>>> main
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
            self.completionResult = result
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
<<<<<<< HEAD
        options = nil
=======
        viewState = nil
>>>>>>> main
        loadingDelegate = nil
        completionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
<<<<<<< HEAD
    
    
    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
=======
    func testInitialisationWithOptionsStateNone() {
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }
    
    func testInitialisationWithOptionsStateDisabled() {
        viewModel = PayPalVM(viewState: ViewState(state: .disabled), payPalToken: { payPalToken in
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
            self.completionResult = result
        }
        
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }
    
    func testInitialisationWithDelegateShowLoader() {
        XCTAssertEqual(viewModel.showLoaders, false)
    }
    
    func testInitialisationWithoutDelegateShowLoader() {
        viewModel = PayPalVM(viewState: ViewState(state: .disabled), payPalToken: { payPalToken in
            
        }, walletService: mockService, loadingDelegate: nil) { result in
            self.completionResult = result
        }
        
        XCTAssertEqual(viewModel.showLoaders, true)
    }
    
    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
>>>>>>> main
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
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
<<<<<<< HEAD
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
=======
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
>>>>>>> main
            
        }, walletService: mockService, loadingDelegate: nil) { result in
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
<<<<<<< HEAD
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
=======
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
>>>>>>> main
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
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
<<<<<<< HEAD
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
=======
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
>>>>>>> main
            
        }, walletService: mockService, loadingDelegate: nil) { result in
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
