//
//  CardTokenRes.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
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
