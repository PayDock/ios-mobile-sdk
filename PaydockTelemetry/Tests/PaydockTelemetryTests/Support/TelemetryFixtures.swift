//
//  TelemetryFixtures.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Synthetic events and credentials for the core tests. No card data, no real credential.
enum TelemetryFixtures {
    static let credentials = TelemetryCredentials(endpoint: "https://otlp.invalid/v1/logs", authorization: "synthetic-not-a-credential")

    static func info(_ type: String = "Sample.Error", frames: [String] = []) -> TelemetryEvent.ErrorInfo {
        TelemetryEvent.ErrorInfo(type: type, frames: frames)
    }

    static func sdkError(_ type: String = "Sample.Error", frames: [String] = []) -> TelemetryEvent {
        .sdkError(error: info(type, frames: frames), errorCode: "SAMPLE_CODE")
    }

    static func crash(_ type: String = "NSException", frames: [String] = []) -> TelemetryEvent {
        .crash(error: info(type, frames: frames), source: .nsException, crashReason: "NSInvalidArgumentException")
    }

    static func networkFailure(
        method: TelemetryEvent.HTTPMethod = .post,
        urlTemplate: String = "/v1/charges/{id}",
        failure: TelemetryEvent.NetworkError = .httpStatus(code: 503)
    ) -> TelemetryEvent {
        .networkFailure(method: method, urlTemplate: urlTemplate, serverAddress: "api-sandbox.paydock.com", failure: failure)
    }
}
