//
//  FlyPayCallbackRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 15.01.2024..
//

import Foundation

struct FlyPayCallbackRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: CallbackData
    }

    struct CallbackData: Codable {
        let id: String
        let charge: Charge

        struct Charge: Codable {
            let status: String
        }
    }
}

