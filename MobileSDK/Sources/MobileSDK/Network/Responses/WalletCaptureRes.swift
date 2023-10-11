//
//  WalletCaptureRes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.10.2023..
//

import Foundation

struct WalletCaptureRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: ChargeResponse
    }
}
