//
//  MastercardDpaData.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

public struct ClickToPayDPAData: Codable {
    public var dpaAddress: String?
    public var dpaEmailAddress: String?
    public var dpaPhoneNumber: PhoneNumber?
    public var dpaLogoUri: String?
    public var dpaSupportedEmailAddress: String?
    public var dpaSupportedPhoneNumber: PhoneNumber?
    public var dpaUri: String?
    public var dpaSupportUri: String?
    public var applicationType: ApplicationType?

    public init(dpaAddress: String? = nil,
                dpaEmailAddress: String? = nil,
                dpaPhoneNumber: PhoneNumber? = nil,
                dpaLogoUri: String? = nil,
                dpaSupportedEmailAddress: String? = nil,
                dpaSupportedPhoneNumber: PhoneNumber? = nil,
                dpaUri: String? = nil,
                dpaSupportUri: String? = nil,
                applicationType: ApplicationType? = nil) {
        self.dpaAddress = dpaAddress
        self.dpaEmailAddress = dpaEmailAddress
        self.dpaPhoneNumber = dpaPhoneNumber
        self.dpaLogoUri = dpaLogoUri
        self.dpaSupportedEmailAddress = dpaSupportedEmailAddress
        self.dpaSupportedPhoneNumber = dpaSupportedPhoneNumber
        self.dpaUri = dpaUri
        self.dpaSupportUri = dpaSupportUri
        self.applicationType = applicationType
    }

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
