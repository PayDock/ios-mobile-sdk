//
//  GoldenFixturesTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import PaydockTelemetry
import XCTest

/// R_08: every shared and iOS golden fixture encodes to its expected JSON, compared as parsed JSON with attribute
/// order. A mismatch is fixed in the builder or the encoder, never in the copied fixture.
final class GoldenFixturesTests: XCTestCase {

    func testThereAreExactlySixteenInputs() throws {
        let names = try GoldenFixtures.all().map(\.name)

        XCTAssertEqual(names.count, 16, "\(names)")
        XCTAssertEqual(Set(names.map { $0.components(separatedBy: "/")[0] }), Set(GoldenFixtures.folders))
    }

    func testEveryFixture_EncodesToItsExpectedJSON() throws {
        let resource = try GoldenFixtures.resource()

        for fixture in try GoldenFixtures.all() {
            let actual = try JSONSerialization.jsonObject(with: GoldenFixtures.encoded(fixture, resource: resource))
            let expected = try GoldenFixtures.expected(fixture)

            if let difference = JSONComparison.firstDifference(actual, expected) {
                XCTFail("\(fixture.name): \(difference)\nencoded:\n\(JSONComparison.text(actual))")
            }
        }
    }

    func testEveryFixtureBatch_HasNoViolation_AndTheFilterKeepsEveryAttribute() throws {
        let resource = try GoldenFixtures.resource()

        for fixture in try GoldenFixtures.all() {
            let built = RecordFactory.create(try GoldenFixtures.pending(fixture.input),
                                             connection: try XCTUnwrap(NetworkConnectionType(rawValue: fixture.input.connection)))
            let record = try GoldenFixtures.record(fixture)

            XCTAssertEqual(Allowlist.violations(resource: resource, records: [record]), [], fixture.name)
            XCTAssertEqual(Allowlist.filter(built), built, fixture.name)
        }
    }

    /// R_04, R_07: an observed failure for the shared `http-error` and `http-error-5xx` calls maps to an event whose record
    /// equals the fixture's expected attributes (but the widget, which the observer never knows), and whose group key is
    /// Android's string for string.
    func testObservedFailures_GiveTheSharedFixturesRecords_AndAndroidsGroupKeys() throws {
        let fixtures = try Dictionary(uniqueKeysWithValues: GoldenFixtures.all().map { ($0.name, $0) })
        let gatewayCode = "INVALID_REQUEST:INVALID:sourceOfFunds.provided.card.securityCode"
        let body = NetworkObservations.json([
            "status": 400,
            "error": ["message": SensitiveSamples.message, "code": "invalid_transaction_details",
                      "details": ["messages": [["gateway_specific_code": gatewayCode]]]],
            "error_summary": ["message": SensitiveSamples.message, "code": "invalid_transaction_details"]
        ])
        let observations: [(name: String, observation: RequestObservation)] = [
            ("shared/http-error", NetworkObservations.observation(
                method: .post, host: "api-sandbox.paydock.com", path: "/v1/payment_sources/tokens", statusCode: 400,
                error: RequestError.unexpectedErrorModel, errorBody: body
            )),
            ("shared/http-error-5xx", NetworkObservations.observation(
                method: .get, host: "api-sandbox.paydock.com", path: "/v1/gateways/63f0c1d2e3a4b5c6d7e8f901/wallet-config",
                attempt: 3, statusCode: 503, error: RequestError.unexpectedErrorModel, errorBody: Data("Service Unavailable".utf8)
            ))
        ]

        for (name, observation) in observations {
            let fixture = try XCTUnwrap(fixtures[name])
            let event = try XCTUnwrap(NetworkFailureFacts.event(observation, excludedHost: nil), name)
            let record = try Self.record(event, as: fixture.input)
            let expected = try GoldenFixtures.record(fixture)

            XCTAssertEqual(record.attributes, expected.attributes.filter { $0.key != "paydock.widget" }, name)
            XCTAssertEqual(record.body, expected.body, name)
            XCTAssertEqual(record.value("paydock.group.key").flatMap(Self.text),
                           try Self.androidGroupKey(fixture), name)
        }
        XCTAssertEqual(try GoldenFixtures.all().count, 16)
    }

    func testContext_MatchesTheResourceConstants() throws {
        let resource = try GoldenFixtures.resource()

        XCTAssertEqual(Set(resource.asMap().keys), Set(Allowlist.resourceKeys))
    }

    func testMapping_TakesAMetricKitCrashTime_AndBuildTimeOtherwise() throws {
        let fixtures = try Dictionary(uniqueKeysWithValues: GoldenFixtures.all().map { ($0.name, $0) })
        let signal = try XCTUnwrap(fixtures["ios/crash-signal"])
        let hang = try XCTUnwrap(fixtures["ios/crash-hang"])
        let exception = try XCTUnwrap(fixtures["ios/crash-exception"])

        XCTAssertEqual(RecordFactory.create(try GoldenFixtures.pending(signal.input), connection: .wifi).timeUnixMillis,
                       try GoldenFixtures.millis(try XCTUnwrap(signal.input.time)))
        XCTAssertEqual(RecordFactory.create(try GoldenFixtures.pending(hang.input), connection: .wifi).timeUnixMillis,
                       try GoldenFixtures.millis(hang.input.builtTime))
        XCTAssertEqual(RecordFactory.create(try GoldenFixtures.pending(exception.input), connection: .wifi).timeUnixMillis,
                       try GoldenFixtures.millis(exception.input.builtTime))
        XCTAssertEqual(try GoldenFixtures.record(signal).value(SendStamp.occurredAtKey), .string("2026-11-04T22:10:03.000Z"))
    }

    // MARK: - Helpers

    /// The event built, filtered and stamped as the fixture's own event would be.
    private static func record(_ event: TelemetryEvent, as input: GoldenFixtures.Input) throws -> TelemetryRecord {
        let pending = PendingRecord(id: "\(input.sessionId)-\(input.sequence)", sessionId: input.sessionId, event: event,
                                    createdAt: try GoldenFixtures.millis(input.builtTime))
        let built = RecordFactory.create(pending, connection: try XCTUnwrap(NetworkConnectionType(rawValue: input.connection)))
        return SendStamp.stamp(Allowlist.filter(built), sentAt: try GoldenFixtures.millis(input.sentTime),
                               clockOffsetMilliseconds: input.clockOffsetMs ?? 0)
    }

    /// `paydock.group.key` of the fixture's `.android.expected.json`.
    private static func androidGroupKey(_ fixture: GoldenFixtures.Fixture) throws -> String? {
        let base = fixture.expectedURL.lastPathComponent.replacingOccurrences(of: ".ios.expected.json", with: "")
        let url = fixture.expectedURL.deletingLastPathComponent().appendingPathComponent("\(base).android.expected.json")
        let root = try XCTUnwrap(try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let resourceLogs = try XCTUnwrap(root["resourceLogs"] as? [[String: Any]])
        let scopeLogs = try XCTUnwrap(resourceLogs.first?["scopeLogs"] as? [[String: Any]])
        let logRecords = try XCTUnwrap(scopeLogs.first?["logRecords"] as? [[String: Any]])
        let attributes = try XCTUnwrap(logRecords.first?["attributes"] as? [[String: Any]])
        let groupKey = attributes.first { $0["key"] as? String == "paydock.group.key" }
        return (groupKey?["value"] as? [String: Any])?["stringValue"] as? String
    }

    private static func text(_ value: AttributeValue) -> String? {
        if case let .string(text) = value {
            return text
        }
        return nil
    }
}
