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
    var viewState: ViewState!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var completionResult: Result<ChargeResponse, PayPalError>?
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockService = WalletServiceMock()
        viewState = ViewState()
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
            self.completionResult = result
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        viewState = nil
        loadingDelegate = nil
        completionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
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
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
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
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
            
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
        XCTAssertEqual(viewModel.viewState.isDisabled, true)
    }
    
    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
            
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
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }
    
    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = PayPalVM(viewState: viewState, payPalToken: { payPalToken in
            
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
        XCTAssertEqual(viewModel.viewState.isDisabled, false)
    }
}
