//
//  GiftCardVMTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
import Combine
@testable import MobileSDK

@MainActor
class GiftCardVMTests: XCTestCase {
    
    var viewModel: GiftCardVM!
    var mockService: CardServiceMock!
    var viewState: ViewState!
    var config: GiftCardWidgetConfig!
    var loadingDelegate: WidgetLoadingDelegateUtil!
    var completionResult: Result<GiftCardResult, GiftCardError>?
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockService = CardServiceMock()
        viewState = ViewState()
        config = GiftCardWidgetConfig(accessToken: "")
        loadingDelegate = WidgetLoadingDelegateUtil()
        completionResult = nil
        viewModel = GiftCardVM(viewState: viewState,
                               cardService: mockService,
                               config: config,
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
    
    func testUpdateLoadingStateToTrueWithDelegate() {
        // Given
        viewModel = GiftCardVM(viewState: viewState,
                               cardService: mockService,
                               config: config,
                               loadingDelegate: loadingDelegate) { result in
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
        viewModel = GiftCardVM(viewState: viewState,
                               cardService: mockService,
                               config: config,
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
    }
    
    func testUpdateLoadingStateToFalseWithDelegate() {
        // Given
        viewModel = GiftCardVM(viewState: viewState,
                               cardService: mockService,
                               config: config,
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
    }
    
    func testUpdateLoadingStateToFalseWithoutDelegate() {
        // Given
        viewModel = GiftCardVM(viewState: viewState,
                               cardService: mockService,
                               config: config,
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
    }
}
