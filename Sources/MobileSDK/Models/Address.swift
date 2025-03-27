//
//  Address.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 28.08.2023..
//

import Foundation

public struct Address {

    public let firstName: String
    public let lastName: String
    public let addressLine1: String
    public let addressLine2: String
    public let city: String
    public let state: String
    public let postcode: String
    public let country: String

    public init(firstName: String = "",
         lastName: String = "",
         addressLine1: String = "",
         addressLine2: String = "",
         city: String = "",
         state: String = "",
         postcode: String = "",
         country: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.postcode = postcode
        self.country = country
    }

}
