//
//  WalletServiceMock.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
@testable import MobileSDK

class WalletServiceMock: Mockable, WalletService {
    func captureCharge(token: String, paymentMethodId: String?, payerId: String?, refToken: String?) async throws -> ChargeResponse {
        return ChargeResponse(status: "", amount: 1.0, currency: "")
    }
    
    func getCallback(token: String, shipping: Bool) async throws -> String {
        return ""
    }
    
    func getFlyPayCallback(token: String) async throws -> String {
        return ""
    }
    
    func getAfterpayCallback(token: String) async throws -> String {
        return ""
    }
    
    func declineWalletTransaction(token: String, chargeId: String) async throws -> String {
        return ""
    }
}
