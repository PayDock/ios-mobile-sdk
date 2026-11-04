//
//  ResourceAttributeValue.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One resource attribute value.
package enum ResourceAttributeValue: Sendable, Equatable {
    case string(String), int(Int), bool(Bool)
}
