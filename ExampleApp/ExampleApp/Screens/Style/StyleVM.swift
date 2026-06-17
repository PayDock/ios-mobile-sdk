//
//  StyleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

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
        case .all: return [.actionButton, .expandSectionButton, .linkText, .loader, .overlayLoader, .searchDropdown,
                           .textField, .title, .toggle, .toggleText, .toolbarButton]
        case .card: return [.cardNameTextField, .cardNumberTextField, .cardExpiryTextField, .cardSecurityTextField,
                            .actionButton, .linkText, .spacings, .toggle, .toggleText, .toolbarButton]
        case .giftCard: return [.actionButton, .spacings, .textField, .toolbarButton]
        case .address: return [.actionButton, .expandSectionButton, .searchDropdown, .spacings, .textField, .title]
        case .applePay: return [.applePay]
        case .paypal: return [.payPal]
        case .paypalVault: return [.actionButton]
        case .colesPay: return [.buttonLoader]
        case .afterPay: return [.afterpay, .loader]
        case .clickToPay: return [.loader]
        case .mpgs3ds: return [.loader]
        case .standalone3ds: return [.overlayLoader]
        case .zip: return [.zip, .buttonLoader]
        }
    }
}
