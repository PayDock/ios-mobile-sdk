//
//  WalletCaptureRes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.10.2023..
//

import Foundation

public struct WalletCaptureRes: Codable {
    public let status: Int
    public let resource: Resource

    public struct Resource: Codable {
        public let type: String
        public let data: ChargeResponse
    }
}
