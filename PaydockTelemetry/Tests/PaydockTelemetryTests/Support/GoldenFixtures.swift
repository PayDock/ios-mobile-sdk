//
//  GoldenFixtures.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// The golden fixtures (`Fixtures/`, copied from the planning repo and never edited) and the mapping of each input
/// onto the record pipeline: a pending record, then RecordFactory → Allowlist.filter → SendStamp → OtlpLogEncoder.
enum GoldenFixtures {
    static let folders = ["shared", "ios"]
    private static let inputSuffix = ".input.json"

    /// One `<folder>/<base>.input.json` and its `<base>.ios.expected.json`.
    struct Fixture {
        let name: String
        let input: Input
        let expectedURL: URL
    }

    /// A fixture the mapping cannot represent; fails the test that loads it.
    struct MappingError: Error, CustomStringConvertible {
        let description: String

        init(_ description: String) {
            self.description = description
        }
    }

    // MARK: - Input shape (fixtures README)

    struct Input: Decodable {
        let time: String?
        let builtTime: String
        let sentTime: String
        let sessionId: String
        let sequence: Int
        let connection: String
        let event: EventInput
        let occurrences: Int?
        let clockOffsetMs: Int64?
    }

    struct EventInput: Decodable {
        let type: String
        let kind: String?
        let source: String?
        let reason: String?
        let thread: String?
        let inSdk: Bool?
        let error: ErrorInput?
        let code: String?
        let widget: String?
        let method: String?
        let urlTemplate: String?
        let serverAddress: String?
        let failure: FailureInput?
        let apiError: APIErrorInput?
        let attempt: Int?
        let count: Int?
    }

    /// A class, so an error can hold its cause.
    final class ErrorInput: Decodable {
        let type: String?
        let frames: [String]?
        let cause: ErrorInput?
    }

    struct FailureInput: Decodable {
        let kind: String
        let status: Int?
        let error: ErrorInput?
    }

    struct APIErrorInput: Decodable {
        let status: Int?
        let code: String?
        let summaryCode: String?
        let gatewayCodes: [String]?
    }

    // MARK: - Loading

    /// Every `*.input.json` under `Fixtures/shared` and `Fixtures/ios`, by folder then name.
    static func all() throws -> [Fixture] {
        let root = try root()
        var fixtures: [Fixture] = []
        for folder in folders {
            let directory = root.appendingPathComponent(folder, isDirectory: true)
            let names = try FileManager.default.contentsOfDirectory(atPath: directory.path)
                .filter { $0.hasSuffix(inputSuffix) }
                .sorted()
            for name in names {
                let base = String(name.dropLast(inputSuffix.count))
                let input = try JSONDecoder().decode(Input.self, from: Data(contentsOf: directory.appendingPathComponent(name)))
                fixtures.append(Fixture(name: "\(folder)/\(base)", input: input,
                                        expectedURL: directory.appendingPathComponent("\(base).ios.expected.json")))
            }
        }
        return fixtures
    }

    /// The parsed `<base>.ios.expected.json`.
    static func expected(_ fixture: Fixture) throws -> Any {
        try JSONSerialization.jsonObject(with: Data(contentsOf: fixture.expectedURL))
    }

