//
//  CardScheme.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public enum CardScheme: String, CaseIterable {

    case amex
    case diners
    case discover
    case japcb
    case mastercard
    case visa
    case unionpay

    var voiceoverName: String {
        switch self {
        case .amex: return "American Express"
        case .diners: return "Diners Club"
        case .discover: return "Discover"
        case .japcb: return "JCB"
        case .mastercard: return "Mastercard"
        case .visa: return "Visa"
        case .unionpay: return "UnionPay International"
        }
    }

    static let preferredOrder: [CardScheme] = [
        .visa, .mastercard, .amex, .diners, .discover, .japcb, .unionpay
    ]

    static func sortedArray(from set: Set<CardScheme>) -> [CardScheme] {
        return set.sorted { preferredOrder.firstIndex(of: $0)! < preferredOrder.firstIndex(of: $1)! }
    }
}
