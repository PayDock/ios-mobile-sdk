//
//  ThreeDSAttributesTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// D25 (R_01, R_05): the 3DS charge ID on both payment records and the authentication flow on the finish, allowlisted
/// last, absent when unknown, and kept by the reducer on the finish it rebuilds.
final class ThreeDSAttributesTests: XCTestCase {

    private typealias Samples = SensitiveSamples

    private static let paymentId = "e7a3c915-4d2b-4f80-b6c1-0a9d5e72f348"
    private static let charge3dsId = "6741b9c2e4a17f0d3c5b8a9e"
    private static let widget = "Standalone3DSWidget"

    // MARK: - Started

    func testStarted_WithAChargeId_CarriesIt() {
        let record = Self.record(.paymentStarted(widget: Self.widget, paymentId: Self.paymentId, charge3dsId: Self.charge3dsId))

        XCTAssertEqual(record.value("paydock.3ds.charge_id"), .string(Self.charge3dsId))
        XCTAssertNil(record.value("paydock.3ds.flow"))
        XCTAssertEqual(record.attributes.last?.key, "paydock.3ds.charge_id")
        XCTAssertEqual(Allowlist.filter(record), record)
    }

    func testStarted_WithoutAChargeId_HasNoKey() {
        let record = Self.record(.paymentStarted(widget: Self.widget, paymentId: Self.paymentId))

        XCTAssertNil(record.value("paydock.3ds.charge_id"))
        XCTAssertNil(record.value("paydock.3ds.flow"))
    }

    func testAnEmptyChargeId_IsAbsent() {
        let started = Self.record(.paymentStarted(widget: Self.widget, paymentId: Self.paymentId, charge3dsId: ""))
        let finished = Self.record(.paymentFinished(widget: Self.widget, paymentId: Self.paymentId, outcome: .success,
                                                    charge3dsId: ""))

        XCTAssertNil(started.value("paydock.3ds.charge_id"))
        XCTAssertNil(finished.value("paydock.3ds.charge_id"))
    }

    // MARK: - Finished

    func testFinished_CarriesTheChargeIdAndTheFlow_InFixtureOrder() {
        let record = Self.record(.paymentFinished(widget: Self.widget, paymentId: Self.paymentId, outcome: .success,
                                                  durationMs: 26_470, charge3dsId: Self.charge3dsId, flow: .challenge))

        XCTAssertEqual(Array(record.attributes.map(\.key).suffix(5)), [
            "paydock.payment.id", "paydock.payment.outcome", "paydock.payment.duration_ms",
            "paydock.3ds.charge_id", "paydock.3ds.flow"
        ])
        XCTAssertEqual(record.value("paydock.3ds.charge_id"), .string(Self.charge3dsId))
        XCTAssertEqual(record.value("paydock.3ds.flow"), .string("challenge"))
        XCTAssertEqual(Allowlist.filter(record), record)
    }

    func testTheBody_StaysWidgetOutcomeCode() {
        let record = Self.record(.paymentFinished(widget: Self.widget, paymentId: Self.paymentId, outcome: .declined,
                                                  charge3dsId: Self.charge3dsId, flow: .decoupled))

        XCTAssertEqual(record.body, "paydock.payment.finished · Standalone3DSWidget · declined")
    }

    // MARK: - Allowlist

    func testTheThreeDSKeys_EndTheRecordKeys_AsStrings() {
        XCTAssertEqual(Array(Allowlist.recordKeys.suffix(2)), ["paydock.3ds.charge_id", "paydock.3ds.flow"])
        XCTAssertEqual(Allowlist.recordKinds["paydock.3ds.charge_id"], .string)
        XCTAssertEqual(Allowlist.recordKinds["paydock.3ds.flow"], .string)
    }

    func testAnUnknownFlow_IsRejected() {
        let base = Self.record(.paymentFinished(widget: Self.widget, paymentId: Self.paymentId, outcome: .success,
                                                charge3dsId: Self.charge3dsId, flow: .challenge))
        for flow in ["unknown", "CHALLENGE", "frictionless ", ""] {
            let record = base.with("paydock.3ds.flow", .string(flow))

            XCTAssertFalse(Allowlist.violations(resource: Self.resource(), records: [record]).isEmpty, flow)
            XCTAssertNil(Allowlist.filter(record).value("paydock.3ds.flow"), flow)
        }
    }

    func testEveryFlowRawValue_Passes() {
        XCTAssertEqual(TelemetryEvent.ThreeDSFlow.allCases.map(\.rawValue), ["frictionless", "challenge", "decoupled"])
        for flow in TelemetryEvent.ThreeDSFlow.allCases {
            let record = Self.record(.paymentFinished(widget: Self.widget, paymentId: Self.paymentId, outcome: .success,
                                                      flow: flow))

            XCTAssertEqual(record.value("paydock.3ds.flow"), .string(flow.rawValue))
            XCTAssertEqual(Allowlist.filter(record), record, flow.rawValue)
            XCTAssertEqual(Allowlist.violations(resource: Self.resource(), records: [record]), [], flow.rawValue)
        }
    }

    func testASensitiveChargeId_IsDropped() {
        let base = Self.record(.paymentStarted(widget: Self.widget, paymentId: Self.paymentId, charge3dsId: Self.charge3dsId))
        for value in [Samples.cardNumber, Samples.email, Samples.longSecret] {
            let record = base.with("paydock.3ds.charge_id", .string(value))

            XCTAssertNil(Allowlist.filter(record).value("paydock.3ds.charge_id"))
        }
    }

    // MARK: - Reducer

    func testTheReducer_KeepsBothValues_OnTheFinishItRebuilds() {
        let sequence = RecordSequence()
        let initial = TelemetryState(enabled: true, sessionId: "session")
        let started = TelemetryReducer.reduce(
            initial,
            .reported(.paymentStarted(widget: Self.widget, paymentId: Self.paymentId, charge3dsId: Self.charge3dsId)),
            now: 1_000, elapsed: 1_000, sequence: sequence
        )
        let finished = TelemetryReducer.reduce(
            started.state,
            .reported(.paymentFinished(widget: Self.widget, paymentId: Self.paymentId, outcome: .success, durationMs: 5,
                                       charge3dsId: Self.charge3dsId, flow: .challenge)),
            now: 2_000, elapsed: 27_470, sequence: sequence
        )

        guard case let .persist(record) = finished.effects.first else {
            return XCTFail("the finish persists a record")
        }
        XCTAssertEqual(record.event, .paymentFinished(widget: Self.widget, paymentId: Self.paymentId, outcome: .success,
                                                      durationMs: 26_470, charge3dsId: Self.charge3dsId, flow: .challenge))
    }

    // MARK: - Helpers

    private static func record(_ event: TelemetryEvent) -> TelemetryRecord {
        let pending = PendingRecord(id: "\(Samples.sessionId)-3", sessionId: Samples.sessionId, event: event,
                                    createdAt: Samples.builtAt)
        return RecordFactory.create(pending, connection: .cell)
    }

    private static func resource() -> ResourceAttributes {
        ResourceAttributes(serviceVersion: "4.9.1", deploymentEnvironmentName: "sandbox", osVersion: "18.1",
                           deviceModelIdentifier: "iPhone15,2", appInstallationId: "5f0d2b8a-6c41-4e97-a3b2-8d1e7c9f4a60",
                           appId: "com.paydock.example", appVersion: "1.0.0", appDebuggable: true)
    }
}
