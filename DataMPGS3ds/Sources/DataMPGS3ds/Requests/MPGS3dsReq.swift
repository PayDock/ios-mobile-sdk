//
//  MPGS3dsReq.swift
//  DataMPGS3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/charges/3ds (Integrated 3D Secure)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#fdde4af3-24da-458b-b1b7-96cc56132a79
public struct MPGS3dsReq: Codable {

    /// The amount to charge (required)
    public let amount: String

    /// Currency code (e.g., "USD", "AUD", "EUR") (required)
    public let currency: String

    /// Merchant reference for the charge (optional)
    public let reference: String?

    /// 3D Secure authentication data (required)
    public let threeDS: MPGS3dsData

    /// Payment source token (required)
    public let token: String

    public enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case reference
        case threeDS = "_3ds"
        case token
    }

    public init(amount: String,
                currency: String,
                reference: String? = nil,
                threeDS: MPGS3dsData,
                token: String) {
        self.amount = amount
        self.currency = currency
        self.reference = reference
        self.threeDS = threeDS
        self.token = token
    }
}

/// 3D Secure data structure for integrated 3DS requests
public struct MPGS3dsData: Codable {
    /// Browser details for 3DS authentication (required)
    public let browserDetails: MPGS3dsBrowserDetails

    public init(browserDetails: MPGS3dsBrowserDetails) {
        self.browserDetails = browserDetails
    }
}

/// Browser details structure for 3D Secure authentication
public struct MPGS3dsBrowserDetails: Codable {

    /// Color depth of the browser display (e.g., "24") (required)
    public let colorDepth: String

    /// Whether Java is enabled in the browser (e.g., "true") (required)
    public let javaEnabled: String

    /// Browser language setting (e.g., "en-US") (required)
    public let language: String

    /// Browser name (e.g., "chrome") (required)
    public let name: String

    /// Screen height in pixels (e.g., "640") (required)
    public let screenHeight: String

    /// Screen width in pixels (e.g., "480") (required)
    public let screenWidth: String

    /// Time zone offset in minutes (e.g., "273") (required)
    public let timeZone: String

    public init(colorDepth: String = "24",
                javaEnabled: String = "true",
                language: String = "en-US",
                name: String = "chrome",
                screenHeight: String = "640",
                screenWidth: String = "480",
                timeZone: String = "273") {
        self.colorDepth = colorDepth
        self.javaEnabled = javaEnabled
        self.language = language
        self.name = name
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        self.timeZone = timeZone
    }
}
