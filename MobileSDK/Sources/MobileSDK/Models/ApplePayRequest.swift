//
//  ApplePayRequest.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 05.10.2023..
//

import PassKit

public struct ApplePayRequest {

    public init(token: String, merchanIdentifier: String, request: PKPaymentRequest) {
        self.token = token
        self.merchanIdentifier = merchanIdentifier
        self.request = request
    }
    
    public let token: String
    public let merchanIdentifier: String
    public let request: PKPaymentRequest

}
