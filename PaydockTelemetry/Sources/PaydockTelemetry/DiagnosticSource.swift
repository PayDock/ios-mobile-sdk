//
//  DiagnosticSource.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Delivers the crash and hang diagnostics the OS reports for earlier launches (R_09).
package protocol DiagnosticSource: Sendable {
    /// Called once, by the active runtime's start; `deliver` may be called on any thread.
    func start(deliver: @escaping @Sendable ([MetricKitDiagnostic]) -> Void)
}
