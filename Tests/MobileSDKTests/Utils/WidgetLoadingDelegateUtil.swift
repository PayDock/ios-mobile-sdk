//
//  WidgetLoadingDelegateUtil.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
@testable import MobileSDK

class WidgetLoadingDelegateUtil: WidgetLoadingDelegate {
    
    public var isLoading: Bool = false
    
    func loadingDidStart() {
        isLoading = true
    }
    
    func loadingDidFinish() {
        isLoading = false
    }
}
