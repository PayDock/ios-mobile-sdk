//
//  Telemetry.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The only telemetry surface SDK code sees. Thread-safe, never throws, returns immediately.
package protocol Telemetry: Sendable {
    var isActive: Bool { get }
    func report(_ event: TelemetryEvent)
    /// An SDK error or an uncaught error with its report site; the runtime describes and classifies the site's
    /// addresses on its queue (R_03). Any other event is reported as by `report(_:)`.
    func report(_ event: TelemetryEvent, site: ReportSite)
}

extension Telemetry {
    /// Test doubles and the no-op: the site is ignored.
    package func report(_ event: TelemetryEvent, site: ReportSite) { report(event) }
}
