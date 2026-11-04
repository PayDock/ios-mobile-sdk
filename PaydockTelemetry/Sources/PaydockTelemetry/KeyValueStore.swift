//
//  KeyValueStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// A small string store. Injected so tests use an in-memory one.
package protocol KeyValueStore: Sendable {
    func string(forKey key: String) -> String?
    func set(_ value: String, forKey key: String)
}
