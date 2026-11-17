//
//  NoOpAppLifecycle.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Observes nothing: `register` does nothing and `onBackground` is never called.
package struct NoOpAppLifecycle: AppLifecycle {
    package init() {}
    package func register(onBackground: @escaping @Sendable (_ finished: @escaping @Sendable () -> Void) -> Void) {}
}
