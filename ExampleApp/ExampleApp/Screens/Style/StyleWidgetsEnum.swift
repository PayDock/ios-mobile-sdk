//
//  StyleWidgetsEnum.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

enum WidgetsEnum {
    case all
    case card
    case address
    case giftCard
    case paypal
    case paypalVault
    case colesPay
    case afterPay
    case clickToPay
    case applePay
    case mpgs3ds
    case standalone3ds
    case zip

    var title: String {
        switch self {
        case .all: return "All widgets"
        case .card: return "Card Details"
        case .address: return "Address"
        case .giftCard: return "Gift Card"
        case .paypal: return "PayPal"
        case .paypalVault: return "PayPal Vault"
        case .colesPay: return "Coles Pay"
        case .afterPay: return "Afterpay"
        case .clickToPay: return "Click to Pay"
        case .applePay: return "Apple Pay"
        case .mpgs3ds: return "MPGS 3DS"
        case .standalone3ds: return "Standalone 3DS"
        case .zip: return "Zip"
        }
    }

    var icon: Image {
        switch self {
        case .all: Image("all-widgets-style")
        case .card: Image("card-style")
        case .address: Image("address-style")
        case .giftCard: Image("gift-card-style")
        case .paypal: Image("paypal-style")
        case .paypalVault: Image("paypal-style")
        case .colesPay: Image("coles-pay-style")
        case .afterPay: Image("afterpay-style")
        case .clickToPay: Image("click-to-pay-style")
        case .applePay: Image("apple-pay-style")
        case .mpgs3ds: Image("integrated-3ds-style")
        case .standalone3ds: Image("standalone-3ds-style")
        case .zip: Image("zip")
        }
    }
}
