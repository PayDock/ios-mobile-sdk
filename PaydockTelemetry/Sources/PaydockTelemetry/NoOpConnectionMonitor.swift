//
//  NoOpConnectionMonitor.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Registers nothing: `start` does nothing and `current` is always `.unknown`.
package struct NoOpConnectionMonitor: ConnectionMonitor {
    package init() {}
    package func start() {}
    package func current() -> NetworkConnectionType { .unknown }
}
