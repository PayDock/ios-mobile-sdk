//
//  SdkErrorFactsTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
@testable import NetworkingLib
import PaydockTelemetry

final class SdkErrorFactsTests: XCTestCase {

    private static let requestError = RequestError.connectionError(URLError(.notConnectedToInternet))
    private static let nsError = NSError(domain: "SampleDomain", code: 7)
    private static let errorRes = ErrorRes(status: 400, error: .init(message: "Declined", code: "declined", details: nil),
                                           resource: nil, errorSummary: nil)

    /// One expected row per case of each of the twelve types: its cause's type, request-caused, outcome.
    private struct Facts {
        let error: any TelemetryErrorFacts
        let causeType: String?
        let isRequestCaused: Bool
        let isOutcome: Bool
        let line: UInt

        init(_ error: any TelemetryErrorFacts, cause causeType: String? = nil, request isRequestCaused: Bool = false,
             outcome isOutcome: Bool = false, line: UInt = #line) {
            self.error = error
            self.causeType = causeType
            self.isRequestCaused = isRequestCaused
            self.isOutcome = isOutcome
            self.line = line
        }
    }

    private static let requestType = "NetworkingLib.RequestError.connectionError"
    private static let nsErrorType = "NSError SampleDomain 7"

    // MARK: - Each error type's facts

    func testEachErrorType_EveryCase_GivesItsFacts() {
        let rows = Self.cardAndGiftCardRows + Self.walletRows + Self.payPalRows + Self.webViewRows + Self.zipRows
        for row in rows {
            let name = String(describing: row.error)
            XCTAssertEqual(row.error.telemetryCause.map(SdkErrorFacts.typeName(of:)), row.causeType, name, line: row.line)
            XCTAssertEqual(row.error.isRequestCaused, row.isRequestCaused, name, line: row.line)
            XCTAssertEqual(row.error.isOutcome, row.isOutcome, name, line: row.line)
            XCTAssertEqual(row.error.telemetryCode, (row.error as? any WidgetError)?.code, name, line: row.line)
        }
    }

    func testUnknownErrorWithoutARequestError_IsNeitherRequestCausedNorCaused() {
        let errors: [any TelemetryErrorFacts] = [
            CardDetailsError.unknownError(nil), GiftCardError.unknownError(nil), AfterpayError.unknownError(nil),
            ApplePayError.unknownError(nil), ColesPayError.unknownError(nil), PayPalError.unknownError(nil),
            PayPalVaultError.unknownError(nil), ZipError.unknownError(nil), PayPalDataCollectorError.unknownError(nil)
        ]
        for error in errors {
            XCTAssertNil(error.telemetryCause, String(describing: error))
            XCTAssertFalse(error.isRequestCaused, String(describing: error))
            XCTAssertFalse(error.isOutcome, String(describing: error))
        }
    }

    func testSilentFailure_EveryCase_GivesItsCodeAndCause() {
        let cause = Self.nsError
        let rows: [SilentRow] = [
            SilentRow(.cardExpiryUnreadable, "CARD_EXPIRY_UNREADABLE", nil),
            SilentRow(.afterpayConfigurationFailed, "AFTERPAY_CONFIGURATION_FAILED", nil),
            SilentRow(.afterpayNoPresenter, "AFTERPAY_NO_PRESENTER", nil),
            SilentRow(.afterpayCancelWithoutChargeId, "AFTERPAY_CANCEL_WITHOUT_CHARGE_ID", nil),
            SilentRow(.colesPayMessageUnreadable, "COLES_PAY_MESSAGE_UNREADABLE", nil),
            SilentRow(.clickToPayMessageUnreadable, "CLICK_TO_PAY_MESSAGE_UNREADABLE", nil),
            SilentRow(.clickToPayTokenMissing, "CLICK_TO_PAY_TOKEN_MISSING", nil),
            SilentRow(.clickToPayCheckoutError, "CLICK_TO_PAY_CHECKOUT_ERROR", nil),
            SilentRow(.clickToPayMetaEncodingFailed(cause), "CLICK_TO_PAY_META_ENCODING_FAILED", Self.nsErrorType),
            SilentRow(.addressSearchFailed(cause), "ADDRESS_SEARCH_FAILED", Self.nsErrorType),
            SilentRow(.addressReverseGeocodeFailed(cause), "ADDRESS_REVERSE_GEOCODE_FAILED", Self.nsErrorType),
            SilentRow(.addressCompleterFailed(cause), "ADDRESS_COMPLETER_FAILED", Self.nsErrorType)
        ]
        for (failure, code, causeType) in rows.map({ ($0.failure, $0.code, $0.causeType) }) {
            XCTAssertEqual(failure.telemetryCode, code)
            XCTAssertEqual(SdkErrorFacts.code(failure), code)
            XCTAssertEqual(failure.telemetryCause.map(SdkErrorFacts.typeName(of:)), causeType, code)
            XCTAssertFalse(failure.isRequestCaused, code)
            XCTAssertFalse(failure.isOutcome, code)
            XCTAssertFalse(SdkErrorFacts.isRequestCaused(failure), code)
        }
    }

