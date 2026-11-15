//
//  OtlpLogEncoderTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class OtlpLogEncoderTests: XCTestCase {

    private let resource = ResourceAttributes(
        serviceVersion: "4.9.0",
        deploymentEnvironmentName: "sandbox",
        osVersion: "18.1",
        deviceModelIdentifier: "iPhone16,2",
        appInstallationId: "7c9e6679-7425-40de-944b-e07fc1f90ae7",
        appId: "com.paydock.example",
        appVersion: "1.2.3",
        appDebuggable: true
    )

    private let record = TelemetryRecord(
        id: "3f2a1c9e-8b7d-4e6f-a5c4-1b2d3e4f5a6b-2",
        timeUnixMillis: 1_793_830_203_000,
        severity: .warn,
        body: "rate_limit · 12 records",
        attributes: [
            TelemetryAttribute(key: "event.name", value: .string("paydock.telemetry.dropped")),
            TelemetryAttribute(key: "paydock.exception.in_sdk", value: .bool(false)),
            TelemetryAttribute(key: "url.template", value: .string("/v1/charges/{id}")),
            TelemetryAttribute(key: "paydock.dropped.count", value: .int(12))
        ]
    )

    func testEncoding_IsDeterministic() {
        let first = OtlpLogEncoder.encode(resource: resource, records: [record, record])
        let second = OtlpLogEncoder.encode(resource: resource, records: [record, record])

        XCTAssertFalse(first.isEmpty)
        XCTAssertEqual(first, second)
    }

    func testWireShape() throws {
        let json = try XCTUnwrap(String(data: OtlpLogEncoder.encode(resource: resource, records: [record]), encoding: .utf8))

        let logRecord = #"{"attributes":[{"key":"event.name","value":{"stringValue":"paydock.telemetry.dropped"}},"#
            + #"{"key":"paydock.exception.in_sdk","value":{"boolValue":false}},"#
            + #"{"key":"url.template","value":{"stringValue":"/v1/charges/{id}"}},"#
            + #"{"key":"paydock.dropped.count","value":{"intValue":"12"}}],"#
            + #""body":{"stringValue":"rate_limit · 12 records"},"severityNumber":13,"severityText":"WARN","#
            + #""timeUnixNano":"1793830203000000000"}"#
        XCTAssertTrue(json.hasPrefix(#"{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","#), json)
        XCTAssertTrue(json.hasSuffix(#""scopeLogs":[{"logRecords":["# + logRecord + #"],"scope":{"name":"paydock.telemetry"}}]}]}"#), json)
    }

    func testResourceAttributes_InAllowlistOrder_WithTypedValues_AndNoInstanceId() throws {
        let attributes = try resourceAttributes(OtlpLogEncoder.encode(resource: resource, records: []))

        XCTAssertEqual(attributes.compactMap { $0["key"] as? String }, Allowlist.resourceKeys)
        let values = Dictionary(uniqueKeysWithValues: attributes.compactMap { attribute -> (String, [String: Any])? in
            guard let key = attribute["key"] as? String, let value = attribute["value"] as? [String: Any] else {
                return nil
            }
            return (key, value)
        })
        XCTAssertEqual(values["paydock.telemetry.spec_version"]?["intValue"] as? String, "1")
        XCTAssertEqual(values["paydock.app.debuggable"]?["boolValue"] as? Bool, true)
        XCTAssertEqual(values["service.name"]?["stringValue"] as? String, "paydock-mobile-sdk")
        XCTAssertNil(values["service.instance.id"])
    }

    func testIntValue_IsWrittenAsADecimalString() throws {
        let big = TelemetryRecord(id: record.id, timeUnixMillis: 0, severity: .info, body: "",
                                  attributes: [TelemetryAttribute(key: "paydock.dropped.count", value: .int(9_007_199_254_740_993))])
        let json = try XCTUnwrap(String(data: OtlpLogEncoder.encode(resource: resource, records: [big]), encoding: .utf8))

        XCTAssertTrue(json.contains(#"{"intValue":"9007199254740993"}"#), json)
        XCTAssertTrue(json.contains(#""timeUnixNano":"0""#), json)
    }

    func testEmptyRecordList_GivesOneScopeWithNoRecords() throws {
        let data = OtlpLogEncoder.encode(resource: resource, records: [])
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.hasSuffix(#""scopeLogs":[{"logRecords":[],"scope":{"name":"paydock.telemetry"}}]}]}"#), json)
        XCTAssertEqual(OtlpLogEncoder.scopeName, "paydock.telemetry")
    }

    private func resourceAttributes(_ data: Data) throws -> [[String: Any]] {
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let resourceLogs = try XCTUnwrap(root["resourceLogs"] as? [[String: Any]])
        XCTAssertEqual(resourceLogs.count, 1)
        let resource = try XCTUnwrap(resourceLogs.first?["resource"] as? [String: Any])
        return try XCTUnwrap(resource["attributes"] as? [[String: Any]])
    }
}
