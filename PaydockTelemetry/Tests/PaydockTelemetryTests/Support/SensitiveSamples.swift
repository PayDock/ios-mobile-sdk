//
//  SensitiveSamples.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Synthetic sensitive values for the allowlist tests, and an event of every variant whose errors carry them in
/// their reason, description and user info. No real card, address or credential: the card number is built at run
/// time from a synthetic prefix, so no card-shaped literal sits in the source.
enum SensitiveSamples {
    static let cardNumber = luhnCompleted("400000000000123")
    static let groupedCardNumber = stride(from: 0, to: cardNumber.count, by: 4).map { start -> String in
        let lower = cardNumber.index(cardNumber.startIndex, offsetBy: start)
        return String(cardNumber[lower..<cardNumber.index(lower, offsetBy: 4)])
    }.joined(separator: " ")
    static let email = "jane.doe@example.com"
    static let message = "secret-message-text"
    static let jwt = ["eyJ" + "syntheticHeader", "syntheticPayload", "syntheticSignature"].joined(separator: ".")
    static let bearer = "Bearer " + "synthetic-token-value"
    static let longSecret = String(repeating: "a1B2", count: 10)
    /// A mangled Swift symbol: a run of more than 40 letters and digits.
    static let mangledSymbol = "$s9MobileSDK20CardDetailsViewModelC13tokeniseCardyyYaKF"

    /// The strings no encoded record may hold.
    static let forbiddenInOutput = [cardNumber, groupedCardNumber, email, message]

    static let sessionId = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
    static let builtAt: Int64 = 1_793_852_047_512

    private static let text = "\(message): card \(cardNumber), \(groupedCardNumber), contact \(email)"

    /// Raw `callStackSymbols` lines, one with a mangled Swift symbol.
    static let rawFrames = [
        "0   MobileSDK                           0x0000000104a3c1f0 \(mangledSymbol) + 340",
        "1   UIKitCore                           0x00000001a6f2d6a8 -[UIApplication sendAction:to:from:forEvent:] + 96",
        "2   libdyld.dylib                       0x00000001a5c1e8f0 ??? + 4"
    ]

    /// An `NSError` whose description, failure reason, user info and underlying error hold the sensitive text.
    static func error() -> NSError {
        let underlying = NSError(domain: "SampleUnderlyingDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: text])
        return NSError(domain: "SampleDomain", code: 7, userInfo: [
            NSLocalizedDescriptionKey: text,
            NSLocalizedFailureReasonErrorKey: text,
            "detail": text,
            NSUnderlyingErrorKey: underlying
        ])
    }

    /// An `NSException` whose reason and user info hold the sensitive text.
    static func exception() -> NSException {
        NSException(name: NSExceptionName("SampleInvalidArgumentException"), reason: text,
                    userInfo: ["detail": text, NSUnderlyingErrorKey: error()])
    }

    /// One event of every variant, errors built with `ErrorInfo.from`.
    static func events() -> [TelemetryEvent] {
        let fromError = TelemetryEvent.ErrorInfo.from(error(), frames: rawFrames)
        let fromException = TelemetryEvent.ErrorInfo.from(exception())
        let apiError = TelemetryEvent.APIError(status: 400, code: "invalid_transaction_details",
                                               summaryCode: "invalid_transaction_details",
                                               gatewayCodes: ["INVALID_REQUEST:INVALID:sourceOfFunds.provided.card.securityCode"])
        return [
            .crash(error: fromException, source: .nsException, kind: .exception, inSdk: true,
                   crashReason: fromException.type, threadName: "main"),
            .crash(error: fromError, source: .metricKit, kind: .signal, inSdk: false, crashReason: "SIGSEGV",
                   occurredAt: builtAt - 7_200_000),
            .crash(error: TelemetryEvent.ErrorInfo(type: nil, frames: rawFrames.map(StackFrame.sanitise)), source: .metricKit,
                   kind: .hang, inSdk: true),
            .uncaughtException(error: fromError, threadName: "main", widget: "ApplePayWidget"),
            .sdkError(error: fromError, errorCode: "CARD_TOKENISE_ERROR", widget: "CardDetailsWidget", apiError: apiError),
            .networkFailure(method: .post, urlTemplate: "/v1/payment_sources/tokens", serverAddress: "api-sandbox.paydock.com",
                            failure: .httpStatus(code: 400), apiError: apiError, widget: "CardDetailsWidget"),
            .networkFailure(method: .get, urlTemplate: "/v1/gateways/{id}/wallet-config", serverAddress: "api-sandbox.paydock.com",
                            failure: .transport(kind: .tls, error: fromError), attempt: 2),
            .networkFailure(method: .put, urlTemplate: "/", serverAddress: "api-sandbox.paydock.com",
                            failure: .decode(statusCode: 200, error: fromError), attempt: 3),
            .widgetOpened(widget: "CardDetailsWidget"),
            .dropped(reason: .storeFull, count: 7)
        ]
    }

    /// Each event built into a record of `sessionId`, sequences from 1.
    static func builtRecords() -> [TelemetryRecord] {
        events().enumerated().map { index, event in
            let pending = PendingRecord(id: "\(sessionId)-\(index + 1)", sessionId: sessionId, event: event,
                                        firstSeenAt: builtAt, occurrences: index % 3 + 1)
            return RecordFactory.create(pending, connection: .cell)
        }
    }

    /// A built record filtered and stamped, as I7 would send it.
    static func sendable(_ built: TelemetryRecord) -> TelemetryRecord {
        SendStamp.stamp(Allowlist.filter(built), sentAt: builtAt + 5_000, clockOffsetMilliseconds: -250)
    }

    /// The prefix followed by its Luhn check digit.
    static func luhnCompleted(_ prefix: String) -> String {
        let digits = prefix.compactMap(\.wholeNumberValue)
        var sum = 0
        for (position, digit) in digits.reversed().enumerated() {
            let weighted = position % 2 == 0 ? digit * 2 : digit
            sum += weighted > 9 ? weighted - 9 : weighted
        }
        return prefix + String((10 - sum % 10) % 10)
    }
}
