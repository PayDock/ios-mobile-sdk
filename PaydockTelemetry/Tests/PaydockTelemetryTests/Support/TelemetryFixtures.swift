//
//  TelemetryFixtures.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Synthetic events and the endpoint for the core tests. No card data.
enum TelemetryFixtures {
    static let endpoint = "https://otlp.invalid/v1/logs"

    static func info(_ type: String = "Sample.Error", frames: [String] = []) -> TelemetryEvent.ErrorInfo {
        TelemetryEvent.ErrorInfo(type: type, frames: frames)
    }

    static func sdkError(_ type: String = "Sample.Error", frames: [String] = []) -> TelemetryEvent {
        .sdkError(error: info(type, frames: frames), errorCode: "SAMPLE_CODE")
    }

    static func crash(_ type: String = "NSInvalidArgumentException", frames: [String] = []) -> TelemetryEvent {
        .crash(error: info(type, frames: frames), source: .nsException, kind: .exception, inSdk: true,
               crashReason: "NSInvalidArgumentException")
    }

    static func networkFailure(
        method: TelemetryEvent.HTTPMethod = .post,
        urlTemplate: String = "/v1/charges/{id}",
        failure: TelemetryEvent.NetworkError = .httpStatus(code: 503)
    ) -> TelemetryEvent {
        .networkFailure(method: method, urlTemplate: urlTemplate, serverAddress: "api-sandbox.paydock.com", failure: failure)
    }
}
