//
//  BinSchema.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 27.01.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

struct BinSchemaRes: Decodable {
    let cardSchemas: [BinSchema]
    
    struct BinSchema: Decodable {
        let bin: String
        let schema: String
    }
}
