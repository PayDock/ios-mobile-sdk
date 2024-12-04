//
//  PayPalVaultSetupTokenReq.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 08.10.2024..
//

struct PayPalVaultSetupTokenReq: Encodable {
    
    let gatewayId: String
<<<<<<< HEAD
=======
    let token: String
>>>>>>> main
    let returnUrl = "sdk.ios.paypal://vault/success"
    let cancelUrl = "sdk.ios.paypal://vault/cancel"
    
}
