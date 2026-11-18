//
//  EndpointTemplateTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import DataCharges
@testable import DataGateways
@testable import DataPaymentSources
import NetworkingLib
import PaydockTelemetry

/// R_07: every `Endpoint` case the SDK calls, built with synthetic IDs, maps its `path` to its spec § 5.4 template, and
/// together they cover all eight. The example app's own `ChargesEndpoints` cases are listed and excluded.
final class EndpointTemplateTests: XCTestCase {

    /// Synthetic IDs, shaped like the API's, never real ones.
    private static let setupTokenId = "6a1b2c3d4e5f60718293a4b5"
    private static let chargeId = "7b2c3d4e5f60718293a4b5c6"
    private static let gatewayId = "8c3d4e5f60718293a4b5c6d7"
    private static let token = "synthetic-widget-token"

    // MARK: - Every SDK case maps to its template

    func testEverySdkEndpoint_MapsToItsTemplate() {
        for item in Self.sdkCases {
            XCTAssertEqual(RouteTemplates.template(item.endpoint.path), item.template, item.name)
        }
    }

    func testTheSdkEndpoints_CoverAllEightTemplates() {
        let templates = Set(Self.sdkCases.map { RouteTemplates.template($0.endpoint.path) })

        XCTAssertEqual(templates, Set(RouteTemplates.templates))
        XCTAssertEqual(RouteTemplates.templates.count, 8)
    }

    func testNoSdkTemplate_HoldsASyntheticId() {
        for item in Self.sdkCases {
            let template = RouteTemplates.template(item.endpoint.path)
            for id in [Self.setupTokenId, Self.chargeId, Self.gatewayId] {
                XCTAssertFalse(template.contains(id), item.name)
            }
        }
    }

    /// The SDK's `ChargesEndpoints` cases are exactly the three wallet ones; the rest belong to the example app.
    func testChargesEndpoints_TheAppOnlyCasesAreListedAndExcluded() {
        XCTAssertEqual(Self.appOnlyChargesCases, ["initialiseWalletCharge", "initialiseColesPayWalletCharge",
                                                  "captureCharge", "captureChargeForStandalone",
                                                  "captureChargeColesPay"])
        let sdkCharges = Self.sdkCases.compactMap { $0.endpoint as? ChargesEndpoints }
        XCTAssertEqual(sdkCharges.count, 4)
        XCTAssertTrue(sdkCharges.allSatisfy(Self.isSdkCase))
    }

    /// The app-only paths built here match none of the eight templates.
    func testTheAppOnlyChargesEndpoints_MatchNoTemplate() {
        let appOnly: [ChargesEndpoints] = [
            .captureCharge(request: CaptureChargeReq(amount: "1.00", currency: "AUD"), apiAccessToken: Self.token),
            .captureChargeColesPay(chargeId: Self.chargeId, apiAccessToken: Self.token)
        ]

        for endpoint in appOnly {
            XCTAssertFalse(Self.isSdkCase(endpoint))
            XCTAssertFalse(RouteTemplates.templates.contains(RouteTemplates.template(endpoint.path)), endpoint.path)
        }
    }

    // MARK: - Cases

