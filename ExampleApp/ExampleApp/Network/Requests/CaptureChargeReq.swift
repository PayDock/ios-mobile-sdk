//
//  CaptureChargeReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation

struct CaptureChargeReq: Codable {
    let amount: String
    let currency: String
    let reference: String
    let description: String
    let _3ds: ThreeDS
    
    struct ThreeDS: Codable {
        let _id: String
        
        enum CodingKeys: String, CodingKey {
            case _id = "id"
        }
    }
}
