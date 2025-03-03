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
    public let actionText: String?
    public var icon: Icon
    
    public init(accessToken: String, gatewayId: String, actionText: String? = nil, icon: Icon = .defaultIcon) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.actionText = actionText
        self.icon = icon
    }
    
    public enum Icon {
        case none
        case defaultIcon
        case customIcon(image: Image)
    }
}
