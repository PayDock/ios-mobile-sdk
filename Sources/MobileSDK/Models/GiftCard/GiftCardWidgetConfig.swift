//
//  GiftCardWidgetConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 30.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

public struct GiftCardWidgetConfig {
    
    public let accessToken: String
    public let storePin: Bool
    
    public init(accessToken: String,
         storePin: Bool = true) {
        self.accessToken = accessToken
        self.storePin = storePin
    }
}
