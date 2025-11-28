//
//  ExternalCheckoutRes.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct ExternalCheckoutRes: Codable {
    let status: Int
    let error: String?
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: CheckoutData
    }

    struct CheckoutData: Codable {
        let link: String
        let token: String
    }
}