    // MARK: - Type names

    func testTypeName_ARequestError_IsItsCase() {
        let rows: [(RequestError, String)] = [
            (.connectionError(URLError(.timedOut)), "connectionError"),
            (.decode(nil), "decode"),
            (.invalidRequest(URLError(.badURL)), "invalidRequest"),
            (.invalidURL, "invalidURL"),
            (.noResponse, "noResponse"),
            (.serverError(URLError(.badServerResponse)), "serverError"),
            (.unexpectedErrorModel, "unexpectedErrorModel"),
            (.requestError(Self.errorRes), "requestError"),
            (.unknown(URLError(.unknown)), "unknown")
        ]
        for (error, name) in rows {
            XCTAssertEqual(SdkErrorFacts.typeName(of: error), "NetworkingLib.RequestError.\(name)")
        }
    }

    func testTypeName_AnNSError_IsItsDomainAndCode() {
        XCTAssertEqual(SdkErrorFacts.typeName(of: Self.nsError), Self.nsErrorType)
        XCTAssertEqual(SdkErrorFacts.typeName(of: SampleNSErrorSubclass(domain: "SubDomain", code: 4)), "NSError SubDomain 4")
    }

    func testTypeName_AURLError_IsItsDomainAndCode() {
        XCTAssertEqual(SdkErrorFacts.typeName(of: URLError(.timedOut)), "NSError NSURLErrorDomain -1001")
    }

    func testTypeName_ASwiftType_IsItsQualifiedName() {
        XCTAssertEqual(SdkErrorFacts.typeName(of: CardDetailsError.unknownError(nil)), "MobileSDK.CardDetailsError")
        XCTAssertEqual(SdkErrorFacts.typeName(of: SilentFailure.cardExpiryUnreadable), "MobileSDK.SilentFailure")
        XCTAssertEqual(SdkErrorFacts.typeName(of: SampleSwiftError()), "MobileSDKTests.SampleSwiftError")
    }

    // MARK: - Code and the request rule

    func testCode_FactsWidgetAndOtherErrors() {
        XCTAssertEqual(SdkErrorFacts.code(ZipError.invalidCheckoutUrl), "ZIP_INVALID_CHECKOUT_URL")
        XCTAssertEqual(SdkErrorFacts.code(WalletTokenError.initialisingWalletToken(reason: nil)), "WALLET_TOKEN_INIT_ERROR")
        XCTAssertNil(SdkErrorFacts.code(Self.nsError))
        XCTAssertNil(SdkErrorFacts.code(SampleSwiftError()))
    }

    func testIsRequestCaused_ARequestErrorAndAFactsErrorWrappingOne() {
        XCTAssertTrue(SdkErrorFacts.isRequestCaused(RequestError.noResponse))
        XCTAssertTrue(SdkErrorFacts.isRequestCaused(CardDetailsError.unknownError(.noResponse)))
        XCTAssertTrue(SdkErrorFacts.isRequestCaused(CardDetailsError.errorTokenisingCard(error: Self.errorRes)))
        XCTAssertFalse(SdkErrorFacts.isRequestCaused(CardDetailsError.unknownError(nil)))
        XCTAssertFalse(SdkErrorFacts.isRequestCaused(Self.nsError))
        XCTAssertFalse(SdkErrorFacts.isRequestCaused(URLError(.timedOut)))
    }

    // MARK: - The cause chain

