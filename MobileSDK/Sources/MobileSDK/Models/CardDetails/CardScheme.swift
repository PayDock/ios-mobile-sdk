//
//  CardScheme.swift
//  MobileSDK
//
//  Created by Ricardo Da Silva on 2024/12/29.
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public enum CardScheme: String, CaseIterable {
    
    case amex
    case ausbc
    case diners
    case discover
    case japcb
    case mastercard
    case solo
    case visa
    
    var voiceoverName: String {
        switch self {
        case .amex: return "American Express"
        case .ausbc: return "Australian Commonwealth Bank"
        case .diners: return "Diners"
        case .discover: return "Discover"
        case .japcb: return "JCB"
        case .mastercard: return "Mastercard"
        case .solo: return "Solo"
        case .visa: return "Visa"
        }
    }
    
    static let preferredOrder: [CardScheme] = [
        .visa, .mastercard, .amex, .ausbc, .diners, .discover, .japcb, .solo
    ]
    
    static func sortedArray(from set: Set<CardScheme>) -> [CardScheme] {
        return set.sorted { preferredOrder.firstIndex(of: $0)! < preferredOrder.firstIndex(of: $1)! }
    }
}
