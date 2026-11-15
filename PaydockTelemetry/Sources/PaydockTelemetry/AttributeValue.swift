//
//  AttributeValue.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One record attribute value.
package enum AttributeValue: Sendable, Equatable {
    case string(String)                      // OTLP stringValue
    case int(Int64)                          // OTLP intValue, written as a decimal string
    case bool(Bool)                          // OTLP boolValue
}
