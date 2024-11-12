//
//  PayPalDataCollectorConfig.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.11.2024..
//

public struct PayPalDataCollectorConfig {
    
    public let accessToken: String
    public let gatewayId: String
    
    public init(accessToken: String, gatewayId: String) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
    }
}
