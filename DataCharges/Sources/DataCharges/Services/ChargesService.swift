//
//  ChargesService.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import CommonModels
import Foundation
import NetworkingLib

public protocol ChargesService {

    // MARK: - ExampleApp Methods (apiAccessToken)

    func initialiseWalletCharge(initializeWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String) async throws -> String
    func initialiseColesPayWalletCharge(
        initializeWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String) async throws -> InitialiseWalletData
    func captureCharge(request: CaptureChargeReq, apiAccessToken: String) async throws -> CaptureChargeResource
    func captureChargeForStandaloneFlow(
        request: CaptureChargeStandaloneReq, apiAccessToken: String
    ) async throws -> CaptureChargeResource
    func captureChargeColesPay(chargeId: String, apiAccessToken: String) async throws -> CaptureChargeResource

    // MARK: - MobileSDK Wallet Methods (widgetAccessToken)

    func captureWalletCharge(widgetAccessToken: String, paymentMethodId: String?, refToken: String?) async throws -> WalletCaptureChargeData
    func getColesPayCallback(widgetAccessToken: String) async throws -> String
    func getPayPalCallback(widgetAccessToken: String, requestShipping: Bool) async throws -> String
    func getAfterpayCallback(widgetAccessToken: String) async throws -> String
    func declineWalletTransaction(widgetAccessToken: String, chargeId: String) async throws -> String
}

public struct ChargesServiceImpl: HTTPClient, ChargesService {

    public init() {}

    public func initialiseWalletCharge(
        initializeWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String
    ) async throws -> String {
        let endpoint = ChargesEndpoints.initialiseWalletCharge(
            initialiseWalletChargeReq: initializeWalletChargeReq, apiAccessToken: apiAccessToken
        )
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: InitialiseWalletChargeRes.self,
            timeout: 60)
        return response.resource.data.token
    }

    public func initialiseColesPayWalletCharge(
        initializeWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String
    ) async throws -> InitialiseWalletData {
        let endpoint = ChargesEndpoints.initialiseColesPayWalletCharge(
            initialiseWalletChargeReq: initializeWalletChargeReq, apiAccessToken: apiAccessToken
        )
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: InitialiseWalletChargeRes.self,
            timeout: 60)
        return response.resource.data
    }

    public func captureCharge(request: CaptureChargeReq, apiAccessToken: String) async throws -> CaptureChargeResource {
        let endpoint = ChargesEndpoints.captureCharge(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: CaptureChargeRes.self,
            timeout: 60)
        return response.resource
    }

    public func captureChargeForStandaloneFlow(
        request: CaptureChargeStandaloneReq, apiAccessToken: String
    ) async throws -> CaptureChargeResource {
        let endpoint = ChargesEndpoints.captureChargeForStandalone(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: CaptureChargeRes.self,
            timeout: 60)
        return response.resource
    }

    public func captureChargeColesPay(chargeId: String, apiAccessToken: String) async throws -> CaptureChargeResource {
        let endpoint = ChargesEndpoints.captureChargeColesPay(chargeId: chargeId, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: CaptureChargeRes.self,
            timeout: 60)
        return response.resource
    }

    // MARK: - MobileSDK Wallet Methods

    public func captureWalletCharge(
        widgetAccessToken: String, paymentMethodId: String?, refToken: String?
    ) async throws -> WalletCaptureChargeData {
        let walletCaptureReq = CaptureWalletChargeReq(
            paymentMethodId: paymentMethodId,
            customer: .init(paymentSource: .init(refToken: refToken))
        )

        let response = try await sendRequest(
            endpoint: ChargesEndpoints.walletCapture(
                capture: true, walletCaptureReq: walletCaptureReq, widgetAccessToken: widgetAccessToken
            ),
            responseModel: WalletCaptureRes.self,
            timeout: 60)

        return response.resource.data
    }

    public func getColesPayCallback(widgetAccessToken: String) async throws -> String {
        let walletCallbackReq = WalletCallbackReq(requestType: "CREATE_SESSION")

        let response = try await sendRequest(
            endpoint: ChargesEndpoints.walletCallback(
                walletCallbackReq: walletCallbackReq, widgetAccessToken: widgetAccessToken
            ),
            responseModel: ColesPayCallbackRes.self,
            timeout: 60,
            maxRetries: 1)

        return response.resource.data.id
    }

    public func getPayPalCallback(widgetAccessToken: String, requestShipping: Bool) async throws -> String {
        let walletCallbackReq = WalletCallbackReq(
            requestType: "CREATE_TRANSACTION",
            requestShipping: requestShipping,
            walletType: "paypal"
        )

        let response = try await sendRequest(
            endpoint: ChargesEndpoints.walletCallback(
                walletCallbackReq: walletCallbackReq, widgetAccessToken: widgetAccessToken
            ),
            responseModel: PayPalCallbackRes.self,
            timeout: 60,
            maxRetries: 1)

        return response.resource.data.id
    }

    public func getAfterpayCallback(widgetAccessToken: String) async throws -> String {
        let walletCallbackReq = WalletCallbackReq(requestType: "CREATE_SESSION")

        let response = try await sendRequest(
            endpoint: ChargesEndpoints.walletCallback(
                walletCallbackReq: walletCallbackReq, widgetAccessToken: widgetAccessToken
            ),
            responseModel: AfterpayCallbackRes.self,
            timeout: 60,
            maxRetries: 1)

        return response.resource.data.refToken
    }

    public func declineWalletTransaction(widgetAccessToken: String, chargeId: String) async throws -> String {
        let endpoint = ChargesEndpoints.declineWalletTransaction(
            chargeId: chargeId, widgetAccessToken: widgetAccessToken
        )
        let response = try await sendRequest(endpoint: endpoint, responseModel: WalletDeclineRes.self, timeout: 60)
        return response.resource.data.status
    }
}
