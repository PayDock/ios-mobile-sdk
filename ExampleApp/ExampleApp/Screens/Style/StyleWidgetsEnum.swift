//
//  StyleWidgetsEnum.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

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
    case integrated3ds
    case standalone3ds

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
        case .integrated3ds: return "Integrated 3DS"
        case .standalone3ds: return "Standalone 3DS"
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
        case .integrated3ds: Image("integrated-3ds-style")
        case .standalone3ds: Image("standalone-3ds-style")
        }
    }
}
