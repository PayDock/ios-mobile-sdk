//
//  AfterpaySdkConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Afterpay
import Foundation

struct AfterpaySdkConfig {
    let buttonTheme: ButtonTheme
    let config: AfterPayConfiguration
    let options: CheckoutOptions

    struct ButtonTheme {
        let buttonType: ButtonKind = .buyNow
        let colorScheme: ColorScheme = .static(.blackOnMint)
    }

    struct CheckoutOptions {
        let pickup: Bool? = nil
        let buyNow: Bool? = nil
        let shippingOptionRequired: Bool? = nil
        let enableSingleShippingOptionUpdate: Bool? = nil
    }

    struct AfterPayConfiguration {
        let minimumAmount: String? = nil
        let maximumAmount: String
        let currency: String
        let language: String = Locale.current.language.languageCode?.identifier ?? "EN_au"
        let country: String = Locale.current.region?.identifier ?? "AU"
    }

}
