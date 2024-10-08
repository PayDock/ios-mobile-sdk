//
//  WalletService.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.10.2023..
//

import Foundation
import NetworkingLib

protocol WalletService {

    func captureCharge(token: String, paymentMethodId: String?, payerId: String?, refToken: String?) async throws -> ChargeResponse
    func getCallback(token: String, shipping: Bool) async throws -> String
    func getFlyPayCallback(token: String) async throws -> String
    func getAfterpayCallback(token: String) async throws -> String
    func declineWalletTransaction(token: String, chargeId: String) async throws -> String

}

struct WalletServiceImpl: HTTPClient, WalletService {

    func captureCharge(token: String, paymentMethodId: String?, payerId: String?, refToken: String?) async throws -> ChargeResponse {
        let walletCaptureReq = WalletCaptureReq(
            paymentMethodId: paymentMethodId,
            customer: .init(paymentSource: .init(externalPayerId: nil, refToken: refToken)))

        let response = try await sendRequest(
            endpoint: WalletEndpoints.walletCapture(capture: true, token: token, walletCaptureReq: walletCaptureReq),
            responseModel: WalletCaptureRes.self)

        return response.resource.data
    }

    func getCallback(token: String, shipping: Bool) async throws -> String {
        let walletCallbackReq = WalletCallbackReq(type: "CREATE_TRANSACTION", shipping: shipping, sessionId: nil, walletType: nil)

        let response = try await sendRequest(
            endpoint: WalletEndpoints.walletCallback(
                token: token,
                walletCallbackReq: walletCallbackReq),
            responseModel: WalletCallbackRes.self)

        return response.resource.data.callbackUrl
    }

    func getFlyPayCallback(token: String) async throws -> String {
        let walletCallbackReq = WalletCallbackReq(type: "CREATE_SESSION", shipping: nil, sessionId: nil, walletType: "flypay")

        let response = try await sendRequest(
            endpoint: WalletEndpoints.walletCallback(
                token: token,
                walletCallbackReq: walletCallbackReq),
            responseModel: FlyPayCallbackRes.self)

        return response.resource.data.id
    }

    func getAfterpayCallback(token: String) async throws -> String {
        let walletCallbackReq = WalletCallbackReq(type: "CREATE_SESSION", shipping: nil, sessionId: nil, walletType: nil)

        let response = try await sendRequest(
            endpoint: WalletEndpoints.walletCallback(
                token: token,
                walletCallbackReq: walletCallbackReq),
            responseModel: AfterpayCallbackRes.self)

        return response.resource.data.refToken
    }

    func declineWalletTransaction(token: String, chargeId: String) async throws -> String {
        let endpoint = WalletEndpoints.declineWalletTransaction(token: token, chargeId: chargeId)
        let response = try await sendRequest(endpoint: endpoint, responseModel: WalletDeclineRes.self)
        return response.resource.status

    }

}
