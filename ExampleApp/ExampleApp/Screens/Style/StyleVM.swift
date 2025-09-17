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

    var selectedWidget: WidgetsEnum
    @Published var stylingDarkMode = false

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum = .all) {
        self.selectedWidget = selectedWidget
    }

    // MARK: - Helpers

    func getComponentsForWidget(_ widget: WidgetsEnum) -> [StyleComponentsEnum] {
        switch widget {
        case .all: return [.actionButton, .expandSectionButton, .linkText, .loader, .searchDropdown,
                           .textField, .title, .toggle, .toggleText, .toolbarButton]
        case .card: return [.actionButton, .linkText, .spacings, .textField, .title, .toggle, .toggleText, .toolbarButton]
        case .giftCard: return [.actionButton, .spacings, .textField, .title, .toolbarButton]
        case .address: return [.actionButton, .expandSectionButton, .searchDropdown, .spacings, .textField, .title]
        case .applePay: return [.applePay]
        case .paypal: return [.payPal, .buttonLoader]
        case .paypalVault: return [.actionButton]
        case .colesPay: return [.buttonLoader]
        case .afterPay: return [.afterpay, .loader]
        case .clickToPay: return [.loader]
        case .integrated3ds: return [.loader]
        case .standalone3ds: return [.loader]
        }
    }
}
