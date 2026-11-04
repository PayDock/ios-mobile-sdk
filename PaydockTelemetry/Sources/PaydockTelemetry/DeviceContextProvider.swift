//
//  DeviceContextProvider.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The device context attached to every export (R_12).
package protocol DeviceContextProvider: Sendable {
    /// Built once per process, then cached.
    func current() -> ResourceAttributes
}
