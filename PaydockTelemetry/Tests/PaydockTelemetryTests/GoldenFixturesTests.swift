//
//  GoldenFixturesTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_08: every shared and iOS golden fixture encodes to its expected JSON, compared as parsed JSON with attribute
/// order. A mismatch is fixed in the builder or the encoder, never in the copied fixture.
final class GoldenFixturesTests: XCTestCase {

    func testThereAreExactlyTenInputs() throws {
        let names = try GoldenFixtures.all().map(\.name)

        XCTAssertEqual(names.count, 10, "\(names)")
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
}
