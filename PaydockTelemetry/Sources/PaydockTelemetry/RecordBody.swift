//
//  RecordBody.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The one body rule (spec § 5.2), read from attribute values only: `event.name`, then the event's details, each
/// from an allowlisted value, joined with ` · ` (generate.py `record()`).
package enum RecordBody {
    private static let separator = " · "

    package static func of(_ attributes: [TelemetryAttribute]) -> String {
        let values = Values(attributes)
        guard let name = values.text("event.name") else {
            return ""
        }
        let parts: [String?]
        switch name {
        case "paydock.crash":
            let kind = values.text("paydock.crash.kind")
            let detail = values.text("paydock.crash.reason") ?? values.text("exception.type")
            parts = [kind, detail?.lowercased() == kind?.lowercased() ? nil : detail]
        case "paydock.error":
            parts = [values.text("paydock.error.kind"), values.text("paydock.error.code") ?? values.text("exception.type")]
        case "paydock.network.failure":
            parts = [network(values), request(values)]
        case "paydock.widget.opened":
            parts = [values.text("paydock.widget")]
        case "paydock.payment.started":
            parts = [values.text("paydock.widget")]
        case "paydock.payment.finished":
            parts = [values.text("paydock.widget"), values.text("paydock.payment.outcome"), values.text("paydock.error.code")]
        case "paydock.telemetry.dropped":
            parts = [values.text("paydock.dropped.reason"), values.text("paydock.dropped.count").map { "\($0) records" }]
        default:
            parts = []
        }
        return ([name] + parts).compactMap { $0 }.joined(separator: separator)
    }

    /// `"<error.type>[ <status>]"`.
    private static func network(_ values: Values) -> String? {
        let text = [values.text("error.type"), values.text("http.response.status_code")].compactMap { $0 }.joined(separator: " ")
        return text.isEmpty ? nil : text
    }

    /// `"<method> <url.template>"` when both are present.
    private static func request(_ values: Values) -> String? {
        guard let method = values.text("http.request.method"), let template = values.text("url.template") else {
            return nil
        }
        return "\(method) \(template)"
    }

    /// The first value of each key as text; an empty string reads as absent.
    private struct Values {
        private let attributes: [TelemetryAttribute]

        init(_ attributes: [TelemetryAttribute]) {
            self.attributes = attributes
        }

        func text(_ key: String) -> String? {
            switch attributes.first(where: { $0.key == key })?.value {
            case let .string(text):
                return text.isEmpty ? nil : text
            case let .int(number):
                return String(number)
            case let .bool(flag):
                return String(flag)
            case nil:
                return nil
            }
        }
    }
}
