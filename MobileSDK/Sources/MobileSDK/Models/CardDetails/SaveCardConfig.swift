//
//  SaveCardConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.05.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct SaveCardConfig {
    public let consentText: String?
    public let privacyPolicyConfig: PrivacyPolicyConfig?

    public init(consentText: String?, privacyPolicyConfig: PrivacyPolicyConfig?) {
        self.consentText = consentText
        self.privacyPolicyConfig = privacyPolicyConfig
    }

    public struct PrivacyPolicyConfig {
        public let privacyPolicyText: String
        public let privacyPolicyURL: String

        public init(privacyPolicyText: String, privacyPolicyURL: String) {
            self.privacyPolicyText = privacyPolicyText
            self.privacyPolicyURL = privacyPolicyURL
        }
    }
}
