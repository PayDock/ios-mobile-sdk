//
//  WalletService.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.10.2023..
//

import Foundation

protocol WalletService {

    func captureCharge(token: String, paymentMethodId: String?, payerId: String?, refToken: String?) async throws -> ChargeResponse

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

}
