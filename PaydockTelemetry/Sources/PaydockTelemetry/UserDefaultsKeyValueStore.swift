//
//  UserDefaultsKeyValueStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The key-value store backed by `UserDefaults`, the only file allowed to use it (D16).
package struct UserDefaultsKeyValueStore: KeyValueStore, @unchecked Sendable {
    private let defaults: UserDefaults

    package init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    package func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    package func set(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
