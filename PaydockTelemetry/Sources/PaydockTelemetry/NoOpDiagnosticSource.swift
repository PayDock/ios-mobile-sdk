//
//  NoOpDiagnosticSource.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Subscribes to nothing and never delivers.
package struct NoOpDiagnosticSource: DiagnosticSource {
    package init() {}
    package func start(deliver: @escaping @Sendable ([MetricKitDiagnostic]) -> Void) {}
}
