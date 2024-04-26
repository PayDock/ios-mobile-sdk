//
//  MastercardSrcMeta.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 14.03.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct MastercardSrcMeta: Codable {
    public let dpaData: MastercardDpaData? = nil
    public let disableSummaryScreen: Bool? = nil
    public let cardBrands: [CardBrands]? = nil
    public let coBrandNames: [String]? = nil
    public let checkoutExperience: CheckoutExperience? = nil
    public let services: Services? = nil
    public let dpaTransactionOptions: MastercardDpaOptions? = nil

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
