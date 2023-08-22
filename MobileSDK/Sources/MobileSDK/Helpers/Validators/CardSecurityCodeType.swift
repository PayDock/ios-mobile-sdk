//
//  CardSecurityCodeType.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 16.08.2023..
//

import Foundation

enum CardSecurityCodeType {

    case cvv
    case cvc
    case csc

    var requiredDigits: Int {
        switch self {
        case .cvv, .cvc: return 3
        case .csc: return 4
        }
    }

}
