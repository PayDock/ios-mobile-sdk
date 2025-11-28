//
//  ExternalCheckoutReq.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import Foundation

struct ExternalCheckoutReq: Codable {
    let gatewayId: String
    let meta: ExternalCheckoutMeta
    let successRedirectUrl: String
    let errorRedirectUrl: String
    let redirectUrl: String

    enum CodingKeys: String, CodingKey {
        case gatewayId = "gateway_id"
        case meta = "meta"
        case successRedirectUrl = "success_redirect_url"
        case errorRedirectUrl = "error_redirect_url"
        case redirectUrl = "redirect_url"
    }
}

struct ExternalCheckoutMeta: Codable {
    let firstName: String?
    let lastName: String?
    let email: String?
    let tokenize: Bool?
    let charge: ExternalCheckoutCharge?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case tokenize = "tokenize"
        case charge = "charge"
    }
}

struct ExternalCheckoutCharge: Codable {
    let amount: Double?
    let currency: String?
    let billingAddress: ExternalBillingAddress?

    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case currency = "currency"
        case billingAddress = "billing_address"
    }
}

struct ExternalBillingAddress: Codable {
    let firstName: String?
    let lastName: String?
    let addressLine1: String?
    let addressCity: String?
    let addressState: String?
    let addressCountry: String?
    let addressPostcode: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case addressLine1 = "address_line1"
        case addressCity = "address_city"
        case addressState = "address_state"
        case addressCountry = "address_country"
        case addressPostcode = "address_postcode"
    }
}
