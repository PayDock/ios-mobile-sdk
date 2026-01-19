//
//  VaultTokenRes.swift
//  DataVault
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import CommonModels

/// Response model for POST /v1/vault/payment_sources (convert token to vault token)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#75616a8a-be50-4e45-aca8-23290fb64254
public struct VaultTokenRes: Codable {
    /// HTTP status code of the response
    public let status: Int

    /// Resource data containing vault token information
    public let resource: VaultTokenResource

    public enum CodingKeys: String, CodingKey {
        case status
        case resource
    }

    public init(status: Int, resource: VaultTokenResource) {
        self.status = status
        self.resource = resource
    }
}

/// Resource wrapper for vault token response
public struct VaultTokenResource: Codable {
    /// Resource type identifier
    public let type: String

    /// Vault token data
    public let data: VaultTokenData

    public init(type: String, data: VaultTokenData) {
        self.type = type
        self.data = data
    }
}

/// Vault token data structure
public struct VaultTokenData: Codable {
    /// The vault token created from the payment source token
    public let vaultToken: String

    /// Payment source type
    public let type: String

    /// Company identifier
    public let companyId: String

    /// Last 4 digits of card number (optional)
    public let cardNumberLast4: String?

    /// Card BIN (first 6-8 digits) (optional)
    public let cardNumberBin: String?

    /// Card scheme (e.g., "visa", "mastercard") (optional)
    public let cardScheme: String?

    /// Payment source status
    public let status: String

    /// Card expiration month (optional)
    public let expireMonth: Int?

    /// Card expiration year (optional)
    public let expireYear: Int?

    /// Creation timestamp
    public let createdAt: String

    /// Last update timestamp
    public let updatedAt: String

    /// Whether CVV is stored in vault (optional)
    public let vaultCcvStored: Bool?

    /// Vault type (e.g., "session", "permanent")
    public let vaultType: String

    /// Address line 1 (optional)
    public let addressLine1: String?

    /// Address city (optional)
    public let addressCity: String?

    /// Address postal code (optional)
    public let addressPostcode: String?

    /// Address state (optional)
    public let addressState: String?

    /// Address country (optional)
    public let addressCountry: String?

    /// Service identifier (optional)
    public let serviceId: String?

    /// Service name (optional)
    public let serviceName: String?

    /// Service type (optional)
    public let serviceType: String?

    /// Service group (optional)
    public let serviceGroup: String?

    /// Wallet type (optional, e.g., "apple", "google")
    public let walletType: String?

    /// Cryptogram information for wallet payments (optional)
    public let cryptogram: VaultTokenCryptogram?

    public init(vaultToken: String,
                type: String,
                companyId: String,
                cardNumberLast4: String?,
                cardNumberBin: String?,
                cardScheme: String?,
                status: String,
                expireMonth: Int?,
                expireYear: Int?,
                createdAt: String,
                updatedAt: String,
                vaultCcvStored: Bool?,
                vaultType: String,
                addressLine1: String?,
                addressCity: String?,
                addressPostcode: String?,
                addressState: String?,
                addressCountry: String?,
                serviceId: String?,
                serviceName: String?,
                serviceType: String?,
                serviceGroup: String?,
                walletType: String?,
                cryptogram: VaultTokenCryptogram?) {
        self.vaultToken = vaultToken
        self.type = type
        self.companyId = companyId
        self.cardNumberLast4 = cardNumberLast4
        self.cardNumberBin = cardNumberBin
        self.cardScheme = cardScheme
        self.status = status
        self.expireMonth = expireMonth
        self.expireYear = expireYear
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.vaultCcvStored = vaultCcvStored
        self.vaultType = vaultType
        self.addressLine1 = addressLine1
        self.addressCity = addressCity
        self.addressPostcode = addressPostcode
        self.addressState = addressState
        self.addressCountry = addressCountry
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.serviceType = serviceType
        self.serviceGroup = serviceGroup
        self.walletType = walletType
        self.cryptogram = cryptogram
    }
}

/// Cryptogram information for wallet payments
public struct VaultTokenCryptogram: Codable {
    /// Cryptogram format (e.g., "3DSECURE")
    public let format: String

    /// Cryptogram identifier
    public let cryptogramId: String

    public init(format: String, cryptogramId: String) {
        self.format = format
        self.cryptogramId = cryptogramId
    }
}
