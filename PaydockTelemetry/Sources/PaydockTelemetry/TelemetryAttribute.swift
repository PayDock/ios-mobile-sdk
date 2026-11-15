//
//  TelemetryAttribute.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One record attribute: an allowlisted key and its typed value.
package struct TelemetryAttribute: Sendable, Equatable {
    package let key: String
    package let value: AttributeValue

    package init(key: String, value: AttributeValue) {
        self.key = key
        self.value = value
    }
}
