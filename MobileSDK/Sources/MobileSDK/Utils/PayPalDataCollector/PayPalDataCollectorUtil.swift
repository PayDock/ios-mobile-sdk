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
    
    private let config: PayPalDataCollectorConfig
    private let clientId: String
    
    // MARK: - Initialization
    
    private init(config: PayPalDataCollectorConfig, clientId: String) {
        self.config = config
        self.clientId = clientId
    }
    
    public static func initializeDataCollector(config: PayPalDataCollectorConfig, completion: @escaping (Result<PayPalDataCollectorUtil, PayPalDataCollectorError>) -> Void) {
        Task {
            do {
                let clientId = try await PayPalVaultMockServiceImpl().getClientId(gatewayId: config.gatewayId, accessToken: config.accessToken)
                let util = PayPalDataCollectorUtil(config: config, clientId: clientId)
                completion(.success(util))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.getPayPalClientId(error: errorResponse)))
            } catch {
                completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }
    
    public func collectDeviceData(additionalData: [String: String]) -> String {
        let config = CoreConfig(clientID: clientId, environment: Constants.payPalVaultEnvironment)
        let payPalDataCollector = PayPalDataCollector(config: config)
        
        let deviceData = payPalDataCollector.collectDeviceData(additionalData: additionalData)
        return deviceData
    }
}
