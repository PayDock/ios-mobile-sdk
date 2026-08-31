//
//  CardSchemeConfig.swift
//  MobileSDK
//

public struct SupportedSchemesConfig {
    public let supportedSchemes: Set<CardScheme>?
    public let enableValidation: Bool
    public let showSchemeList: Bool

    public init(
        supportedSchemes: Set<CardScheme>? = nil,
        enableValidation: Bool = false,
        showSchemeList: Bool = true
    ) {
        self.supportedSchemes = supportedSchemes
        self.enableValidation = enableValidation
        self.showSchemeList = showSchemeList
    }
}
