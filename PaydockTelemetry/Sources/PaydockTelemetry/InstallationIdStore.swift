//
//  InstallationIdStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The random installation ID: created once per install, kept across launches (MD-13). Never a hardware or
/// advertising identifier (principle 10).
package struct InstallationIdStore: Sendable {
    package static let key = "paydock_telemetry_installation_id"

    private let store: any KeyValueStore
    private let idGenerator: any IdGenerator

    package init(store: any KeyValueStore, idGenerator: any IdGenerator) {
        self.store = store
        self.idGenerator = idGenerator
    }

    /// Reads; writes a new random ID only when none exists.
    package func getOrCreate() -> String {
        if let existing = store.string(forKey: Self.key) {
            return existing
        }
        let created = idGenerator.newId()
        store.set(created, forKey: Self.key)
        return created
    }
}
