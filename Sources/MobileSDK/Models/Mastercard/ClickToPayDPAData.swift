//
//  MastercardDpaData.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

public struct ClickToPayDPAData: Codable {
    public var dpaAddress: String? = nil
    public var dpaEmailAddress: String? = nil
    public var dpaPhoneNumber: PhoneNumber? = nil
    public var dpaLogoUri: String? = nil
    public var dpaSupportedEmailAddress: String? = nil
    public var dpaSupportedPhoneNumber: PhoneNumber? = nil
    public var dpaUri: String? = nil
    public var dpaSupportUri: String? = nil
    public var applicationType: ApplicationType? = nil

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
