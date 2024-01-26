//
//  ApplePayError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.10.2023..
//

import Foundation

public enum ApplePayError: Error {

    case initFailed
    case paymentFailed

    public var customMessage: String {
        switch self {
        case .initFailed:
            return "Initialisation of Apple Pay has failed!"
        case .paymentFailed:
            return "Payment Failed!"
        }
    }
}
