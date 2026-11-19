//
//  DuplicateGateTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_07: records with the same session, event name and signature merge; notices and records without a session never do.
final class DuplicateGateTests: XCTestCase {

    private static let session = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
    private static let otherSession = "9a3e5d71-0c2b-4f86-b1e4-7d5a2c9f0e13"
    private static let time: Int64 = 1_793_852_047_512

    func testTheSameKindAndType_WithDifferentFramesOrFields_StaySeparate() {
        let records = [
            built(1, TelemetryFixtures.sdkError(frames: ["MobileSDK Sample.one() + 4"])),
            built(2, TelemetryFixtures.sdkError(frames: ["MobileSDK Sample.two() + 4"])),
            built(3, .sdkError(error: TelemetryFixtures.info(), errorCode: "OTHER_CODE")),
            built(4, .sdkError(error: TelemetryFixtures.info(), errorCode: "SAMPLE_CODE", widget: "CardDetailsWidget")),
            built(5, TelemetryFixtures.networkFailure()),
            built(6, TelemetryFixtures.networkFailure(failure: .httpStatus(code: 500))),
            built(7, TelemetryFixtures.networkFailure(urlTemplate: "/v1/vault/{id}")),
            built(8, TelemetryFixtures.networkFailure(method: .get)),
            built(9, .widgetOpened(widget: "CardDetailsWidget")),
            built(10, .widgetOpened(widget: "ApplePayWidget"))
        ]

        let merged = DuplicateGate.merge(records)

        XCTAssertEqual(merged.map(\.record), records)
        XCTAssertEqual(merged.map(\.sourceIds), records.map { [$0.id] })
    }

    func testExactDuplicatesInOneSession_Merge_WithTheSummedCountAndTheHighestAttempt_KeepingTheEarliest() throws {
        let event = TelemetryFixtures.networkFailure()
        let first = built(4, event, at: Self.time, attempt: 1)
        let second = built(5, event, at: Self.time + 10, attempt: 3).with("paydock.occurrences", .int(2))
        let third = built(6, event, at: Self.time + 20, attempt: 2)

        let merged = try XCTUnwrap(DuplicateGate.merge([third, first, second]).first)

        XCTAssertEqual(merged.sourceIds, [third.id, first.id, second.id])
        XCTAssertEqual(merged.record.id, first.id)
        XCTAssertEqual(merged.record.timeUnixMillis, first.timeUnixMillis)
        XCTAssertEqual(merged.record.value("paydock.occurrences"), .int(4))
        XCTAssertEqual(merged.record.value("paydock.http.attempt"), .int(3))
        XCTAssertEqual(merged.record.value("log.record.uid"), .string(first.id))
        XCTAssertEqual(merged.record.body, first.body)
        XCTAssertEqual(merged.record.body, RecordBody.of(merged.record.attributes))
        XCTAssertEqual(merged.record.attributes.map(\.key), Allowlist.recordKeys.filter { merged.record.value($0) != nil })
    }

    func testTheEarliest_IsByTime_ThenTheSequenceAsANumber() throws {
        let event = TelemetryFixtures.sdkError()
        let tenth = built(10, event)
        let ninth = built(9, event)
        let later = built(2, event, at: Self.time + 1)

        let byNumber = try XCTUnwrap(DuplicateGate.merge([tenth, later, ninth]).first)
        XCTAssertEqual(byNumber.record.id, ninth.id, "-9 comes before -10")
        XCTAssertEqual(byNumber.record.value("paydock.occurrences"), .int(3))

        let byTime = try XCTUnwrap(DuplicateGate.merge([later, built(1, event, at: Self.time + 5)]).first)
        XCTAssertEqual(byTime.record.id, later.id)
    }

    func testASingleRecord_IsKeptUnchanged_WithoutACount() {
        let record = built(1, TelemetryFixtures.networkFailure())

        XCTAssertEqual(DuplicateGate.merge([record]), [MergedRecord(record: record, sourceIds: [record.id])])
        XCTAssertNil(DuplicateGate.merge([record])[0].record.value("paydock.occurrences"))
    }

    func testDifferentSessions_NeverMerge() {
        let records = [built(1, TelemetryFixtures.sdkError()), built(1, TelemetryFixtures.sdkError(), session: Self.otherSession)]

        XCTAssertEqual(DuplicateGate.merge(records).map(\.record), records)
    }

    func testNotices_NeverMerge() {
        let notices = [built(1, .dropped(reason: .rateLimit, count: 3)), built(2, .dropped(reason: .rateLimit, count: 3))]

        XCTAssertNil(DuplicateGate.signature(notices[0]))
        XCTAssertEqual(DuplicateGate.merge(notices).map(\.record), notices)
    }

    func testIdenticalPaymentRecords_InOneSession_NeverMerge() {
        let paymentId = "2c7d9a05-6e18-4b3f-9d42-8a1f5e0c7b63"
        let started = TelemetryEvent.paymentStarted(widget: "Standalone3DSWidget", paymentId: paymentId)
        let finished = TelemetryEvent.paymentFinished(widget: "Standalone3DSWidget", paymentId: paymentId, outcome: .declined,
                                                      durationMs: 18_342)
        let records = [built(1, started), built(2, started), built(3, finished), built(4, finished)]

        let merged = DuplicateGate.merge(records)

        XCTAssertNil(DuplicateGate.signature(records[0]))
        XCTAssertNil(DuplicateGate.signature(records[2]))
        XCTAssertEqual(merged.map(\.record), records)
        XCTAssertEqual(merged.map(\.sourceIds), records.map { [$0.id] })
        XCTAssertTrue(merged.allSatisfy { $0.record.value("paydock.occurrences") == nil })
    }

