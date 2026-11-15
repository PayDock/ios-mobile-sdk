//
//  OtlpLogEncoder.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// OTLP/HTTP JSON logs (spec § 5), as generate.py `encode` writes them.
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
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return (try? encoder.encode(request)) ?? Data()
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
