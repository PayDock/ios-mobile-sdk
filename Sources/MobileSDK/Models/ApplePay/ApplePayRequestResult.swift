//
//  ApplePayRequestResult.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.06.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation
import PassKit

public struct ApplePayRequestResult {

    public let request: PKPaymentRequest
    public let token: String

    public init(request: PKPaymentRequest, token: String) {
        self.request = request
        self.token = token
    }
}
