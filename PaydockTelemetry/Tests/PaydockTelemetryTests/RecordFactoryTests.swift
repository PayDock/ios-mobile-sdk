//
//  RecordFactoryTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class RecordFactoryTests: XCTestCase {

    private static let sessionId = "3f2a1c9e-8b7d-4e6f-a5c4-1b2d3e4f5a6b"
    private static let builtAt: Int64 = 1_793_052_603_000
    private static let frame = "MobileSDK $s9MobileSDK3fooyyF + 340"
    private static let paymentId = "9b2e4f61-7c3a-4d58-a1e9-3f0d6b8c2a17"

    // MARK: - Severity

    func testSeverities() {
        let info = TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: [])
        let cases: [(TelemetryEvent, Severity)] = [
            (crash(kind: .exception), .fatal), (crash(kind: .signal), .fatal), (crash(kind: .osKill), .fatal),
            (crash(kind: .hang), .error),
            (.sdkError(error: info), .error), (.uncaughtException(error: info), .error),
            (network(.httpStatus(code: 503)), .error),
            (.widgetOpened(widget: "CardDetailsWidget"), .info), (.dropped(reason: .tooOld, count: 3), .warn),
            (.paymentStarted(widget: "PayPalWidget", paymentId: Self.paymentId), .info),
            (.paymentFinished(widget: "PayPalWidget", paymentId: Self.paymentId, outcome: .error, errorCode: "PAYPAL_UNKNOWN",
                              durationMs: 10), .info)
        ]
        for (event, severity) in cases {
            XCTAssertEqual(record(event).severity, severity, "\(event)")
        }
        XCTAssertEqual(record(crash(kind: .hang)).severity.text, "ERROR")
        XCTAssertEqual([Severity.info, .warn, .error, .fatal].map(\.text), ["INFO", "WARN", "ERROR", "FATAL"])
        XCTAssertEqual([Severity.info, .warn, .error, .fatal].map(\.rawValue), [9, 13, 17, 21])
    }

    // MARK: - Common fields

    func testCommonFields_AndNoOccurrences() {
        let once = record(.widgetOpened(widget: "CardDetailsWidget"))
        XCTAssertEqual(once.id, "\(Self.sessionId)-1")
        XCTAssertEqual(once.value("session.id"), .string(Self.sessionId))
        XCTAssertEqual(once.value("log.record.uid"), .string("\(Self.sessionId)-1"))
        XCTAssertEqual(once.value("network.connection.type"), .string("wifi"))
        XCTAssertNil(once.value("paydock.occurrences"), "the duplicate gate writes paydock.occurrences, never the factory")
        XCTAssertEqual(once.timeUnixMillis, Self.builtAt)
    }

    // MARK: - Crash

    func testCrash_FieldsInKeyOrder_BodyAndOwnTime() {
        let cause = TelemetryEvent.ErrorInfo(type: "NSError", frames: [])
        let error = TelemetryEvent.ErrorInfo(type: "NSInvalidArgumentException", frames: [Self.frame], cause: cause)
        let event = TelemetryEvent.crash(error: error, source: .nsException, kind: .exception, inSdk: true,
                                         crashReason: "NSInvalidArgumentException", threadName: "main", occurredAt: 1_000)

        let result = record(event)

        XCTAssertEqual(result.attributes.map(\.key), [
            "event.name", "session.id", "log.record.uid", "network.connection.type", "exception.type", "exception.stacktrace",
            "paydock.exception.cause_types", "paydock.exception.in_sdk", "paydock.crash.kind", "paydock.crash.source",
            "paydock.crash.reason", "thread.name"
        ])
        XCTAssertEqual(result.eventName, "paydock.crash")
        XCTAssertEqual(result.value("exception.stacktrace"), .string("NSInvalidArgumentException\n\tat \(Self.frame)\nCaused by: NSError"))
        XCTAssertEqual(result.value("paydock.exception.cause_types"), .string("NSError"))
        XCTAssertEqual(result.value("paydock.exception.in_sdk"), .bool(true))
        XCTAssertEqual(result.value("paydock.crash.kind"), .string("exception"))
        XCTAssertEqual(result.value("paydock.crash.source"), .string("nsexception"))
        XCTAssertEqual(result.body, "paydock.crash · exception · NSInvalidArgumentException")
        XCTAssertEqual(result.timeUnixMillis, 1_000)
    }

    func testCrash_WithoutItsOwnTime_UsesTheBuildTime() {
        XCTAssertEqual(record(crash(kind: .signal)).timeUnixMillis, Self.builtAt)
    }

    func testCrash_WithoutError_HasNoExceptionTypeOrStack_ButKeepsInSdk() {
        let result = record(.crash(error: nil, source: .metricKit, kind: .osKill, inSdk: false))

        XCTAssertNil(result.value("exception.type"))
        XCTAssertNil(result.value("exception.stacktrace"))
        XCTAssertEqual(result.value("paydock.exception.in_sdk"), .bool(false))
        XCTAssertEqual(result.value("paydock.crash.source"), .string("metrickit"))
        XCTAssertEqual(result.value("paydock.crash.kind"), .string("os_kill"))
    }

    func testCrash_WithInSdkNil_HasNoInSdk() {
        let error = TelemetryEvent.ErrorInfo(type: "NSInvalidArgumentException", frames: ["ExampleApp 0x1b5058"])

        let result = record(.crash(error: error, source: .nsException, kind: .exception, inSdk: nil,
                                   crashReason: "NSInvalidArgumentException"))

        XCTAssertNil(result.value("paydock.exception.in_sdk"))
        XCTAssertFalse(result.attributes.map(\.key).contains("paydock.exception.in_sdk"))
        XCTAssertEqual(result.value("exception.type"), .string("NSInvalidArgumentException"))
        XCTAssertEqual(result.value("paydock.crash.kind"), .string("exception"))
    }

    func testCrash_WritesInSdkTrueAndFalse() {
        for inSdk in [true, false] {
            let result = record(.crash(error: nil, source: .metricKit, kind: .signal, inSdk: inSdk, crashReason: "SIGSEGV"))

            XCTAssertEqual(result.value("paydock.exception.in_sdk"), .bool(inSdk))
        }
    }

    func testHangWithoutType_HasNoExceptionType_ButAStack() {
        let error = TelemetryEvent.ErrorInfo(type: nil, frames: ["MobileSDK 0x0000000104a3c1f0"])

        let result = record(.crash(error: error, source: .metricKit, kind: .hang, inSdk: true))

        XCTAssertNil(result.value("exception.type"))
        XCTAssertEqual(result.value("exception.stacktrace"), .string("\tat MobileSDK 0x0000000104a3c1f0"))
        XCTAssertEqual(result.body, "paydock.crash · hang")
    }

    func testEmptyStrings_AreLeftOut() {
        let error = TelemetryEvent.ErrorInfo(type: "", frames: [])
        let crashRecord = record(.crash(error: error, source: .nsException, kind: .exception, inSdk: true, crashReason: "",
                                        threadName: ""))
        for key in ["exception.type", "exception.stacktrace", "paydock.exception.cause_types", "paydock.crash.reason", "thread.name"] {
            XCTAssertNil(crashRecord.value(key), key)
        }

        let errorRecord = record(.sdkError(error: TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: []), errorCode: "",
                                           widget: "", apiError: TelemetryEvent.APIError(code: "", summaryCode: "")))
        for key in ["paydock.error.code", "paydock.widget", "paydock.api.error.code", "paydock.api.error.summary_code",
                    "paydock.api.gateway.codes", "paydock.api.status"] {
            XCTAssertNil(errorRecord.value(key), key)
        }
    }

    // MARK: - Errors

    func testSdkError_WithAnAPIError_GetsTheFourAPIFieldsInKeyOrder() {
        let apiError = TelemetryEvent.APIError(status: 400, code: "invalid_card", summaryCode: "card_error", gatewayCodes: ["05", "14"])
        let event = TelemetryEvent.sdkError(error: TelemetryEvent.ErrorInfo(type: "MobileSDK.CardError", frames: [Self.frame]),
                                            errorCode: "CARD_INVALID", widget: "CardDetailsWidget", apiError: apiError)

        let result = record(event)

        XCTAssertEqual(result.attributes.map(\.key), [
            "event.name", "session.id", "log.record.uid", "network.connection.type", "paydock.widget", "exception.type",
            "exception.stacktrace", "paydock.exception.in_sdk", "paydock.error.kind", "paydock.error.code", "paydock.api.status",
            "paydock.api.error.code", "paydock.api.error.summary_code", "paydock.api.gateway.codes"
        ])
        XCTAssertEqual(result.value("paydock.error.kind"), .string("sdk_error"))
        XCTAssertEqual(result.value("paydock.exception.in_sdk"), .bool(true))
        XCTAssertEqual(result.value("paydock.api.status"), .int(400))
        XCTAssertEqual(result.value("paydock.api.gateway.codes"), .string("05, 14"))
        XCTAssertEqual(result.body, "paydock.error · sdk_error · CARD_INVALID")
        XCTAssertEqual(result.timeUnixMillis, Self.builtAt)
    }

    func testUncaughtError() {
        let event = TelemetryEvent.uncaughtException(error: TelemetryEvent.ErrorInfo(type: "MobileSDK.SampleError", frames: []),
                                                     threadName: "worker", widget: "CardDetailsWidget")

        let result = record(event)

        XCTAssertEqual(result.value("paydock.error.kind"), .string("uncaught"))
        XCTAssertEqual(result.value("thread.name"), .string("worker"))
        XCTAssertEqual(result.value("paydock.widget"), .string("CardDetailsWidget"))
        XCTAssertEqual(result.value("paydock.exception.in_sdk"), .bool(true))
        XCTAssertEqual(result.body, "paydock.error · uncaught · MobileSDK.SampleError")
    }

    /// R_03: `in_sdk` comes from the event: true or false as given, absent when nil.
    func testSdkErrorAndUncaught_WriteInSdkFromTheEvent_AndNoneWhenNil() {
        let info = TelemetryEvent.ErrorInfo(type: "MobileSDK.SampleError", frames: [Self.frame])
        for inSdk in [true, false] {
            XCTAssertEqual(record(.sdkError(error: info, errorCode: "SAMPLE_CODE", inSdk: inSdk))
                .value("paydock.exception.in_sdk"), .bool(inSdk))
            XCTAssertEqual(record(.uncaughtException(error: info, inSdk: inSdk)).value("paydock.exception.in_sdk"), .bool(inSdk))
        }

        let sdkError = record(.sdkError(error: info, errorCode: "SAMPLE_CODE", widget: "CardDetailsWidget", inSdk: nil))
        let uncaught = record(.uncaughtException(error: info, threadName: "main", inSdk: nil))

        XCTAssertNil(sdkError.value("paydock.exception.in_sdk"))
        XCTAssertNil(uncaught.value("paydock.exception.in_sdk"))
        XCTAssertFalse(sdkError.attributes.map(\.key).contains("paydock.exception.in_sdk"))
        XCTAssertEqual(sdkError.value("paydock.error.code"), .string("SAMPLE_CODE"), "nothing else changes")
        XCTAssertEqual(uncaught.value("thread.name"), .string("main"))
    }

    // MARK: - Network

    func testNetworkFailure_HTTPStatus_HasTheGroupKey() {
        let apiError = TelemetryEvent.APIError(status: 502, code: "gateway_error", gatewayCodes: ["91", "96"])
        let event = TelemetryEvent.networkFailure(method: .post, urlTemplate: "/v1/charges/{id}", serverAddress: "api.paydock.com",
                                                  failure: .httpStatus(code: 502), attempt: 2, apiError: apiError,
                                                  widget: "CardDetailsWidget")

        let result = record(event)

        XCTAssertEqual(result.attributes.map(\.key), [
            "event.name", "session.id", "log.record.uid", "network.connection.type", "paydock.widget", "paydock.group.key",
            "http.request.method", "url.template", "server.address", "http.response.status_code", "error.type",
            "paydock.api.status", "paydock.api.error.code", "paydock.api.gateway.codes", "paydock.http.attempt"
        ])
        XCTAssertEqual(result.value("paydock.group.key"), .string("http POST /v1/charges/{id} 502"))
        XCTAssertEqual(result.value("error.type"), .string("http_5xx"))
        XCTAssertEqual(result.value("paydock.api.gateway.codes"), .string("91, 96"))
        XCTAssertEqual(result.value("paydock.http.attempt"), .int(2))
        XCTAssertEqual(result.body, "paydock.network.failure · http_5xx 502 · POST /v1/charges/{id}")
    }

    func testNetworkFailure_ErrorTypeByStatus() {
        XCTAssertEqual(record(network(.httpStatus(code: 499))).value("error.type"), .string("http_4xx"))
        XCTAssertEqual(record(network(.httpStatus(code: 500))).value("error.type"), .string("http_5xx"))
    }

    func testNetworkFailure_Transport_HasNoGroupKeyOrStatus_ButTheErrorTypeAndStack() {
        let error = TelemetryEvent.ErrorInfo(type: "Foundation.URLError", frames: [Self.frame])

        let result = record(network(.transport(kind: .timeout, error: error)))

        XCTAssertNil(result.value("paydock.group.key"))
        XCTAssertNil(result.value("http.response.status_code"))
        XCTAssertEqual(result.value("error.type"), .string("timeout"))
        XCTAssertEqual(result.value("exception.type"), .string("Foundation.URLError"))
        XCTAssertEqual(result.value("exception.stacktrace"), .string("Foundation.URLError\n\tat \(Self.frame)"))
        XCTAssertNil(result.value("paydock.exception.in_sdk"))
        XCTAssertEqual(result.body, "paydock.network.failure · timeout · GET /v1/vault/{id}")
    }

    func testNetworkFailure_Decode_HasItsStatus_AndNoGroupKey() {
        let result = record(network(.decode(statusCode: 200)))

        XCTAssertNil(result.value("paydock.group.key"))
        XCTAssertEqual(result.value("http.response.status_code"), .int(200))
        XCTAssertEqual(result.value("error.type"), .string("decode"))
        XCTAssertNil(record(network(.decode())).value("http.response.status_code"))
    }

    // MARK: - Widget opened and dropped

    func testWidgetOpenedAndDropped() {
        let opened = record(.widgetOpened(widget: "CardDetailsWidget"))
        XCTAssertEqual(opened.eventName, "paydock.widget.opened")
        XCTAssertEqual(opened.body, "paydock.widget.opened · CardDetailsWidget")

        let dropped = record(.dropped(reason: .storeFull, count: 7))
        XCTAssertEqual(dropped.eventName, "paydock.telemetry.dropped")
        XCTAssertEqual(dropped.value("paydock.dropped.reason"), .string("store_full"))
        XCTAssertEqual(dropped.value("paydock.dropped.count"), .int(7))
        XCTAssertEqual(dropped.body, "paydock.telemetry.dropped · store_full · 7 records")
    }

    // MARK: - Payments (D24)

    func testPaymentStarted_FieldsInKeyOrder() {
        let started = record(.paymentStarted(widget: "PayPalWidget", paymentId: Self.paymentId))

        XCTAssertEqual(started.severity, .info)
        XCTAssertEqual(started.attributes.map(\.key), [
            "event.name", "session.id", "log.record.uid", "network.connection.type", "paydock.widget", "paydock.payment.id"
        ])
        XCTAssertEqual(started.eventName, "paydock.payment.started")
        XCTAssertEqual(started.value("paydock.widget"), .string("PayPalWidget"))
        XCTAssertEqual(started.value("paydock.payment.id"), .string(Self.paymentId))
        XCTAssertEqual(started.body, "paydock.payment.started · PayPalWidget")
    }

    func testPaymentFinished_AnError_KeepsItsCode_FieldsInKeyOrder() {
        let finished = record(.paymentFinished(widget: "CardDetailsWidget", paymentId: Self.paymentId, outcome: .error,
                                               errorCode: "CARD_TOKENISE_ERROR", durationMs: 2_215))

        XCTAssertEqual(finished.severity, .info)
        XCTAssertEqual(finished.attributes.map(\.key), [
            "event.name", "session.id", "log.record.uid", "network.connection.type", "paydock.widget", "paydock.error.code",
            "paydock.payment.id", "paydock.payment.outcome", "paydock.payment.duration_ms"
        ])
        XCTAssertEqual(finished.eventName, "paydock.payment.finished")
        XCTAssertEqual(finished.value("paydock.error.code"), .string("CARD_TOKENISE_ERROR"))
        XCTAssertEqual(finished.value("paydock.payment.outcome"), .string("error"))
        XCTAssertEqual(finished.value("paydock.payment.duration_ms"), .int(2_215))
        XCTAssertEqual(finished.body, "paydock.payment.finished · CardDetailsWidget · error · CARD_TOKENISE_ERROR")
    }

    func testPaymentFinished_DropsTheCode_ForEveryOtherOutcome() {
        for outcome in TelemetryEvent.PaymentOutcome.allCases where outcome != .error {
            let finished = record(.paymentFinished(widget: "ApplePayWidget", paymentId: Self.paymentId, outcome: outcome,
                                                   errorCode: "APPLE_PAY_PRESENT_FAILED", durationMs: 900))

            XCTAssertNil(finished.value("paydock.error.code"), outcome.rawValue)
            XCTAssertEqual(finished.attributes.map(\.key), [
                "event.name", "session.id", "log.record.uid", "network.connection.type", "paydock.widget",
                "paydock.payment.id", "paydock.payment.outcome", "paydock.payment.duration_ms"
            ], outcome.rawValue)
            XCTAssertEqual(finished.value("paydock.payment.outcome"), .string(outcome.rawValue))
            XCTAssertEqual(finished.body, "paydock.payment.finished · ApplePayWidget · \(outcome.rawValue)")
        }
        XCTAssertEqual(TelemetryEvent.PaymentOutcome.allCases.map(\.rawValue), ["success", "declined", "error", "cancelled"])
    }

    func testPaymentFinished_AnErrorWithoutACode_HasNone() {
        let finished = record(.paymentFinished(widget: "Standalone3DSWidget", paymentId: Self.paymentId, outcome: .error,
                                               durationMs: 5))

        XCTAssertNil(finished.value("paydock.error.code"))
        XCTAssertEqual(finished.body, "paydock.payment.finished · Standalone3DSWidget · error")
    }

    // MARK: - Helpers

    private func record(_ event: TelemetryEvent) -> TelemetryRecord {
        let pending = PendingRecord(id: "\(Self.sessionId)-1", sessionId: Self.sessionId, event: event, createdAt: Self.builtAt)
        return RecordFactory.create(pending, connection: .wifi)
    }

    private func crash(kind: TelemetryEvent.CrashKind) -> TelemetryEvent {
        .crash(error: TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: []), source: .metricKit, kind: kind, inSdk: true)
    }

    private func network(_ failure: TelemetryEvent.NetworkError) -> TelemetryEvent {
        .networkFailure(method: .get, urlTemplate: "/v1/vault/{id}", serverAddress: "api.paydock.com", failure: failure)
    }
}
