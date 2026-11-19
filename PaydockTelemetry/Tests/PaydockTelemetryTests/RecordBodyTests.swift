//
//  RecordBodyTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class RecordBodyTests: XCTestCase {

    func testCrash_KindThenReason() {
        XCTAssertEqual(body(["event.name": "paydock.crash", "paydock.crash.kind": "signal", "paydock.crash.reason": "SIGSEGV",
                             "exception.type": "EXC_BAD_ACCESS"]), "paydock.crash · signal · SIGSEGV")
    }

    func testCrash_KindThenExceptionType_WithoutAReason() {
        XCTAssertEqual(body(["event.name": "paydock.crash", "paydock.crash.kind": "exception",
                             "exception.type": "NSInvalidArgumentException"]), "paydock.crash · exception · NSInvalidArgumentException")
    }

    func testCrash_DetailEqualToTheKindIgnoringCase_IsLeftOut() {
        XCTAssertEqual(body(["event.name": "paydock.crash", "paydock.crash.kind": "hang", "paydock.crash.reason": "Hang"]),
                       "paydock.crash · hang")
        XCTAssertEqual(body(["event.name": "paydock.crash", "paydock.crash.kind": "os_kill"]), "paydock.crash · os_kill")
    }

    func testError_KindThenCode_OrElseExceptionType() {
        XCTAssertEqual(body(["event.name": "paydock.error", "paydock.error.kind": "sdk_error", "paydock.error.code": "CARD_INVALID",
                             "exception.type": "MobileSDK.CardError"]), "paydock.error · sdk_error · CARD_INVALID")
        XCTAssertEqual(body(["event.name": "paydock.error", "paydock.error.kind": "uncaught",
                             "exception.type": "MobileSDK.CardError"]), "paydock.error · uncaught · MobileSDK.CardError")
    }

    func testNetworkFailure_ErrorTypeAndStatus_ThenMethodAndTemplate() {
        let attributes = [
            TelemetryAttribute(key: "event.name", value: .string("paydock.network.failure")),
            TelemetryAttribute(key: "http.request.method", value: .string("POST")),
            TelemetryAttribute(key: "url.template", value: .string("/v1/charges/{id}")),
            TelemetryAttribute(key: "http.response.status_code", value: .int(503)),
            TelemetryAttribute(key: "error.type", value: .string("http_5xx"))
        ]

        XCTAssertEqual(RecordBody.of(attributes), "paydock.network.failure · http_5xx 503 · POST /v1/charges/{id}")
    }

    func testNetworkFailure_WithoutStatusOrMethod() {
        XCTAssertEqual(body(["event.name": "paydock.network.failure", "error.type": "timeout", "url.template": "/v1/charges"]),
                       "paydock.network.failure · timeout")
    }

    func testWidgetOpened_TheWidget() {
        XCTAssertEqual(body(["event.name": "paydock.widget.opened", "paydock.widget": "CardDetailsWidget"]),
                       "paydock.widget.opened · CardDetailsWidget")
    }

    func testPaymentStarted_TheWidget() {
        XCTAssertEqual(body(["event.name": "paydock.payment.started", "paydock.widget": "PayPalWidget",
                             "paydock.payment.id": "9b2e4f61-7c3a-4d58-a1e9-3f0d6b8c2a17"]),
                       "paydock.payment.started · PayPalWidget")
    }

    func testPaymentFinished_TheWidgetAndOutcome_ThenTheCodeWhenPresent() {
        let attributes = [
            TelemetryAttribute(key: "event.name", value: .string("paydock.payment.finished")),
            TelemetryAttribute(key: "paydock.widget", value: .string("CardDetailsWidget")),
            TelemetryAttribute(key: "paydock.error.code", value: .string("CARD_TOKENISE_ERROR")),
            TelemetryAttribute(key: "paydock.payment.id", value: .string("e4a1c8b7-3f29-4d06-b5e8-7c2d9f1a0b34")),
            TelemetryAttribute(key: "paydock.payment.outcome", value: .string("error")),
            TelemetryAttribute(key: "paydock.payment.duration_ms", value: .int(2_215))
        ]

        XCTAssertEqual(RecordBody.of(attributes), "paydock.payment.finished · CardDetailsWidget · error · CARD_TOKENISE_ERROR")
        XCTAssertEqual(RecordBody.of(attributes.filter { $0.key != "paydock.error.code" }),
                       "paydock.payment.finished · CardDetailsWidget · error")
        XCTAssertEqual(body(["event.name": "paydock.payment.finished", "paydock.widget": "PayPalWidget",
                             "paydock.payment.outcome": "success"]), "paydock.payment.finished · PayPalWidget · success")
    }

    func testDropped_ReasonThenCount() {
        let attributes = [
            TelemetryAttribute(key: "event.name", value: .string("paydock.telemetry.dropped")),
            TelemetryAttribute(key: "paydock.dropped.reason", value: .string("rate_limit")),
            TelemetryAttribute(key: "paydock.dropped.count", value: .int(12))
        ]

        XCTAssertEqual(RecordBody.of(attributes), "paydock.telemetry.dropped · rate_limit · 12 records")
    }

    func testUnknownEventName_GivesTheNameAlone() {
        XCTAssertEqual(body(["event.name": "paydock.sample", "paydock.widget": "CardDetailsWidget"]), "paydock.sample")
    }

    func testNoEventName_GivesAnEmptyBody() {
        XCTAssertEqual(body(["paydock.widget": "CardDetailsWidget"]), "")
    }

    private func body(_ strings: KeyValuePairs<String, String>) -> String {
        RecordBody.of(strings.map { TelemetryAttribute(key: $0.key, value: .string($0.value)) })
    }
}
