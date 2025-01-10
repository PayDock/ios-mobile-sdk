//
//  CardSchemeConfig.swift
//  MobileSDK
//
//  Created by Ricardo Da Silva on 2025/01/09.
//

public struct SupportedSchemesConfig {
    public let supportedSchemes: Set<CardScheme>?
    public let enableValidation: Bool

    public init(
        supportedSchemes: Set<CardScheme>? = nil,
        enableValidation: Bool = false
    ) {
        self.supportedSchemes = supportedSchemes
        self.enableValidation = enableValidation
    }
}