    func testARecordWithoutASessionId_IsNeverMerged() {
        let records = [1, 2].map { sequence in
            let record = built(sequence, TelemetryFixtures.sdkError())
            return TelemetryRecord(id: record.id, timeUnixMillis: record.timeUnixMillis, severity: record.severity,
                                   body: record.body, attributes: record.attributes.filter { $0.key != "session.id" })
        }

        XCTAssertNil(DuplicateGate.signature(records[0]))
        XCTAssertEqual(DuplicateGate.merge(records).map(\.record), records)
    }

    func testMerge_KeepsInputOrder_ByEachGroupsFirstRecord() {
        let alpha = TelemetryFixtures.sdkError("Sample.Alpha")
        let beta = TelemetryFixtures.sdkError("Sample.Beta")
        let gamma = TelemetryFixtures.sdkError("Sample.Gamma")
        let records = [built(5, beta), built(2, alpha), built(6, beta), built(7, gamma), built(1, alpha)]

        let merged = DuplicateGate.merge(records)

        XCTAssertEqual(merged.map(\.sourceIds), [[records[0].id, records[2].id], [records[1].id, records[4].id], [records[3].id]])
        XCTAssertEqual(merged.map(\.record.id), [records[0].id, records[4].id, records[3].id])
    }

    func testTheSignature_IsSessionNameAndTheSignatureKeysInOrder() {
        let network = record("paydock.network.failure", [
            ("http.request.method", .string("POST")), ("url.template", .string("/v1/charges/{id}")),
            ("server.address", .string("api-sandbox.paydock.com")), ("http.response.status_code", .int(503)),
            ("error.type", .string("http_5xx")), ("paydock.api.error.code", .string("sample_code")),
            ("paydock.http.attempt", .int(2)), ("paydock.widget", .string("CardDetailsWidget"))
        ])
        XCTAssertEqual(DuplicateGate.signature(network), [
            "\(Self.session)", "paydock.network.failure", "paydock.widget=CardDetailsWidget", "http.request.method=POST",
            "url.template=/v1/charges/{id}", "http.response.status_code=503", "error.type=http_5xx",
            "paydock.api.error.code=sample_code"
        ].joined(separator: "\u{0}"))

        let crash = record("paydock.crash", [
            ("paydock.crash.reason", .string("SIGSEGV")), ("exception.type", .string("EXC_BAD_ACCESS")),
            ("paydock.crash.kind", .string("signal")), ("paydock.crash.source", .string("metrickit")),
            ("paydock.exception.in_sdk", .bool(true)), ("exception.stacktrace", .string("EXC_BAD_ACCESS"))
        ])
        XCTAssertEqual(DuplicateGate.signature(crash), [
            "\(Self.session)", "paydock.crash", "exception.type=EXC_BAD_ACCESS", "exception.stacktrace=EXC_BAD_ACCESS",
            "paydock.crash.kind=signal", "paydock.crash.source=metrickit", "paydock.crash.reason=SIGSEGV"
        ].joined(separator: "\u{0}"))

        let error = record("paydock.error", [
            ("paydock.error.code", .string("SAMPLE_CODE")), ("paydock.error.kind", .string("sdk_error")),
            ("exception.type", .string("Sample.Error")), ("thread.name", .string("main"))
        ])
        XCTAssertEqual(DuplicateGate.signature(error), [
            "\(Self.session)", "paydock.error", "exception.type=Sample.Error", "paydock.error.kind=sdk_error",
            "paydock.error.code=SAMPLE_CODE"
        ].joined(separator: "\u{0}"))

        let opened = record("paydock.widget.opened", [("paydock.widget", .string("CardDetailsWidget")),
                                                      ("exception.type", .string("Sample.Error"))])
        XCTAssertEqual(DuplicateGate.signature(opened),
                       "\(Self.session)\u{0}paydock.widget.opened\u{0}paydock.widget=CardDetailsWidget")
    }

    // MARK: - Helpers

    private func built(_ sequence: Int, _ event: TelemetryEvent, at time: Int64 = DuplicateGateTests.time,
                       session: String = DuplicateGateTests.session, attempt: Int? = nil) -> TelemetryRecord {
        var event = event
        if let attempt, case let .networkFailure(method, urlTemplate, serverAddress, failure, _, apiError, widget) = event {
            event = .networkFailure(method: method, urlTemplate: urlTemplate, serverAddress: serverAddress, failure: failure,
                                    attempt: attempt, apiError: apiError, widget: widget)
        }
        let pending = PendingRecord(id: "\(session)-\(sequence)", sessionId: session, event: event, createdAt: time)
        return RecordFactory.create(pending, connection: .wifi)
    }

    private func record(_ name: String, _ fields: [(String, AttributeValue)]) -> TelemetryRecord {
        let attributes = [TelemetryAttribute(key: "event.name", value: .string(name)),
                          TelemetryAttribute(key: "session.id", value: .string(Self.session))]
            + fields.map { TelemetryAttribute(key: $0.0, value: $0.1) }
        return TelemetryRecord(id: "\(Self.session)-1", timeUnixMillis: Self.time, severity: .error, body: name,
                               attributes: attributes)
    }
}
