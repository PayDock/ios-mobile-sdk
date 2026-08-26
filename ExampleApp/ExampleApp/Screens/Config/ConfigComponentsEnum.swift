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
    case collectCardholderName
    case allowSaveCard
    case storeSecurityCode
    case schemeSupport
    case activePrimaryButton
    case showSubmitButton
    case storePin
    case requestShipping
    case fundingSource
    case address
    case clickToPayMetaConfig
    case checkoutOptions
    case clientId
    case serviceId
    case totalAmount
    case currency
    case applePayConfig
    case firstName
    case lastName
    case email
    case phoneNumber
    case gender
    case dateOfBirth
    case tokenize
    case shippingType
    case billingAddress
    case shippingAddress

    var title: String {
        switch self {
        case .widgetAccessToken: return "Widget Access Token"
        case .apiAccessToken: return "Api Access Token"
        case .gatewayId: return "Gateway ID"
        case .collectCardholderName: return "Collect Cardholder Name"
        case .allowSaveCard: return "Allow Save Card"
        case .storeSecurityCode: return "Store Security Code"
        case .schemeSupport: return "Scheme Support"
        case .activePrimaryButton: return "Active Primary Button"
        case .showSubmitButton: return "Show Submit Button"
        case .storePin: return "Store PIN"
        case .requestShipping: return "Request Shipping"
        case .fundingSource: return "Funding Source"
        case .address: return "Address"
        case .clickToPayMetaConfig: return "Click To Pay Meta Configuration"
        case .checkoutOptions: return "Checkout Options"
        case .clientId: return "Client ID"
        case .serviceId: return "Service ID"
        case .totalAmount: return "Total Amount"
        case .currency: return "Currency"
        case .applePayConfig: return "Apple Pay Configuration"
        case .firstName: return "First Name"
        case .lastName: return "Last Name"
        case .email: return "Email"
        case .phoneNumber: return "Phone"
        case .gender: return "Gender"
        case .dateOfBirth: return "Date of Birth"
        case .tokenize: return "Tokenize"
        case .shippingType: return "Shipping Type"
        case .billingAddress: return "Billing Address"
        case .shippingAddress: return "Shipping Address"
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
        case .widgetAccessToken, .apiAccessToken, .gatewayId, .clientId, .serviceId, .totalAmount, .currency,
                    .firstName, .lastName, .email, .phoneNumber, .dateOfBirth:
            return createTextFieldView(selectedWidget: selectedWidget)
        case .collectCardholderName, .storePin, .requestShipping, .tokenize, .activePrimaryButton, .showSubmitButton:
            return createToggleView(selectedWidget: selectedWidget)
        case .fundingSource, .gender, .shippingType:
            return createPickerView(selectedWidget: selectedWidget)
        case .billingAddress, .shippingAddress:
            return createAddressView(selectedWidget: selectedWidget)
        case .allowSaveCard:
            return AnyView(ConfigSaveCardView(selectedWidget: selectedWidget, title: title))
        case .storeSecurityCode:
            return AnyView(ConfigStoreSecurityCodeView(selectedWidget: selectedWidget, title: title))
        case .schemeSupport:
            return AnyView(ConfigSchemeView(selectedWidget: selectedWidget, title: title))
        case .address:
            return AnyView(ConfigAddressView(selectedWidget: selectedWidget, title: title))
        case .clickToPayMetaConfig:
            return AnyView(ConfigClickToPayView(selectedWidget: selectedWidget, title: title))
        case .checkoutOptions:
            return AnyView(ConfigCheckoutOptionsView(selectedWidget: selectedWidget, title: title))
        case .applePayConfig:
            return AnyView(ConfigApplePayView(selectedWidget: selectedWidget, title: title))
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

    private func createAddressView(selectedWidget: ConfigWidgetsEnum) -> AnyView {
        return AnyView(ConfigAddressView(
            selectedWidget: selectedWidget,
            configKey: configKey,
            title: title))
    }

    private var configKey: ConfigKeys {
        switch self {
        case .widgetAccessToken: return .widgetAccessToken
        case .apiAccessToken: return .apiAccessToken
        case .gatewayId: return .gatewayId
        case .collectCardholderName: return .collectCardholderName
        case .activePrimaryButton: return .activePrimaryButton
        case .showSubmitButton: return .showSubmitButton
        case .storePin: return .storePin
        case .requestShipping: return .requestShipping
        case .fundingSource: return .fundingSource
        case .clientId: return .clientId
        case .serviceId: return .serviceId
        case .totalAmount: return .totalAmount
        case .currency: return .currency
        case .shippingAddress: return .shippingAddress
        case .billingAddress: return .billingAddress
        case .firstName: return .firstName
        case .lastName: return .lastName
        case .phoneNumber: return .phoneNumber
        case .email: return .email
        case .gender: return .gender
        case .shippingType: return .shippingType
        case .dateOfBirth: return .dateOfBirth
        case .tokenize: return .tokenize
        case .allowSaveCard, .storeSecurityCode, .schemeSupport, .address,
                    .checkoutOptions, .clickToPayMetaConfig, .applePayConfig:
            fatalError("This component doesn't use ConfigKeys")
        }
    }
}
