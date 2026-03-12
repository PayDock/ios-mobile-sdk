//
//  ChargesEndpoints.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public enum ChargesEndpoints {

    // MARK: - ExampleApp Endpoints (apiAccessToken)

    case initialiseWalletCharge(initialiseWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String)
    case initialiseColesPayWalletCharge(initialiseWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String)
    case captureCharge(request: CaptureChargeReq, apiAccessToken: String)
    case captureChargeForStandalone(request: CaptureChargeStandaloneReq, apiAccessToken: String)
    case captureChargeColesPay(chargeId: String, apiAccessToken: String)

    // MARK: - MobileSDK Wallet Endpoints (widgetAccessToken)

    case walletCapture(capture: Bool, walletCaptureReq: CaptureWalletChargeReq, widgetAccessToken: String)
    case walletCallback(walletCallbackReq: WalletCallbackReq, widgetAccessToken: String)
    case declineWalletTransaction(chargeId: String, widgetAccessToken: String)
}

extension ChargesEndpoints: Endpoint {

    public var path: String {
        switch self {
        case .initialiseWalletCharge, .initialiseColesPayWalletCharge: return "/v1/charges/wallet"
        case .captureCharge: return "/v1/charges"
        case .captureChargeForStandalone: return "/v1/charges"
        case .captureChargeColesPay(let chargeId, _): return "/v1/charges/\(chargeId)/capture"
        case .walletCapture: return "/v1/charges/wallet/capture"
        case .walletCallback: return "/v1/charges/wallet/callback"
        case .declineWalletTransaction(let chargeId, _): return "/v1/charges/wallet/\(chargeId)/decline"
        }
    }

    public var method: RequestMethod {
        switch self {
        case .initialiseWalletCharge: return .post
        case .initialiseColesPayWalletCharge: return .post
        case .captureCharge: return .post
        case .captureChargeForStandalone: return .post
        case .captureChargeColesPay: return .post
        case .walletCapture, .walletCallback, .declineWalletTransaction: return .post
        }
    }

    public var header: [String: String]? {
        switch self {
        case .initialiseWalletCharge(_, let token),
             .initialiseColesPayWalletCharge(_, let token),
             .captureCharge(_, let token),
             .captureChargeForStandalone(_, let token),
             .captureChargeColesPay(_, let token):
            return [
                "x-access-token": token,
                "Content-Type": "application/json;charset=utf-8"
            ]
        case .walletCapture(_, _, let token),
             .walletCallback(_, let token),
             .declineWalletTransaction(_, let token):
            return [
                "x-access-token": token,
                "Content-Type": "application/json"
            ]
        }
    }

    public var body: Data? {
        switch self {
        case .initialiseWalletCharge(let request, _): return try? encoder.encode(request)
        case .initialiseColesPayWalletCharge(let request, _): return try? encoder.encode(request)
        case .captureCharge(let request, _): return try? encoder.encode(request)
        case .captureChargeForStandalone(let request, _): return try? encoder.encode(request)
        case .captureChargeColesPay: return nil
        case .walletCapture(_, let request, _): return try? encoder.encode(request)
        case .walletCallback(let request, _): return try? encoder.encode(request)
        case .declineWalletTransaction: return nil
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        case .initialiseWalletCharge: return [URLQueryItem(name: "capture", value: "true")]
        case .initialiseColesPayWalletCharge: return [URLQueryItem(name: "capture", value: "false")]
        case .captureChargeColesPay: return [URLQueryItem(name: "mobile", value: "true")]
        case .captureCharge, .captureChargeForStandalone: return []
        case let .walletCapture(capture, _, _): return capture ? [URLQueryItem(name: "capture", value: "true")] : []
        case .walletCallback: return [URLQueryItem(name: "mobile", value: "true")]
        case .declineWalletTransaction: return []
        }
    }

    public var mockFile: String? {
        return nil
    }

    public var bundle: Bundle? {
        return nil
    }
}
