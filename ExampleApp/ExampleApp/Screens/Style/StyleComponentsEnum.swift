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
    case title
    case applePay
    case afterpay
    case payPal
    case spacings
    case buttonLoader
    case zip

    var title: String {
        switch self {
        case .textField: return "Text Field"
        case .searchDropdown: return "Search Dropdown"
        case .actionButton: return "Action Button"
        case .expandSectionButton: return "Link Button"
        case .toolbarButton: return "Toolbar Button"
        case .loader: return "Loader"
        case .toggle: return "Toggle"
        case .linkText: return "Link Text"
        case .toggleText: return "Toggle Text"
        case .title: return "Title"
        case .applePay: return "Apple Pay Button"
        case .afterpay: return "Afterpay Button"
        case .payPal: return "PayPal Button"
        case .spacings: return "Spacings"
        case .buttonLoader: return "Button Loader"
        case .zip: return "Zip Button"
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
        case .searchDropdown:
            return AnyView(DropdownStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .title:
            return AnyView(createTitleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .linkText:
            return AnyView(createLinkTextView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .toggleText:
            return AnyView(createToggleTextView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .applePay:
            return AnyView(ApplePayStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .afterpay:
            return AnyView(AfterpayStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .payPal:
            return AnyView(PayPalStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .spacings:
            return AnyView(SpacingsStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .buttonLoader:
            return AnyView(ButtonLoaderStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        case .zip:
            return AnyView(ZipStyleView(selectedWidget: selectedWidget, stylingDarkMode: stylingDarkMode))
        }
    }

    // MARK: - Button Helper Methods

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

    // MARK: - Text Helper Methods

    private func createTitleView(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) -> AnyView {
        switch selectedWidget {
        case .all:
            return AnyView(TextStyleView<Theme>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                textKeyPath: \.title,
                title: title))
        case .address:
            return AnyView(TextStyleView<AddressWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                textKeyPath: \.title,
                title: title))
        default:
            return AnyView(EmptyView())
        }
    }

    private func createLinkTextView(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) -> AnyView {
        switch selectedWidget {
        case .all:
            return AnyView(TextStyleView<Theme>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                textKeyPath: \.linkText,
                title: title))
        case .card:
            return AnyView(TextStyleView<CardDetailsWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                textKeyPath: \.linkText,
                title: title))
        default:
            return AnyView(EmptyView())
        }
    }

    private func createToggleTextView(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) -> AnyView {
        switch selectedWidget {
        case .all:
            return AnyView(TextStyleView<Theme>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                textKeyPath: \.toggleText,
                title: title))
        case .card:
            return AnyView(TextStyleView<CardDetailsWidgetAppearance>(
                selectedWidget: selectedWidget,
                stylingDarkMode: stylingDarkMode,
                textKeyPath: \.toggleText,
                title: title))
        default:
            return AnyView(EmptyView())
        }
    }
}
