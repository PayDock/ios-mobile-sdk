//
//
//  ConfigWidgetsEnum.swift
//  ExampleApp
//

import Foundation
import SwiftUI

enum ConfigWidgetsEnum {
    case global
    case card
    case address
    case giftCard
    case paypal
    case paypalVault
    case afterPay
    case colesPay
    case clickToPay
    case applePay
    case zip

    var title: String {
        switch self {
        case .global: return "All Widgets"
        case .card: return "Card Details"
        case .address: return "Address"
        case .giftCard: return "Gift Card"
        case .paypal: return "PayPal"
        case .paypalVault: return "PayPal Vault"
        case .afterPay: return "Afterpay"
        case .colesPay: return "Coles Pay"
        case .clickToPay: return "Click to Pay"
        case .applePay: return "Apple Pay"
        case .zip: return "Zip"
        }
    }

    var icon: Image {
        switch self {
        case .global: Image("all-widgets-style")
        case .card: Image("card-style")
        case .address: Image("address-style")
        case .giftCard: Image("gift-card-style")
        case .paypal: Image("paypal-style")
        case .paypalVault: Image("paypal-style")
        case .afterPay: Image("afterpay-style")
        case .colesPay: Image("coles-pay-style")
        case .clickToPay: Image("click-to-pay-style")
        case .applePay: Image("apple-pay-style")
        case .zip: Image("zip")
        }
    }
}
