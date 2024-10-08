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
    
    func createToken(gatewayId: String, accessToken: String) async throws -> String {
        if sendError {
            let errorResponse = loadJSON(filename: responseFilename.rawValue, type: ErrorRes.self)
            throw RequestError.requestError(errorResponse)
        } else {
            let response = loadJSON(filename: responseFilename.rawValue, type: PayPalVaultAuthRes.self)
            return response.resource.data.accessToken
        }
    }

}
