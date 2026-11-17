//
//  NoOpTelemetryStateStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Keeps nothing: loads nothing, saves nothing, and a crash marker save returns false.
package struct NoOpTelemetryStateStore: TelemetryStateStore {
    package init() {}
    package func loadFramePoints() -> [FramePoints] { [] }
    package func saveFramePoints(_ builds: [FramePoints]) {}
    package func loadCrashMarker() -> CrashMarker? { nil }
    @discardableResult package func saveCrashMarker(_ marker: CrashMarker, timeout: TimeInterval) -> Bool { false }
    package func clearCrashMarker() {}
}
