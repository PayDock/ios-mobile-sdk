//
//  TelemetryTransport.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Posts one payload to the gateway.
package protocol TelemetryTransport: Sendable {
    /// Blocking; on the telemetry queue only; never throws.
    func send(_ payload: Data, headers: [String: String]) -> TransportResult
}
