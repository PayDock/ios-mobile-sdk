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
    var options: WidgetOptions!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var completionResult: Result<ChargeResponse, PayPalError>?
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockService = WalletServiceMock()
        options = WidgetOptions()
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
            self.completionResult = result
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        options = nil
        loadingDelegate = nil
        completionResult = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
            
        }, walletService: mockService, loadingDelegate: loadingDelegate) { result in
            self.completionResult = result
        }
        
        // When
        viewModel.updateLoadingState(isLoading: true)
        
        // Then
        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(loadingDelegate.isLoading, true)
        XCTAssertEqual(viewModel.options.isDisabled, true)
    }
    
    func testUpdateLoadingStateToTrueWithoutDelegate() {
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
            
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
        XCTAssertEqual(viewModel.options.isDisabled, true)
    }
    
    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
            
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
        XCTAssertEqual(viewModel.options.isDisabled, false)
    }
    
    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = PayPalVM(options: options, payPalToken: { payPalToken in
            
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
        XCTAssertEqual(viewModel.options.isDisabled, false)
    }
}
