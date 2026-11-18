//
//  TelemetryHTTPClient.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Telemetry's own NetworkingLib client: never the SDK's shared session, so never pinned to an app's key (R_03).
/// An ephemeral session that fails at once without connectivity, with the request and resource timeouts at
/// `TelemetryLimits.requestTimeoutSeconds` and no delegate.
package struct TelemetryHTTPClient: HTTPClient {
    package let session: URLSession
    package var sslPinningManager: SSLPinningManager? { nil }

    package init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        configuration.timeoutIntervalForRequest = TelemetryLimits.requestTimeoutSeconds
        configuration.timeoutIntervalForResource = TelemetryLimits.requestTimeoutSeconds
        session = URLSession(configuration: configuration)
    }
}
