//
//  PayPalDataCollectorUtil.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.11.2024..
//

import CorePayments
import FraudProtection
import NetworkingLib

public class PayPalDataCollectorUtil {
    
    // MARK: - Dependencies
    
    let config: PayPalDataCollectorConfig
    let clientId: String
    
    // MARK: - Initialization
    
    init(config: PayPalDataCollectorConfig, clientId: String) {
        self.config = config
        self.clientId = clientId
    }
    
    public static func initialise(config: PayPalDataCollectorConfig) async throws -> PayPalDataCollectorUtil {
        return try await initialise(config: config, service: PayPalVaultServiceImpl())
    }
    
    static func initialise(config: PayPalDataCollectorConfig, service: PayPalVaultService = PayPalVaultServiceImpl()) async throws -> PayPalDataCollectorUtil {
        do {
            let clientId = try await service.getClientId(gatewayId: config.gatewayId, accessToken: config.accessToken)
            return PayPalDataCollectorUtil(config: config, clientId: clientId)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            throw PayPalDataCollectorError.initialisationClientId(error: errorResponse)
        } catch {
            throw PayPalDataCollectorError.unknownError(error as? RequestError)
        }
    }
    
    public func collectDeviceData(additionalData: [String: String] = [:]) -> String {
        let config = CoreConfig(clientID: clientId, environment: Constants.payPalVaultEnvironment)
        let payPalDataCollector = PayPalDataCollector(config: config)
        
        let deviceData = payPalDataCollector.collectDeviceData(additionalData: additionalData)
        return deviceData
    }
}
