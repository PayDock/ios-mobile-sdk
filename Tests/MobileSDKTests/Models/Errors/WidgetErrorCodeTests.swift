//
//  WidgetErrorCodeTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import NetworkingLib
@testable import MobileSDK

/// Locks the stable, machine-readable `code` values integrators log/alert on. These strings are an
/// API contract — changing one is a breaking change for downstream logging/alerting and must be
/// deliberate.
final class WidgetErrorCodeTests: XCTestCase {

    private func makeErrorRes() -> ErrorRes {
        ErrorRes(status: 400,
                 error: .init(message: "boom", code: "E123", details: nil),
                 resource: nil,
                 errorSummary: nil)
    }

    // MARK: - RequestError.diagnosticCode (the shared engine)

    func testRequestErrorDiagnosticCodes() {
        XCTAssertEqual(RequestError.decode(nil).diagnosticCode, "RESPONSE_DECODE")
        XCTAssertEqual(RequestError.unexpectedErrorModel.diagnosticCode, "UNEXPECTED_RESPONSE_MODEL")
        XCTAssertEqual(RequestError.noResponse.diagnosticCode, "NO_RESPONSE")
        XCTAssertEqual(RequestError.invalidURL.diagnosticCode, "INVALID_URL")
        XCTAssertEqual(RequestError.connectionError(URLError(.timedOut)).diagnosticCode, "NETWORK")
        XCTAssertEqual(RequestError.serverError(URLError(.badServerResponse)).diagnosticCode, "NETWORK")
        XCTAssertEqual(RequestError.unknown(URLError(.unknown)).diagnosticCode, "NETWORK")
        XCTAssertEqual(RequestError.requestError(makeErrorRes()).diagnosticCode, "SERVER_ERROR")
    }

    // MARK: - unknownError delegation (per widget prefix + RequestError suffix)

    func testUnknownErrorDelegatesToRequestErrorDiagnosticCode() {
        XCTAssertEqual(ApplePayError.unknownError(.decode(nil)).code, "APPLE_PAY_RESPONSE_DECODE")
        XCTAssertEqual(ApplePayError.unknownError(.noResponse).code, "APPLE_PAY_NO_RESPONSE")
        XCTAssertEqual(ApplePayError.unknownError(nil).code, "APPLE_PAY_UNKNOWN")

        XCTAssertEqual(PayPalError.unknownError(.decode(nil)).code, "PAYPAL_RESPONSE_DECODE")
        XCTAssertEqual(AfterpayError.unknownError(.decode(nil)).code, "AFTERPAY_RESPONSE_DECODE")
        XCTAssertEqual(ZipError.unknownError(.decode(nil)).code, "ZIP_RESPONSE_DECODE")
        XCTAssertEqual(ColesPayError.unknownError(.decode(nil)).code, "COLES_PAY_RESPONSE_DECODE")
        XCTAssertEqual(GiftCardError.unknownError(.decode(nil)).code, "GIFT_CARD_RESPONSE_DECODE")
        XCTAssertEqual(CardDetailsError.unknownError(.decode(nil)).code, "CARD_RESPONSE_DECODE")
        XCTAssertEqual(PayPalVaultError.unknownError(.decode(nil)).code, "PAYPAL_VAULT_RESPONSE_DECODE")
        XCTAssertEqual(PayPalDataCollectorError.unknownError(.decode(nil)).code, "PAYPAL_DATA_COLLECTOR_RESPONSE_DECODE")
    }

    // MARK: - One representative code per widget enum

    func testRepresentativeCodesPerWidget() {
        XCTAssertEqual(ApplePayError.payloadEncodingFailed.code, "APPLE_PAY_PAYLOAD_ENCODING_FAILED")
        XCTAssertEqual(AfterpayError.errorCapturingCharge(error: makeErrorRes()).code, "AFTERPAY_CAPTURE_CHARGE_ERROR")
        XCTAssertEqual(CardDetailsError.errorTokenisingCard(error: makeErrorRes()).code, "CARD_TOKENISE_ERROR")
        XCTAssertEqual(ColesPayError.colesPayUrlError.code, "COLES_PAY_URL_ERROR")
        XCTAssertEqual(GiftCardError.errorTokenisingCard(error: makeErrorRes()).code, "GIFT_CARD_TOKENISE_ERROR")
        XCTAssertEqual(PayPalError.sdkException(description: "x").code, "PAYPAL_SDK_EXCEPTION")
        XCTAssertEqual(PayPalVaultError.createSetupToken(error: makeErrorRes()).code, "PAYPAL_VAULT_SETUP_TOKEN_ERROR")
        XCTAssertEqual(ZipError.transactionDeclined(checkoutId: "c1").code, "ZIP_TRANSACTION_DECLINED")
        XCTAssertEqual(ClickToPayError.unknownError.code, "CLICK_TO_PAY_UNKNOWN")
        XCTAssertEqual(MPGS3dsError.mappingFailed.code, "MPGS_3DS_RESPONSE_MAPPING_FAILED")
        XCTAssertEqual(Standalone3DSError.mappingFailed.code, "STANDALONE_3DS_RESPONSE_MAPPING_FAILED")
        XCTAssertEqual(WalletTokenError.initialisingWalletToken(reason: nil).code, "WALLET_TOKEN_INIT_ERROR")
        XCTAssertEqual(PayPalDataCollectorError.parsingError.code, "PAYPAL_DATA_COLLECTOR_PARSING_ERROR")
    }

    // MARK: - debugDescription embeds the code + underlying detail

    func testDebugDescriptionEmbedsCodeAndUnderlyingCause() {
        let decodeErr = ApplePayError.unknownError(.decode(nil))
        XCTAssertTrue(decodeErr.debugDescription.contains("APPLE_PAY_RESPONSE_DECODE"))
        XCTAssertTrue(decodeErr.debugDescription.contains("RequestError.decode"))

        let apiErr = CardDetailsError.errorTokenisingCard(error: makeErrorRes())
        XCTAssertTrue(apiErr.debugDescription.contains("CARD_TOKENISE_ERROR"))
        XCTAssertTrue(apiErr.debugDescription.contains("status: 400"))
        XCTAssertTrue(apiErr.debugDescription.contains("code: E123"))

        // CustomDebugStringConvertible: String(reflecting:) yields debugDescription.
        XCTAssertEqual(String(reflecting: decodeErr), decodeErr.debugDescription)
    }

    /// End-to-end: a decode failure carrying a `DecodingFailureContext` surfaces the offending field
    /// in the widget error's `debugDescription`, so integrators can log/report exactly what failed.
    func testDecodeContextFieldDetailSurfacesInDebugDescription() {
        let context = DecodingFailureContext(kind: .keyNotFound,
                                             codingPath: "resource.data.tempToken",
                                             summary: "keyNotFound 'tempToken' at resource.data",
                                             debugDescription: "No value associated with key tempToken")
        let error = ApplePayError.unknownError(.decode(context))

        XCTAssertEqual(error.code, "APPLE_PAY_RESPONSE_DECODE")
        XCTAssertTrue(error.debugDescription.contains("keyNotFound 'tempToken' at resource.data"),
                      "expected the failing field to surface, got: \(error.debugDescription)")
    }

    // MARK: - customMessage is unchanged (regression guard)

    func testCustomMessageUnchangedForRepresentativeCases() {
        XCTAssertEqual(ApplePayError.notSupported.customMessage, "Apple Pay is not supported")
        XCTAssertEqual(ApplePayError.unknownError(nil).customMessage, "Unknown error")
        XCTAssertEqual(MPGS3dsError.mappingFailed.customMessage, "3DS response mapping failed")
    }
}
