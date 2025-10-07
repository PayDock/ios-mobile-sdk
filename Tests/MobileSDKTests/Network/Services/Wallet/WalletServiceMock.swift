//
//  WalletServiceMock.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
@testable import MobileSDK

class WalletServiceMock: Mockable, WalletService {

    // Properties for error simulation
    var shouldReturnError = false
    var errorToReturn: AfterpayError?

    func captureCharge(token: String, paymentMethodId: String?, payerId: String?, refToken: String?) async throws -> ChargeResponse {
        if shouldReturnError, let error = errorToReturn {
            throw error
        }
        return ChargeResponse(status: "", amount: 1.0, currency: "")
    }

    func getCallback(token: String, shipping: Bool) async throws -> String {
        if shouldReturnError, let error = errorToReturn {
            throw error
        }
        return ""
    }

    func getColesPayCallback(token: String) async throws -> String {
        if shouldReturnError, let error = errorToReturn {
            throw error
        }
        return ""
    }

    func getAfterpayCallback(token: String) async throws -> String {
        if shouldReturnError, let error = errorToReturn {
            throw error
        }
        return ""
    }

    func declineWalletTransaction(token: String, chargeId: String) async throws -> String {
        if shouldReturnError, let error = errorToReturn {
            throw error
        }
        return ""
    }
}
