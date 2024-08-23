//
//  MastercardResult.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 14.03.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct ClickToPayResult {
    public let event: EventType
    public let mastercardToken: String
    
    public enum EventType: String {
        case checkoutCompleted
        case checkoutReady
        case checkoutError
    }
}
