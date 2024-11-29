//
//  PayPalVaultServiceMock.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 07.10.2024..
//

import XCTest
@testable import MobileSDK
@testable import NetworkingLib

class PayPalVaultServiceMock: Mockable, PayPalVaultService {

    var responseFilename: PayPalFilenames = .authSuccess
    var sendError = false
    
    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String {
        if sendError {
            let errorResponse = loadJSON(filename: responseFilename.rawValue, type: ErrorRes.self)
            throw RequestError.requestError(errorResponse)
        } else {
            let response = loadJSON(filename: PayPalFilenames.authSuccess.rawValue, type: PayPalVaultAuthRes.self)
            return response.resource.data.accessToken
        }
    }
    
    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData {
        if sendError {
            let errorResponse = loadJSON(filename: responseFilename.rawValue, type: ErrorRes.self)
            throw RequestError.requestError(errorResponse)
        } else {
            let response = loadJSON(filename: PayPalFilenames.setupTokenSuccess.rawValue, type: PayPalVaultSetupTokenRes.self)
            return response.resource.data
        }
    }
    
    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        if sendError {
            let errorResponse = loadJSON(filename: responseFilename.rawValue, type: ErrorRes.self)
            throw RequestError.requestError(errorResponse)
        } else {
            let response = loadJSON(filename: PayPalFilenames.getClientId.rawValue, type: PayPalVaultConfigRes.self)
            return response.resource.data.credentials.clientAuth
        }
    }
    
    func createPaymentToken(request: PayPalVaultPaymentTokenReq, setupToken: String, accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData {
        if sendError {
            let errorResponse = loadJSON(filename: responseFilename.rawValue, type: ErrorRes.self)
            throw RequestError.requestError(errorResponse)
        } else {
            let response = loadJSON(filename: PayPalFilenames.createPaymentToken.rawValue, type: PayPalVaultPaymentTokenRes.self)
            return response.resource.data
        }
    }

}
