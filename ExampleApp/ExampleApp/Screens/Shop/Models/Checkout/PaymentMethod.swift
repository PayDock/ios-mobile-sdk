//
//  PaymentMethod.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

enum PaymentMethod: CaseIterable {
    case card
    case applePay
    case payPal
    case afterpay
    case mastercard
    case colesPay

    var displayName: String {
        switch self {
        case .card: return "Credit/Debit Card"
        case .applePay: return "Apple Pay"
        case .payPal: return "PayPal"
        case .afterpay: return "Afterpay"
        case .mastercard: return "Mastercard Click to Pay"
        case .colesPay: return "Coles Pay"
        }
    }

    var iconName: String {
        switch self {
        case .card: return "credit-card-fill"
        case .applePay: return "applePay"
        case .payPal: return "payPal"
        case .afterpay: return "afterpay"
        case .mastercard: return "mastercard"
        case .colesPay: return "coles-pay"
        }
    }
}
