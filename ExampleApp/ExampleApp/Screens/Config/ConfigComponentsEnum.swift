//
//  ConfigComponentsEnum.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

enum ConfigComponentsEnum {
    case widgetAccessToken
    case apiAccessToken
    case gatewayId
    case showCardTitle
    case collectCardholderName
    case allowSaveCard
    case schemeSupport
    case storePin
    case requestShipping
    case fundingSource
    case address
    case environment
    case enableTestMode
    case afterpayConfig
    case clickToPayMetaConfig
    case checkoutOptions
    case clientId
    case serviceId
    case totalAmount
    case currency

    var title: String {
        switch self {
        case .widgetAccessToken: return "Widget Access Token"
        case .apiAccessToken: return "Api Access Token"
        case .gatewayId: return "Gateway ID"
        case .showCardTitle: return "Show Card Title"
        case .collectCardholderName: return "Collect Cardholder Name"
        case .allowSaveCard: return "Allow Save Card"
        case .schemeSupport: return "Scheme Support"
        case .storePin: return "Store PIN"
        case .requestShipping: return "Request Shipping"
        case .fundingSource: return "Funding Source"
        case .address: return "Address"
        case .environment: return "Environment"
        case .enableTestMode: return "Enable Test Mode"
        case .afterpayConfig: return "Afterpay Configuration"
        case .clickToPayMetaConfig: return "Click To Pay Meta Configuration"
        case .checkoutOptions: return "Checkout Options"
        case .clientId: return "Client ID"
        case .serviceId: return "Service ID"
        case .totalAmount: return "Total Amount"
        case .currency: return "Currency"
        }
    }

    var description: String? {
        switch self {
        case .apiAccessToken: return "Set API access token to use for API requests"
        case .totalAmount: return "Set the value passed for widgets on the widget list"
        case .currency: return "Set the currency to pass to widgets"
        default: return nil
        }
    }

    func destinationView(selectedWidget: ConfigWidgetsEnum) -> AnyView {
        switch self {
        case .widgetAccessToken, .apiAccessToken, .gatewayId, .clientId, .serviceId, .totalAmount, .currency:
            return createTextFieldView(selectedWidget: selectedWidget)
        case .showCardTitle, .collectCardholderName, .storePin, .requestShipping, .enableTestMode:
            return createToggleView(selectedWidget: selectedWidget)
        case .fundingSource, .environment:
            return createPickerView(selectedWidget: selectedWidget)
        case .allowSaveCard:
            return AnyView(ConfigSaveCardView(selectedWidget: selectedWidget, title: title))
        case .schemeSupport:
            return AnyView(ConfigSchemeView(selectedWidget: selectedWidget, title: title))
        case .address:
            return AnyView(ConfigAddressView(selectedWidget: selectedWidget, title: title))
        case .afterpayConfig:
            return AnyView(ConfigAfterpayView(selectedWidget: selectedWidget, title: title))
        case .clickToPayMetaConfig:
            return AnyView(ConfigClickToPayView(selectedWidget: selectedWidget, title: title))
        case .checkoutOptions:
            return AnyView(ConfigCheckoutOptionsView(selectedWidget: selectedWidget, title: title))
        }
    }

    private func createTextFieldView(selectedWidget: ConfigWidgetsEnum) -> AnyView {
        return AnyView(ConfigTextFieldView(
            selectedWidget: selectedWidget,
            configKey: configKey,
            title: title,
            description: description))
    }

    private func createToggleView(selectedWidget: ConfigWidgetsEnum) -> AnyView {
        return AnyView(ConfigToggleView(
            selectedWidget: selectedWidget,
            configKey: configKey,
            title: title))
    }

    private func createPickerView(selectedWidget: ConfigWidgetsEnum) -> AnyView {
        return AnyView(ConfigPickerView(
            selectedWidget: selectedWidget,
            configKey: configKey,
            title: title))
    }

    private var configKey: ConfigKeys {
        switch self {
        case .widgetAccessToken: return .widgetAccessToken
        case .apiAccessToken: return .apiAccessToken
        case .gatewayId: return .gatewayId
        case .showCardTitle: return .showCardTitle
        case .collectCardholderName: return .collectCardholderName
        case .storePin: return .storePin
        case .requestShipping: return .requestShipping
        case .fundingSource: return .fundingSource
        case .environment: return .environment
        case .enableTestMode: return .enableTestMode
        case .clientId: return .clientId
        case .serviceId: return .serviceId
        case .totalAmount: return .totalAmount
        case .currency: return .currency
        case .allowSaveCard, .schemeSupport, .address, .afterpayConfig, .checkoutOptions, .clickToPayMetaConfig:
            fatalError("This component doesn't use ConfigKeys")
        }
    }
}