    func testErrorInfo_HasNoFrames_AndFollowsAWrappedRequestErrorToItsURLError_ThenTheUnderlyingError() {
        let inner = NSError(domain: "InnerDomain", code: 3)
        let urlError = URLError(.notConnectedToInternet, userInfo: [NSUnderlyingErrorKey: inner])
        let info = SdkErrorFacts.errorInfo(CardDetailsError.unknownError(.connectionError(urlError)))

        XCTAssertEqual(info.type, "MobileSDK.CardDetailsError")
        XCTAssertEqual(info.frames, [])
        XCTAssertEqual(info.causeTypes, [
            "NetworkingLib.RequestError.connectionError",
            "NSError NSURLErrorDomain -1009",
            "NSError InnerDomain 3"
        ])
        XCTAssertEqual(info.cause?.frames, [])
    }

    func testErrorInfo_ARequestErrorWithoutAURLError_HasNoCause() {
        XCTAssertNil(SdkErrorFacts.errorInfo(RequestError.noResponse).cause)
    }

    func testErrorInfo_AtMostEightCauses() {
        var error = NSError(domain: "Level", code: 0)
        for level in 1...12 {
            error = NSError(domain: "Level", code: level, userInfo: [NSUnderlyingErrorKey: error])
        }

        XCTAssertEqual(SdkErrorFacts.errorInfo(error).causeTypes.count, TelemetryEvent.ErrorInfo.maxCauses)
    }

    func testErrorInfo_ALoopingCause_Ends() {
        let info = SdkErrorFacts.errorInfo(LoopingError())

        XCTAssertEqual(info.causeTypes, Array(repeating: "MobileSDKTests.LoopingError", count: TelemetryEvent.ErrorInfo.maxCauses))
    }

    // MARK: - No message text

    /// A wallet-token reason, a PayPal SDK description, an `NSError` localized description and an error body message,
    /// each holding card-like and email-like text, appear in no field of the event or of its record.
    func testNoMessageText_InTheEventOrTheRecord() {
        let text = TelemetrySensitiveText.text
        let nsError = NSError(domain: "SampleDomain", code: 7, userInfo: [
            NSLocalizedDescriptionKey: text,
            NSLocalizedFailureReasonErrorKey: text,
            NSUnderlyingErrorKey: NSError(domain: "InnerDomain", code: 3, userInfo: [NSLocalizedDescriptionKey: text])
        ])
        let body = ErrorRes(status: 400, error: .init(message: text, code: "declined", details: nil), resource: nil,
                            errorSummary: nil)
        let errors: [any Error] = [
            WalletTokenError.initialisingWalletToken(reason: text),
            AfterpayError.initialisingWalletToken(reason: text),
            ZipError.initialisingWalletToken(reason: text),
            PayPalError.sdkException(description: text),
            PayPalVaultError.sdkException(description: text),
            nsError,
            ClickToPayError.webViewFailed(error: nsError),
            SilentFailure.addressSearchFailed(nsError),
            CardDetailsError.errorTokenisingCard(error: body),
            CardDetailsError.unknownError(.requestError(body))
        ]

        for error in errors {
            let event = TelemetryEvent.sdkError(error: SdkErrorFacts.errorInfo(error), errorCode: SdkErrorFacts.code(error),
                                                widget: SdkWidget.cardDetails.rawValue)
            let record = RecordFactory.create(PendingRecord(id: "s-1", sessionId: "s", event: event, createdAt: 0),
                                              connection: .wifi)
            for output in [String(describing: event), String(describing: record)] {
                for forbidden in TelemetrySensitiveText.forbidden {
                    XCTAssertFalse(output.contains(forbidden), "\(SdkErrorFacts.typeName(of: error)) leaks message text")
                }
            }
        }
    }

    // MARK: - Rows

    private static let cardAndGiftCardRows: [Facts] = [
        Facts(CardDetailsError.errorTokenisingCard(error: errorRes), request: true),
        Facts(CardDetailsError.unknownError(requestError), cause: requestType, request: true),
        Facts(GiftCardError.errorTokenisingCard(error: errorRes), request: true),
        Facts(GiftCardError.unknownError(requestError), cause: requestType, request: true),
        Facts(PayPalDataCollectorError.initialisationClientId(error: errorRes), request: true),
        Facts(PayPalDataCollectorError.parsingError),
        Facts(PayPalDataCollectorError.unknownError(requestError), cause: requestType, request: true)
    ]

