//
//  SaveCardConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public struct SaveCardConfig {
    public let consentText: String?
    public let privacyPolicyConfig: PrivacyPolicyConfig?

    public init(consentText: String? = "Remember this card for next time.",
                privacyPolicyConfig: PrivacyPolicyConfig?) {
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
