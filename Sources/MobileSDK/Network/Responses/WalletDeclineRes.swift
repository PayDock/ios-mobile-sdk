//
//  WalletDeclineRes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 25.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct WalletDeclineRes: Codable {
    public let status: Int
    public let resource: Resource

    public struct Resource: Codable {
        public let data: Data
    }

    public struct Data: Codable {
        public let status: String
    }
}
