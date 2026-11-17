//
//  TelemetryStateStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The classifier's saved ranges and the crash marker (R_15, R_07), kept apart from the records.
package protocol TelemetryStateStore: Sendable {
    func loadFramePoints() -> [FramePoints]          // [] when missing or unreadable
    func saveFramePoints(_ builds: [FramePoints])
    func loadCrashMarker() -> CrashMarker?
    /// The crash path: waits at most `timeout` seconds for the store's lock; false when it gave up or failed.
    @discardableResult func saveCrashMarker(_ marker: CrashMarker, timeout: TimeInterval) -> Bool
    func clearCrashMarker()
}