    /// Every SDK endpoint case with its expected template. `walletCapture` appears with and without its query.
    private static var sdkCases: [SdkCase] {
        let tokens = "/v1/payment_sources/tokens"
        return [
            SdkCase("cardToken", PaymentSourcesEndpoints.cardToken(
                tokeniseCardDetailsReq: CreatePaymentSourceTokenReq(), widgetAccessToken: token), tokens),
            SdkCase("giftCardToken", PaymentSourcesEndpoints.giftCardToken(
                tokeniseGiftCardReq: CreateGiftCardTokenReq(cardNumber: "", cardPin: ""), widgetAccessToken: token), tokens),
            SdkCase("applePayToken", PaymentSourcesEndpoints.applePayToken(
                tokeniseApplePayReq: CreateApplePayTokenReq(serviceId: gatewayId, payload: ""), widgetAccessToken: token),
             tokens),
            SdkCase("zipToken", PaymentSourcesEndpoints.zipToken(
                request: CreatePaymentSourceTokenFromCheckoutReq(checkoutToken: "synthetic", gatewayId: gatewayId),
                widgetAccessToken: token), tokens),
            SdkCase("externalCheckout", PaymentSourcesEndpoints.externalCheckout(
                request: CreateExternalCheckoutReq(
                    gatewayId: gatewayId,
                    meta: ExternalCheckoutMeta(charge: ExternalCheckoutCharge(amount: 1, currency: "AUD")),
                    successRedirectUrl: "", errorRedirectUrl: "", redirectUrl: ""),
                widgetAccessToken: token), "/v1/payment_sources/external_checkout"),
            SdkCase("setupToken", PaymentSourcesEndpoints.setupToken(
                request: CreatePayPalVaultSetupTokenReq(gatewayId: gatewayId), widgetAccessToken: token),
             "/v1/payment_sources/setup-tokens"),
            SdkCase("paymentToken", PaymentSourcesEndpoints.paymentToken(
                setupToken: setupTokenId, request: CreatePayPalVaultPaymentTokenReq(gatewayId: gatewayId),
                widgetAccessToken: token), "/v1/payment_sources/setup-tokens/{id}/tokens"),
            SdkCase("walletCapture capture", ChargesEndpoints.walletCapture(
                capture: true, walletCaptureReq: CaptureWalletChargeReq(), widgetAccessToken: token),
             "/v1/charges/wallet/capture"),
            SdkCase("walletCapture", ChargesEndpoints.walletCapture(
                capture: false, walletCaptureReq: CaptureWalletChargeReq(), widgetAccessToken: token),
             "/v1/charges/wallet/capture"),
            SdkCase("declineWalletTransaction", ChargesEndpoints.declineWalletTransaction(
                chargeId: chargeId, widgetAccessToken: token), "/v1/charges/wallet/{id}/decline"),
            SdkCase("walletCallback", ChargesEndpoints.walletCallback(
                walletCallbackReq: WalletCallbackReq(requestType: "synthetic"), widgetAccessToken: token),
             "/v1/charges/wallet/callback"),
            SdkCase("clientId", GatewayEndpoints.clientId(gatewayId: gatewayId, widgetAccessToken: token),
             "/v1/gateways/{id}/wallet-config")
        ]
    }

    private struct SdkCase {
        let name: String
        let endpoint: any Endpoint
        let template: String

        init(_ name: String, _ endpoint: any Endpoint, _ template: String) {
            self.name = name
            self.endpoint = endpoint
            self.template = template
        }
    }

    /// The example app's `ChargesEndpoints` cases (`apiAccessToken`), which the SDK never calls.
    private static let appOnlyChargesCases = ["initialiseWalletCharge", "initialiseColesPayWalletCharge", "captureCharge",
                                              "captureChargeForStandalone", "captureChargeColesPay"]

    /// Every case of `PaymentSourcesEndpoints` and `GatewayEndpoints` is built above: each name below is an exhaustive
    /// switch's, so a new case fails to compile until it is added.
    func testEveryPaymentSourcesAndGatewayCase_IsBuilt() {
        let built = Set(Self.sdkCases.compactMap { item -> String? in
            if let endpoint = item.endpoint as? PaymentSourcesEndpoints { return Self.caseName(endpoint) }
            if let endpoint = item.endpoint as? GatewayEndpoints { return Self.caseName(endpoint) }
            return nil
        })

        XCTAssertEqual(built, ["cardToken", "giftCardToken", "applePayToken", "zipToken", "externalCheckout",
                               "setupToken", "paymentToken", "clientId"])
    }

    private static func caseName(_ endpoint: PaymentSourcesEndpoints) -> String {
        switch endpoint {
        case .cardToken: return "cardToken"
        case .giftCardToken: return "giftCardToken"
        case .applePayToken: return "applePayToken"
        case .zipToken: return "zipToken"
        case .externalCheckout: return "externalCheckout"
        case .setupToken: return "setupToken"
        case .paymentToken: return "paymentToken"
        }
    }

    private static func caseName(_ endpoint: GatewayEndpoints) -> String {
        switch endpoint {
        case .clientId: return "clientId"
        }
    }

    /// Exhaustive, so a new `ChargesEndpoints` case fails to compile until it is placed on one side.
    private static func isSdkCase(_ endpoint: ChargesEndpoints) -> Bool {
        switch endpoint {
        case .walletCapture, .walletCallback, .declineWalletTransaction:
            return true
        case .initialiseWalletCharge, .initialiseColesPayWalletCharge, .captureCharge, .captureChargeForStandalone,
             .captureChargeColesPay:
            return false
        }
    }
}
