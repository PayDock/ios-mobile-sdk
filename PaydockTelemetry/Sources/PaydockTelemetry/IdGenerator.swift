//
//  IdGenerator.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Makes new random identifiers. Injected so tests can use a sequence.
package protocol IdGenerator: Sendable {
    func newId() -> String
}
