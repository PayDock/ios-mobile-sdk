//
//  MastercardDpaData.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

public struct MastercardDpaData: Codable {
    public let dpaAddress: String? = nil
    public let dpaEmailAddress: String? = nil
    public let dpaPhoneNumber: PhoneNumber? = nil
    public let dpaLogoUri: String? = nil
    public let dpaSupportedEmailAddress: String? = nil
    public let dpaSupportedPhoneNumber: PhoneNumber? = nil
    public let dpaUri: String? = nil
    public let dpaSupportUri: String? = nil
    public let applicationType: ApplicationType? = nil

    enum CodingKeys: String, CodingKey {
        case dpaAddress = "dpa_address"
        case dpaEmailAddress = "dpa_email_address"
        case dpaPhoneNumber = "dpa_phone_number"
        case dpaLogoUri = "dpa_logo_uri"
        case dpaSupportedEmailAddress = "dpa_supported_email_address"
        case dpaSupportedPhoneNumber = "dpa_supported_phone_number"
        case dpaUri = "dpa_uri"
        case dpaSupportUri = "dpa_support_uri"
        case applicationType = "application_type"
    }
}
