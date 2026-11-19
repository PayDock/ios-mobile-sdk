//
//  RecordFactory.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Builds a telemetry record from a pending record (spec § 5.2), mirroring generate.py `record()`.
/// Only typed event fields enter a record, never message text. `paydock.occurrences` is the duplicate gate's.
package enum RecordFactory {

    package static func create(_ pending: PendingRecord, connection: NetworkConnectionType) -> TelemetryRecord {
        var fields = Fields()
        fields.put("session.id", pending.sessionId)
        fields.put("log.record.uid", pending.id)
        fields.put("network.connection.type", connection.rawValue)
        let severity = addEvent(pending.event, to: &fields)
        let attributes = Allowlist.recordKeys.compactMap { key in
            fields.values[key].map { TelemetryAttribute(key: key, value: $0) }
        }
        return TelemetryRecord(id: pending.id, timeUnixMillis: time(of: pending), severity: severity,
                               body: RecordBody.of(attributes), attributes: attributes)
    }

    /// The crash's own time, or else when the reducer created the record.
    private static func time(of pending: PendingRecord) -> Int64 {
        if case let .crash(_, _, _, _, _, _, occurredAt) = pending.event, let occurredAt {
            return occurredAt
        }
        return pending.createdAt
    }

    /// Adds `event.name` and the event's fields; gives the record's severity.
    private static func addEvent(_ event: TelemetryEvent, to fields: inout Fields) -> Severity {
        switch event {
        case let .crash(error, source, kind, inSdk, crashReason, threadName, _):
            fields.put("event.name", "paydock.crash")
            addException(error, inSdk: inSdk, to: &fields)
            fields.put("paydock.crash.kind", kind.rawValue)
            fields.put("paydock.crash.source", source.rawValue)
            fields.put("paydock.crash.reason", crashReason)
            fields.put("thread.name", threadName)
            return kind == .hang ? .error : .fatal
        case let .sdkError(error, errorCode, widget, apiError, inSdk):
            fields.put("event.name", "paydock.error")
            addException(error, inSdk: inSdk, to: &fields)
            fields.put("paydock.error.kind", "sdk_error")
            fields.put("paydock.error.code", errorCode)
            fields.put("paydock.widget", widget)
            addAPIError(apiError, to: &fields)
            return .error
        case let .uncaughtException(error, threadName, widget, inSdk):
            fields.put("event.name", "paydock.error")
            addException(error, inSdk: inSdk, to: &fields)
            fields.put("paydock.error.kind", "uncaught")
            fields.put("thread.name", threadName)
            fields.put("paydock.widget", widget)
            return .error
        case let .networkFailure(method, urlTemplate, serverAddress, failure, attempt, apiError, widget):
            fields.put("event.name", "paydock.network.failure")
            fields.put("http.request.method", method.rawValue)
            fields.put("url.template", urlTemplate)
            fields.put("server.address", serverAddress)
            addFailure(failure, method: method, urlTemplate: urlTemplate, to: &fields)
            addAPIError(apiError, to: &fields)
            fields.put("paydock.http.attempt", Int64(attempt))
            fields.put("paydock.widget", widget)
            return .error
        case let .widgetOpened(widget):
            fields.put("event.name", "paydock.widget.opened")
            fields.put("paydock.widget", widget)
            return .info
        case .paymentStarted, .paymentFinished:
            addPayment(event, to: &fields)
            return .info
        case let .dropped(reason, count):
            fields.put("event.name", "paydock.telemetry.dropped")
            fields.put("paydock.dropped.reason", reason.rawValue)
            fields.put("paydock.dropped.count", Int64(count))
            return .warn
        }
    }

    /// D24: a payment record's fields; `paydock.error.code` only for the `error` outcome.
    private static func addPayment(_ event: TelemetryEvent, to fields: inout Fields) {
        switch event {
        case let .paymentStarted(widget, paymentId):
            fields.put("event.name", "paydock.payment.started")
            fields.put("paydock.widget", widget)
            fields.put("paydock.payment.id", paymentId)
        case let .paymentFinished(widget, paymentId, outcome, errorCode, durationMs):
            fields.put("event.name", "paydock.payment.finished")
            fields.put("paydock.widget", widget)
            fields.put("paydock.error.code", outcome == .error ? errorCode : nil)
            fields.put("paydock.payment.id", paymentId)
            fields.put("paydock.payment.outcome", outcome.rawValue)
            fields.put("paydock.payment.duration_ms", durationMs)
        default:
            break
        }
    }

    /// The exception fields of a crash, an SDK error or an uncaught error.
    /// `paydock.exception.in_sdk` only when known: a crash the classifier cannot place has none.
    private static func addException(_ error: TelemetryEvent.ErrorInfo?, inSdk: Bool?, to fields: inout Fields) {
        if let error {
            fields.put("exception.type", error.type)
            fields.put("exception.stacktrace", StackTraceFormatter.format(error))
            fields.put("paydock.exception.cause_types", error.causeTypes.joined(separator: ", "))
        }
        fields.put("paydock.exception.in_sdk", inSdk)
    }

    /// The status, `error.type`, the failure error's type and stack, and the group key on an HTTP status only.
    private static func addFailure(_ failure: TelemetryEvent.NetworkError, method: TelemetryEvent.HTTPMethod,
                                   urlTemplate: String, to fields: inout Fields) {
        let error: TelemetryEvent.ErrorInfo?
        switch failure {
        case let .httpStatus(code):
            fields.put("http.response.status_code", Int64(code))
            fields.put("error.type", code < 500 ? "http_4xx" : "http_5xx")
            fields.put("paydock.group.key", "http \(method.rawValue) \(urlTemplate) \(code)")
            error = nil
        case let .transport(kind, transportError):
            fields.put("error.type", kind.rawValue)
            error = transportError
        case let .decode(statusCode, decodeError):
            fields.put("http.response.status_code", statusCode.map(Int64.init))
            fields.put("error.type", "decode")
            error = decodeError
        }
        if let error {
            fields.put("exception.type", error.type)
            fields.put("exception.stacktrace", StackTraceFormatter.format(error))
        }
    }

    /// The § 5.4 API fields, each when present and non-empty.
    private static func addAPIError(_ apiError: TelemetryEvent.APIError?, to fields: inout Fields) {
        guard let apiError else {
            return
        }
        fields.put("paydock.api.status", apiError.status.map(Int64.init))
        fields.put("paydock.api.error.code", apiError.code)
        fields.put("paydock.api.error.summary_code", apiError.summaryCode)
        fields.put("paydock.api.gateway.codes", apiError.gatewayCodes.joined(separator: ", "))
    }

    /// Collected attribute values by key; a nil value or an empty string is left out.
    private struct Fields {
        private(set) var values: [String: AttributeValue] = [:]

        mutating func put(_ key: String, _ text: String?) {
            if let text, !text.isEmpty {
                values[key] = .string(text)
            }
        }

        mutating func put(_ key: String, _ number: Int64?) {
            if let number {
                values[key] = .int(number)
            }
        }

        mutating func put(_ key: String, _ flag: Bool?) {
            if let flag {
                values[key] = .bool(flag)
            }
        }
    }
}
