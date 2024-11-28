//
//  WidgetOptions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI

public class WidgetOptions: ObservableObject {
    @Published var isDisabled: Bool
    
    public init(state: WidgetState = .none) {
        isDisabled = state == .disabled
    }
    
    public func setState(_ state: WidgetState) {
        isDisabled = state == .disabled
    }
}

public enum WidgetState {
    case none
    case disabled
}
