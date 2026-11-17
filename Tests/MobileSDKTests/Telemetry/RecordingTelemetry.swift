//
//  RecordingTelemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PaydockTelemetry

/// A facade that records every event and the report site it came with (nil through `report(_:)`), active or not.
/// Thread-safe.
final class RecordingTelemetry: Telemetry, @unchecked Sendable {
    struct Report: Equatable {
        let event: TelemetryEvent
        let site: ReportSite?
    }

    let isActive: Bool
    private let lock = NSLock()
    private var log: [Report] = []

    init(isActive: Bool = true) {
        self.isActive = isActive
    }

    var reports: [Report] { lock.withLock { log } }
    var events: [TelemetryEvent] { reports.map(\.event) }

    func report(_ event: TelemetryEvent) {
        lock.withLock { log.append(Report(event: event, site: nil)) }
    }

    func report(_ event: TelemetryEvent, site: ReportSite) {
        lock.withLock { log.append(Report(event: event, site: site)) }
    }
}
