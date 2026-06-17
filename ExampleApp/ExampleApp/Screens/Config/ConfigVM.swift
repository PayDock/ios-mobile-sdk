//
//  ConfigVM.swift
//  ExampleApp
//

import Foundation
import MobileSDK
import SwiftUI

class ConfigVM: ObservableObject {
    @Published var selectedWidget: ConfigWidgetsEnum = .card

    func getComponentsForWidget(_ widget: ConfigWidgetsEnum) -> [ConfigComponentsEnum] {
        switch widget {
        case .global:
            return [.apiAccessToken, .totalAmount, .currency]
        case .card:
            return [
                .widgetAccessToken, .gatewayId, .collectCardholderName, .allowSaveCard,
                .storeSecurityCode, .schemeSupport, .activePrimaryButton
            ]
        case .address:
            return [.address]
        case .giftCard:
            return [.widgetAccessToken, .storePin]
        case .paypal:
            return [.widgetAccessToken, .gatewayId, .requestShipping, .fundingSource]
        case .paypalVault:
            return [.widgetAccessToken, .gatewayId]
        case .afterPay:
            return [.checkoutOptions]
        case .colesPay:
            return [.clientId]
        case .clickToPay:
            return [.widgetAccessToken, .clickToPayMetaConfig, .serviceId]
        case .applePay:
            return [.applePayConfig]
        case .zip:
            return [
                .widgetAccessToken,
                .gatewayId,
                .firstName,
                .lastName,
                .email,
                .phoneNumber,
                .tokenize,
                .gender,
                .dateOfBirth,
                .shippingType,
                .billingAddress,
                .shippingAddress
            ]
        }
    }

    func updateConfiguration<T>(for widget: ConfigWidgetsEnum, with config: T) {
        ConfigManager.shared.updateConfiguration(for: widget, with: config)
    }

    func getConfiguration<T>(for widget: ConfigWidgetsEnum, as type: T.Type) -> T? {
        return ConfigManager.shared.getConfiguration(for: widget, as: type)
    }
}
