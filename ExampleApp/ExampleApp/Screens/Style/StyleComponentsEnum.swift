//
//  StyleComponentsEnum.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright 2025 Paydock Ltd. All rights reserved.

import SwiftUI
import MobileSDK

enum StyleComponentsEnum {
    case textField
    case searchDropdown
    case actionButton
    case expandSectionButton
    case toolbarButton
    case loader
    case toggle
    case linkText
    case toggleText
    case description
    case title
    
    var title: String {
        switch self {
        case .textField: return "Text Field"
        case .searchDropdown: return "Search Dropdown"
        case .actionButton: return "Action Button"
        case .expandSectionButton: return "Expand Button"
        case .toolbarButton: return "Toolbar Button"
        case .loader: return "Loader"
        case .toggle: return "Toggle"
        case .linkText: return "Link Text"
        case .toggleText: return "Toggle Text"
        case .description: return "Description"
        case .title: return "Title"
        }
    }
    
    func destinationView(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) -> AnyView {
        switch self {
        case .loader:
            return AnyView(LoaderStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .toggle:
            return AnyView(ToggleStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .actionButton:
            return AnyView(createActionButtonView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .expandSectionButton:
            return AnyView(createExpandSectionButtonView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .toolbarButton:
            return AnyView(createToolbarButtonView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .textField:
            return AnyView(TextFieldStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        default:
            return AnyView(EmptyView())
        }
    }
    
    // MARK: - Helper Methods
    
    private func createActionButtonView(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) -> AnyView {
        switch selectedWidget {
        case .all:
            return AnyView(ButtonStyleView<Theme>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.actionButton,
                title: title))
        case .card:
            return AnyView(ButtonStyleView<CardDetailsWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.actionButton,
                title: title))
        case .address:
            return AnyView(ButtonStyleView<AddressWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.actionButton,
                title: title))
        case .giftCard:
            return AnyView(ButtonStyleView<GiftCardWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.actionButton,
                title: title))
        case .paypalVault:
            return AnyView(ButtonStyleView<PayPalVaultAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.actionButton,
                title: title))
        default:
            return AnyView(EmptyView())
        }
    }
    
    private func createExpandSectionButtonView(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) -> AnyView {
        switch selectedWidget {
        case .all:
            return AnyView(ButtonStyleView<Theme>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.expandSectionButton,
                title: title))
        case .address:
            return AnyView(ButtonStyleView<AddressWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.expandSectionButton,
                title: title))
        default:
            return AnyView(EmptyView())
        }
    }
    
    private func createToolbarButtonView(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) -> AnyView {
        switch selectedWidget {
        case .all:
            return AnyView(ButtonStyleView<Theme>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.toolbarButton,
                title: title))
        case .card:
            return AnyView(ButtonStyleView<CardDetailsWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.toolbarButton,
                title: title))
        case .giftCard:
            return AnyView(ButtonStyleView<GiftCardWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                buttonKeyPath: \.toolbarButton,
                title: title))
        default:
            return AnyView(EmptyView())
        }
    }
}
