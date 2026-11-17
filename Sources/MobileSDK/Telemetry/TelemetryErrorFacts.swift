//
//  TelemetryErrorFacts.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// What an SDK error tells telemetry, from its own exhaustive switch (no `default`); never its message.
protocol TelemetryErrorFacts: Error {
    /// `paydock.error.code`: `WidgetError.code` for a widget error.
    var telemetryCode: String? { get }
    /// The case's own error value: a wrapped `RequestError`, an `NSError`, another error; nil when it holds none
    /// (an `ErrorRes`, a reason string or a description is never a cause).
    var telemetryCause: (any Error)? { get }
    /// A failed API request caused it: a case holding an `ErrorRes`, or a non-nil `RequestError`.
    var isRequestCaused: Bool { get }
    /// A user cancellation or a provider's outcome (R_05).
    var isOutcome: Bool { get }
}

extension TelemetryErrorFacts where Self: WidgetError {
    var telemetryCode: String? { code }
}
