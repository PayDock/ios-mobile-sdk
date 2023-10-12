//
//  WalletService.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.10.2023..
//

import Foundation

protocol WalletService {

    func captureCharge(token: String, paymentMethodId: String?, payerId: String?, refToken: String?) async throws -> ChargeResponse
    func getCallback(token: String) async throws -> String

}

struct WalletServiceImpl: HTTPClient, WalletService {

    func captureCharge(token: String, paymentMethodId: String?, payerId: String?, refToken: String?) async throws -> ChargeResponse {
        let walletCaptureReq = WalletCaptureReq(
            paymentMethodId: paymentMethodId,
            customer: .init(paymentSource: .init(externalPayerId: payerId, refToken: refToken)))
        
        let response = try await sendRequest(
            endpoint: WalletEndpoints.walletCapture(token: token, walletCaptureReq: walletCaptureReq),
            responseModel: WalletCaptureRes.self)
        
        return response.resource.data
    }

    func getCallback(token: String) async throws -> String {
        let walletCallbackReq = WalletCallbackReq(type: "CREATE_TRANSACTION", shipping: false, sessionId: nil, walletType: nil)

        let response = try await sendRequest(
            endpoint: WalletEndpoints.walletCallback(
                token: token,
                walletCallbackReq: walletCallbackReq),
            responseModel: WalletCallbackRes.self)

        return response.resource.data.callbackUrl
    }

}