    /// The device context of `context.ios.json`; its keys must be the § 5.1 keys and its constant keys must equal
    /// `ResourceAttributes`' constants.
    static func resource() throws -> ResourceAttributes {
        let data = try Data(contentsOf: root().appendingPathComponent("context.ios.json"))
        guard let context = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw MappingError("context.ios.json is not an object")
        }
        guard Set(context.keys) == Set(Allowlist.resourceKeys) else {
            throw MappingError("context.ios.json keys differ from Allowlist.resourceKeys")
        }
        let constants: [(key: String, value: String)] = [
            ("service.name", ResourceAttributes.serviceName), ("service.namespace", ResourceAttributes.serviceNamespace),
            ("paydock.sdk.platform", ResourceAttributes.sdkPlatform), ("os.name", ResourceAttributes.osName),
            ("device.manufacturer", ResourceAttributes.deviceManufacturer)
        ]
        for constant in constants where context[constant.key] as? String != constant.value {
            throw MappingError("context.ios.json \(constant.key) differs from ResourceAttributes")
        }
        guard context["paydock.telemetry.spec_version"] as? Int == ResourceAttributes.specVersion else {
            throw MappingError("context.ios.json paydock.telemetry.spec_version differs from ResourceAttributes")
        }
        return ResourceAttributes(
            serviceVersion: try text(context, "service.version"),
            deploymentEnvironmentName: try text(context, "deployment.environment.name"),
            osVersion: try text(context, "os.version"),
            deviceModelIdentifier: try text(context, "device.model.identifier"),
            appInstallationId: try text(context, "app.installation.id"),
            appId: try text(context, "paydock.app.id"),
            appVersion: try text(context, "paydock.app.version"),
            appDebuggable: try required(context["paydock.app.debuggable"] as? Bool, "paydock.app.debuggable")
        )
    }

    // MARK: - Pipeline

    /// The record as I7 would send it: built, filtered, then stamped at `sentTime`.
    static func record(_ fixture: Fixture) throws -> TelemetryRecord {
        let input = fixture.input
        let connection = try required(NetworkConnectionType(rawValue: input.connection), "connection \(input.connection)")
        let built = RecordFactory.create(try pending(input), connection: connection)
        return SendStamp.stamp(Allowlist.filter(built), sentAt: try millis(input.sentTime),
                               clockOffsetMilliseconds: input.clockOffsetMs ?? 0)
    }

    /// The fixture's one-record export request.
    static func encoded(_ fixture: Fixture, resource: ResourceAttributes) throws -> Data {
        OtlpLogEncoder.encode(resource: resource, records: [try record(fixture)])
    }

    static func pending(_ input: Input) throws -> PendingRecord {
        let builtTime = try millis(input.builtTime)
        return PendingRecord(id: "\(input.sessionId)-\(input.sequence)", sessionId: input.sessionId,
                             event: try event(input, builtTime: builtTime), firstSeenAt: builtTime,
                             occurrences: input.occurrences ?? 1)
    }

    /// UTC epoch milliseconds of a fixture time.
    static func millis(_ iso: String) throws -> Int64 {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = try required(formatter.date(from: iso), "time \(iso)")
        return Int64((date.timeIntervalSince1970 * 1_000).rounded())
    }

    // MARK: - Events

    /// A MetricKit crash takes `time` as its own time (nil when null); any other event must have `time == builtTime`.
    private static func event(_ input: Input, builtTime: Int64) throws -> TelemetryEvent {
        let event = input.event
        let time = try input.time.map(millis)
        if event.type == "Crash", event.source == TelemetryEvent.CrashSource.metricKit.rawValue {
            return try crash(event, occurredAt: time)
        }
        guard time == builtTime else {
            throw MappingError("\(event.type): time must equal builtTime")
        }
        switch event.type {
        case "Crash":
            return try crash(event, occurredAt: nil)
        case "SdkError":
            try requireInSdk(event)
            guard event.thread == nil else {
                throw MappingError("SdkError: the event model has no thread")
            }
            return .sdkError(error: try errorInfo(required(event.error, "error")), errorCode: event.code, widget: event.widget,
                             apiError: event.apiError.map(apiError))
        case "UncaughtException":
            try requireInSdk(event)
            return .uncaughtException(error: try errorInfo(required(event.error, "error")), threadName: event.thread,
                                      widget: event.widget)
        case "NetworkFailure":
            return try networkFailure(event)
        case "WidgetOpened":
            return .widgetOpened(widget: try required(event.widget, "widget"))
        case "Dropped":
            return .dropped(reason: try required(TelemetryEvent.DroppedReason(rawValue: event.reason ?? ""), "dropped reason"),
                            count: try required(event.count, "count"))
        default:
            throw MappingError("unknown event type \(event.type)")
        }
    }

    private static func crash(_ event: EventInput, occurredAt: Int64?) throws -> TelemetryEvent {
        .crash(
            error: event.error.map(errorInfo),
            source: try required(TelemetryEvent.CrashSource(rawValue: event.source ?? ""), "crash source"),
            kind: try required(TelemetryEvent.CrashKind(rawValue: event.kind ?? ""), "crash kind"),
            inSdk: try required(event.inSdk, "inSdk"),
            crashReason: event.reason,
            threadName: event.thread,
            occurredAt: occurredAt
        )
    }

    private static func networkFailure(_ event: EventInput) throws -> TelemetryEvent {
        .networkFailure(
            method: try required(TelemetryEvent.HTTPMethod(rawValue: event.method ?? ""), "method"),
            urlTemplate: try required(event.urlTemplate, "urlTemplate"),
            serverAddress: try required(event.serverAddress, "serverAddress"),
            failure: try failure(required(event.failure, "failure")),
            attempt: try required(event.attempt, "attempt"),
            apiError: event.apiError.map(apiError),
            widget: event.widget
        )
    }

    /// `http` → `.httpStatus`, `decode` → `.decode`, `timeout`/`connection`/`tls`/`unknown` → `.transport`.
    private static func failure(_ input: FailureInput) throws -> TelemetryEvent.NetworkError {
        switch input.kind {
        case "http":
            return .httpStatus(code: try required(input.status, "failure.status"))
        case "decode":
            return .decode(statusCode: input.status, error: input.error.map(errorInfo))
        default:
            let kind = try required(TelemetryEvent.TransportKind(rawValue: input.kind), "failure.kind \(input.kind)")
            return .transport(kind: kind, error: input.error.map(errorInfo))
        }
    }

    private static func errorInfo(_ input: ErrorInput) -> TelemetryEvent.ErrorInfo {
        TelemetryEvent.ErrorInfo(type: input.type, frames: input.frames ?? [], cause: input.cause.map(errorInfo))
    }

    /// `{}` → `APIError()`.
    private static func apiError(_ input: APIErrorInput) -> TelemetryEvent.APIError {
        TelemetryEvent.APIError(status: input.status, code: input.code, summaryCode: input.summaryCode,
                                gatewayCodes: input.gatewayCodes ?? [])
    }

    /// An SDK or uncaught error is always in the SDK in the event model.
    private static func requireInSdk(_ event: EventInput) throws {
        guard event.inSdk == true else {
            throw MappingError("\(event.type): the event model writes paydock.exception.in_sdk true")
        }
    }

    // MARK: - Helpers

    private static func root() throws -> URL {
        try required(Bundle.module.url(forResource: "Fixtures", withExtension: nil), "the Fixtures folder in the test bundle")
    }

    private static func text(_ context: [String: Any], _ key: String) throws -> String {
        try required(context[key] as? String, key)
    }

    private static func required<Value>(_ value: Value?, _ what: String) throws -> Value {
        guard let value else {
            throw MappingError("missing or invalid \(what)")
        }
        return value
    }
}
