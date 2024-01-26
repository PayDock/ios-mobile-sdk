//
//  CardTokenRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 27.07.2023..
//

import Foundation

struct CardTokenRes: Codable {

    let status: Int
    let error: ErrorRes?
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: String
    }

}
