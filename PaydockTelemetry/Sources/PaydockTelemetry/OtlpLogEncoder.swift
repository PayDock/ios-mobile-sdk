//
//  OtlpLogEncoder.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// OTLP/HTTP JSON logs (spec § 5), as generate.py `encode` writes them, and the store's one-record file format.
package enum OtlpLogEncoder {
    package static let scopeName = "paydock.telemetry"

    /// One export request, UTF-8, deterministic: resource attributes in Allowlist.resourceKeys order, then every
    /// record under one scope, attributes in the record's order.
    package static func encode(resource: ResourceAttributes, records: [TelemetryRecord]) -> Data {
        let map = resource.asMap()
        let resourceAttributes = Allowlist.resourceKeys.compactMap { key in
            map[key].map { KeyValue(key: key, value: Value($0)) }
        }
        let request = ExportRequest(resourceLogs: [
            ResourceLogs(
                resource: Resource(attributes: resourceAttributes),
                scopeLogs: [ScopeLogs(scope: Scope(name: scopeName), logRecords: records.map(LogRecord.init))]
            )
        ])
        return (try? makeEncoder().encode(request)) ?? Data()
    }

    /// One OTLP `logRecord`, UTF-8, deterministic: the store's file format.
    package static func recordJSON(_ record: TelemetryRecord) -> Data {
        (try? makeEncoder().encode(LogRecord(record))) ?? Data()
    }

    /// The record of one `recordJSON` file: the id from `log.record.uid`, the time from `timeUnixNano / 1_000_000`, the
    /// severity from `severityNumber`; nil when any is missing or the data is not a JSON object. An attribute of an
    /// unknown shape is skipped. Never throws.
    package static func parseRecord(_ data: Data) -> TelemetryRecord? {
        guard let parsed = try? JSONDecoder().decode(ParsedRecord.self, from: data),
              let time = parsed.timeUnixNano.flatMap(milliseconds),
              let severity = parsed.severityNumber.flatMap(Severity.init(rawValue:)) else {
            return nil
        }
        let attributes = parsed.attributes.compactMap(\.attribute)
        guard case let .string(id) = attributes.first(where: { $0.key == "log.record.uid" })?.value else {
            return nil
        }
        return TelemetryRecord(id: id, timeUnixMillis: time, severity: severity, body: parsed.body ?? "",
                               attributes: attributes)
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    /// `ns / 1_000_000` of a non-negative decimal string, without overflow; nil for anything else.
    private static func milliseconds(_ nanos: String) -> Int64? {
        guard !nanos.isEmpty, nanos.allSatisfy({ $0.isASCII && $0.isNumber }) else {
            return nil
        }
        return nanos.count <= 6 ? 0 : Int64(nanos.dropLast(6))
    }

    /// `ms * 1_000_000` as a decimal string, without overflow.
    private static func nanos(_ milliseconds: Int64) -> String {
        milliseconds == 0 ? "0" : "\(milliseconds)000000"
    }

    // MARK: - Wire shape

    private struct ExportRequest: Encodable {
        let resourceLogs: [ResourceLogs]
    }

    private struct ResourceLogs: Encodable {
        let resource: Resource
        let scopeLogs: [ScopeLogs]
    }

    private struct Resource: Encodable {
        let attributes: [KeyValue]
    }

    private struct ScopeLogs: Encodable {
        let scope: Scope
        let logRecords: [LogRecord]
    }

    private struct Scope: Encodable {
        let name: String
    }

    private struct LogRecord: Encodable {
        let timeUnixNano: String
        let severityNumber: Int
        let severityText: String
        let body: Value
        let attributes: [KeyValue]

        init(_ record: TelemetryRecord) {
            timeUnixNano = OtlpLogEncoder.nanos(record.timeUnixMillis)
            severityNumber = record.severity.rawValue
            severityText = record.severity.text
            body = .string(record.body)
            attributes = record.attributes.map { KeyValue(key: $0.key, value: Value($0.value)) }
        }
    }

    private struct KeyValue: Encodable {
        let key: String
        let value: Value
    }

    /// `{"stringValue":…}`, `{"intValue":"<decimal>"}` or `{"boolValue":…}`.
    private enum Value: Encodable {
        case string(String)
        case int(String)
        case bool(Bool)

        init(_ value: AttributeValue) {
            switch value {
            case let .string(text): self = .string(text)
            case let .int(number): self = .int(String(number))
            case let .bool(flag): self = .bool(flag)
            }
        }

        init(_ value: ResourceAttributeValue) {
            switch value {
            case let .string(text): self = .string(text)
            case let .int(number): self = .int(String(number))
            case let .bool(flag): self = .bool(flag)
            }
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: FieldKey.self)
            switch self {
            case let .string(text): try container.encode(text, forKey: FieldKey("stringValue"))
            case let .int(number): try container.encode(number, forKey: FieldKey("intValue"))
            case let .bool(flag): try container.encode(flag, forKey: FieldKey("boolValue"))
            }
        }
    }

    // MARK: - File shape, read leniently

    private struct ParsedRecord: Decodable {
        let timeUnixNano: String?
        let severityNumber: Int?
        let body: String?
        let attributes: [ParsedAttribute]

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: FieldKey.self)
            timeUnixNano = (try? container.decode(String.self, forKey: FieldKey("timeUnixNano")))
                ?? (try? container.decode(UInt64.self, forKey: FieldKey("timeUnixNano"))).map(String.init)
            severityNumber = try? container.decode(Int.self, forKey: FieldKey("severityNumber"))
            body = (try? container.decode(ParsedValue.self, forKey: FieldKey("body")))?.text
            attributes = (try? container.decode([ParsedAttribute].self, forKey: FieldKey("attributes"))) ?? []
        }
    }

    /// `{"key":…,"value":{…}}`; `attribute` is nil for any other shape.
    private struct ParsedAttribute: Decodable {
        let attribute: TelemetryAttribute?

        init(from decoder: any Decoder) {
            let container = try? decoder.container(keyedBy: FieldKey.self)
            let key = try? container?.decode(String.self, forKey: FieldKey("key"))
            let value = (try? container?.decode(ParsedValue.self, forKey: FieldKey("value")))?.value
            attribute = key.flatMap { key in value.map { TelemetryAttribute(key: key, value: $0) } }
        }
    }

    /// `{"stringValue":…}`, `{"intValue":"<decimal>"}` (or a number) or `{"boolValue":…}`; `value` is nil otherwise.
    private struct ParsedValue: Decodable {
        let value: AttributeValue?

        var text: String? {
            if case let .string(text) = value {
                return text
            }
            return nil
        }

        init(from decoder: any Decoder) {
            let container = try? decoder.container(keyedBy: FieldKey.self)
            if let text = try? container?.decode(String.self, forKey: FieldKey("stringValue")) {
                value = .string(text)
            } else if let number = try? container?.decode(String.self, forKey: FieldKey("intValue")) {
                value = Int64(number).map(AttributeValue.int)
            } else if let number = try? container?.decode(Int64.self, forKey: FieldKey("intValue")) {
                value = .int(number)
            } else if let flag = try? container?.decode(Bool.self, forKey: FieldKey("boolValue")) {
                value = .bool(flag)
            } else {
                value = nil
            }
        }
    }

    private struct FieldKey: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }

        init(_ name: String) {
            stringValue = name
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            nil
        }
    }
}
