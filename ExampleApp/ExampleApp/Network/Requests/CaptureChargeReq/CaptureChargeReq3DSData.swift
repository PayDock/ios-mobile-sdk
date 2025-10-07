//
//  CaptureChargeReq3DSData.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct CaptureChargeReq3DSData: Codable {
    let id3DS: String

    enum CodingKeys: String, CodingKey {
        case id3DS = "id"
    }
}
