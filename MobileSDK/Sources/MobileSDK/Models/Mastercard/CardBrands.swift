//
//  CardBrands.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public enum CardBrands: String, Codable {
    case mastercard = "mastercard"
    case maestro = "maestro"
    case visa = "visa"
    case amex = "amex"
    case discover = "discover"
}

public enum CheckoutExperience: String, Codable {
    case withingCheckout = "within_checkout"
    case paymentSettings = "payment_settings"
}

public enum Services: String, Codable {
    case inlineCheckout = "inline_checkout"
    case inlineInstallments = "inline_nstallments"
}

public enum MastercardDPAShippingBillingPreference: String, Codable {
    case full = "full"
    case postalCountry = "postal_country"
    case none = "none"
}

public enum MastercardOrderType: String, Codable {
    case splitShipment = "split_shipment"
    case preferredCard = "preferred_card"
}

public enum ApplicationType: String, Codable {
    case webBrowser = "web_browser"
    case mobileApp = "mobile_app"
}