    private static let walletRows: [Facts] = [
        Facts(AfterpayError.errorFetchingAfterpayUrl(error: errorRes), request: true),
        Facts(AfterpayError.errorCapturingCharge(error: errorRes), request: true),
        Facts(AfterpayError.errorCancelingTransaction(error: errorRes), request: true),
        Facts(AfterpayError.transactionCanceled, outcome: true),
        Facts(AfterpayError.initialisingWalletToken(reason: "r")),
        Facts(AfterpayError.unknownError(requestError), cause: requestType, request: true),
        Facts(ApplePayError.notSupported),
        Facts(ApplePayError.noSupportedCardsInWallet),
        Facts(ApplePayError.errorCreatingToken(error: errorRes), request: true),
        Facts(ApplePayError.userCanceledPayment, outcome: true),
        Facts(ApplePayError.unableToPresentPaymentSheet),
        Facts(ApplePayError.payloadEncodingFailed),
        Facts(ApplePayError.unknownError(requestError), cause: requestType, request: true),
        Facts(ColesPayError.errorFetchingColesPayOrder(error: errorRes), request: true),
        Facts(ColesPayError.colesPayUrlError),
        Facts(ColesPayError.webViewFailed(error: nsError), cause: nsErrorType),
        Facts(ColesPayError.transactionCanceled, outcome: true),
        Facts(ColesPayError.initialisingWalletToken(reason: "r")),
        Facts(ColesPayError.unknownError(requestError), cause: requestType, request: true)
    ]

    private static let payPalRows: [Facts] = [
        Facts(PayPalError.getPayPalClientId(error: errorRes), request: true),
        Facts(PayPalError.errorFetchingOrderId(error: errorRes), request: true),
        Facts(PayPalError.errorCapturingCharge(error: errorRes), request: true),
        Facts(PayPalError.userCancelled, outcome: true),
        Facts(PayPalError.initialisingWalletToken(reason: "r")),
        Facts(PayPalError.sdkException(description: "d")),
        Facts(PayPalError.unknownError(requestError), cause: requestType, request: true),
        Facts(PayPalVaultError.createSetupToken(error: errorRes), request: true),
        Facts(PayPalVaultError.getPayPalClientId(error: errorRes), request: true),
        Facts(PayPalVaultError.createPaymentToken(error: errorRes), request: true),
        Facts(PayPalVaultError.sdkException(description: "d")),
        Facts(PayPalVaultError.userCancelled, outcome: true),
        Facts(PayPalVaultError.unknownError(requestError), cause: requestType, request: true)
    ]

    private static let webViewRows: [Facts] = [
        Facts(ClickToPayError.webViewFailed(error: nsError), cause: nsErrorType),
        Facts(ClickToPayError.unknownError),
        Facts(MPGS3dsError.webViewFailed(error: nsError), cause: nsErrorType),
        Facts(MPGS3dsError.invalidToken),
        Facts(MPGS3dsError.mappingFailed),
        Facts(Standalone3DSError.webViewFailed(error: nsError), cause: nsErrorType),
        Facts(Standalone3DSError.invalidToken),
        Facts(Standalone3DSError.mappingFailed)
    ]

    private static let zipRows: [Facts] = [
        Facts(ZipError.errorFetchingZipUrl(error: errorRes), request: true),
        Facts(ZipError.errorCapturingCharge(error: errorRes), request: true),
        Facts(ZipError.invalidCheckoutUrl),
        Facts(ZipError.webViewFailed(error: nsError), cause: nsErrorType),
        Facts(ZipError.transactionCanceled(checkoutId: nil), outcome: true),
        Facts(ZipError.transactionDeclined(checkoutId: nil), outcome: true),
        Facts(ZipError.transactionReferred(checkoutId: nil), outcome: true),
        Facts(ZipError.unexpectedStatus(status: nil, checkoutId: nil)),
        Facts(ZipError.initialisingWalletToken(reason: "r")),
        Facts(ZipError.unknownError(requestError), cause: requestType, request: true)
    ]
}

struct SampleSwiftError: Error {}

private struct SilentRow {
    let failure: SilentFailure
    let code: String
    let causeType: String?

    init(_ failure: SilentFailure, _ code: String, _ causeType: String?) {
        self.failure = failure
        self.code = code
        self.causeType = causeType
    }
}

private final class SampleNSErrorSubclass: NSError, @unchecked Sendable {}

/// A facts error that is its own cause.
struct LoopingError: TelemetryErrorFacts {
    var telemetryCode: String? { nil }
    var telemetryCause: (any Error)? { self }
    var isRequestCaused: Bool { false }
    var isOutcome: Bool { false }
}
