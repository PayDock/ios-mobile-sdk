//
//  ApplePayRequest.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.10.2023..
//

import PassKit

public struct ApplePayRequest {

    public init(token: String, request: PKPaymentRequest) {
        self.token = token
        self.request = request
    }
    
    public let token: String
    public let request: PKPaymentRequest

}
