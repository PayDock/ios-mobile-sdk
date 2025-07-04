//
//  StyleThemeManager.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 09.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class StyleThemeManager {

    private static var lightAppearances: [WidgetsEnum: Any] = [.all : Theme()]
    private static var darkAppearances: [WidgetsEnum: Any] = [.all : Theme()]

    static func getAppearance<T>(for widget: WidgetsEnum, isDarkMode: Bool, as type: T.Type, shouldCreateDefaultIfNeeded: Bool = true) -> T? {
        
        if shouldCreateDefaultIfNeeded {
            createDefaultAppearanceIfNeeded(for: widget, isDarkMode: isDarkMode)
        }
        
        let dict = isDarkMode ? darkAppearances : lightAppearances
        return dict[widget] as? T
    }

    static func setAppearance<T>(_ appearance: T, for widget: WidgetsEnum, isDarkMode: Bool) {
        if isDarkMode {
            darkAppearances[widget] = appearance
        } else {
            lightAppearances[widget] = appearance
        }
        
        if widget == .all {
            if let globalTheme = appearance as? Theme {
                GlobalTheme.shared.globalTheme = globalTheme
            }
        }
    }
    
    static func resetAppearance(for widget: WidgetsEnum, isDarkMode: Bool) {
        if isDarkMode {
            darkAppearances[widget] = nil
        } else {
            lightAppearances[widget] = nil
        }
        
        createDefaultAppearanceIfNeeded(for: widget, isDarkMode: isDarkMode)
    }

    static func createDefaultAppearanceIfNeeded(for widget: WidgetsEnum, isDarkMode: Bool) {
        let dict = isDarkMode ? darkAppearances : lightAppearances
        if dict[widget] != nil {
            return
        }

        let newAppearance: Any
        switch widget {
        case .all: newAppearance = Theme()
        case .card: newAppearance = CardDetailsWidgetAppearance()
        case .address: newAppearance = AddressWidgetAppearance()
        case .giftCard: newAppearance = GiftCardWidgetAppearance()
        case .paypal: newAppearance = PayPalWidgetAppearance()
        case .paypalVault: newAppearance = PayPalVaultAppearance()
        case .colesPay: newAppearance = ColesPayWidgetAppearance()
        case .afterPay: newAppearance = AfterpayWidgetAppearance()
        case .clickToPay: newAppearance = ClickToPayWidgetAppearance()
        case .applePay: newAppearance = ApplePayWidgetAppearance()
        case .integrated3ds: newAppearance = ThreeDSWidgetAppearance()
        case .standalone3ds: newAppearance = ThreeDSWidgetAppearance()
        }

        setAppearance(newAppearance, for: widget, isDarkMode: isDarkMode)
    }
}
