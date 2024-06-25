//
//  MastercardSrcMeta.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 14.03.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct MastercardSrcMeta: Codable {
    public let dpaData: MastercardDpaData?
    public let disableSummaryScreen: Bool?
    public let cardBrands: [CardBrands]?
    public let coBrandNames: [String]?
    public let checkoutExperience: CheckoutExperience?
    public let services: Services?
    public let dpaTransactionOptions: MastercardDpaOptions?

    public init(dpaData: MastercardDpaData? = nil,
                disableSummaryScreen: Bool? = nil,
                cardBrands: [CardBrands]? = nil,
                coBrandNames: [String]? = nil,
                checkoutExperience: CheckoutExperience? = nil,
                services: Services? = nil,
                dpaTransactionOptions: MastercardDpaOptions? = nil) {
        self.dpaData = dpaData
        self.disableSummaryScreen = disableSummaryScreen
        self.cardBrands = cardBrands
        self.coBrandNames = coBrandNames
        self.checkoutExperience = checkoutExperience
        self.services = services
        self.dpaTransactionOptions = dpaTransactionOptions
    }

    enum CodingKeys: String, CodingKey {
        case dpaData = "dpa_data"
        case disableSummaryScreen = "disable_summary_screen"
        case cardBrands = "card_brands"
        case coBrandNames = "co_brand_names"
        case checkoutExperience = "checkout_experience"
        case services
        case dpaTransactionOptions = "dpa_transaction_options"
    }
}
