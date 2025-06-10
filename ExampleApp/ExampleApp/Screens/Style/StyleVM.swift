//
//  StyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

class StyleVM: ObservableObject {
    
    // MARK: - Properties
    
    let selectedWidget: WidgetsEnum
    @Published var stylingDarkMode = false
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum) {
        self.selectedWidget = selectedWidget
    }
    
    // MARK: - Helpers
    
    func getComponentsForWidget(_ widget: WidgetsEnum) -> [StyleComponentsEnum] {
        switch widget {
        case .all: return [.textField, .searchDropdown, .actionButton, .expandSectionButton, .toolbarButton, .loader, .toggle, .linkText, .toggleText, .description, .title]
        case .card: return [.textField, .title, .actionButton, .toolbarButton, .toggle, .toggleText, .linkText]
        case .giftCard: return [.textField, .title, .actionButton, .toolbarButton]
        case .address: return [.textField, .title, .actionButton, .expandSectionButton, .searchDropdown]
        case .applePay: return [] // TODO: - Nothing we can customize from UI - best to remove from the list
        case .paypal: return [.actionButton]
        case .paypalVault: return [.actionButton]
        case .colesPay: return [.loader]
        case .afterPay: return [.loader]
        case .clickToPay: return [.loader]
        case .integrated3ds: return [.loader]
        case .standalone3ds: return [.loader]
        }
    }
}
