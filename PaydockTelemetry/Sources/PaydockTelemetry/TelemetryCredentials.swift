//
//  TelemetryCredentials.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Where telemetry is sent and the authorization header value. Never prints or reflects the authorization.
package struct TelemetryCredentials: Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible,
    CustomReflectable {
    package let endpoint: String
    package let authorization: String

    package init(endpoint: String, authorization: String) {
        self.endpoint = endpoint
        self.authorization = authorization
    }

    package var description: String { "TelemetryCredentials(endpoint: \(endpoint), authorization: <redacted>)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: ["endpoint": endpoint, "authorization": "<redacted>"]) }
}
