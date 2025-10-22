//
//  PayPalVaultConfig.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.10.2024..
//

import Foundation
import SwiftUI

public struct PayPalVaultConfig {

    public let accessToken: String
    public let gatewayId: String

    public init(accessToken: String, gatewayId: String) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
    }
}
