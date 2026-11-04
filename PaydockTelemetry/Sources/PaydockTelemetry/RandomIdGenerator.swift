//
//  RandomIdGenerator.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// A random UUID, lower-cased. Never a hardware or advertising identifier.
package struct RandomIdGenerator: IdGenerator {
    package init() {}

    package func newId() -> String {
        UUID().uuidString.lowercased()
    }
}
