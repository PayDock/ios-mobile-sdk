//
//  PaymentOption.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct PaymentOption: Codable {
    public var dynamicDataType: String? = nil

    enum CodingKeys: String, CodingKey {
        case dynamicDataType = "dynamic_data_type"
    }
}
