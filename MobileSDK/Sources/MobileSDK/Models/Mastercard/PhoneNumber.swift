//
//  PhoneNumber.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct PhoneNumber: Codable {
    public let countryCode: String
    public let phoneNumber: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case phoneNumber = "phone_number"
    }
}
