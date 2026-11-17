//
//  InMemoryStateStore.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Keeps the ranges and the marker in memory and counts every save and clear. `holdLock()` takes its lock on a thread
/// of its own until `releaseLock()`, so a crash marker save gives up after its timeout.
final class InMemoryStateStore: TelemetryStateStore, @unchecked Sendable {
    private let lock = NSLock()
    private let holder = LockHolder()
    private var builds: [FramePoints]
    private var marker: CrashMarker?
    private var framePointSaves = 0
    private var markerSaves = 0
    private var markerClears = 0

    init(builds: [FramePoints] = [], marker: CrashMarker? = nil) {
        self.builds = builds
        self.marker = marker
    }

    var savedBuilds: [FramePoints] { locked { builds } }
    var savedMarker: CrashMarker? { locked { marker } }
    var framePointSaveCount: Int { locked { framePointSaves } }
    var markerSaveCount: Int { locked { markerSaves } }
    var markerClearCount: Int { locked { markerClears } }

    func loadFramePoints() -> [FramePoints] {
        locked { builds }
    }

    func saveFramePoints(_ builds: [FramePoints]) {
        locked {
            self.builds = builds
            framePointSaves += 1
        }
    }

    func loadCrashMarker() -> CrashMarker? {
        locked { marker }
    }

    func saveCrashMarker(_ marker: CrashMarker, timeout: TimeInterval) -> Bool {
        guard lock.lock(before: Date(timeIntervalSinceNow: timeout)) else {
            return false
        }
        defer { lock.unlock() }
        self.marker = marker
        markerSaves += 1
        return true
    }

    func clearCrashMarker() {
        locked {
            marker = nil
            markerClears += 1
        }
    }

    /// Takes the store's lock on another thread and returns once it holds it.
    func holdLock() {
        holder.hold(lock)
    }

    /// Lets the holding thread release the lock, and waits until it has.
    func releaseLock() {
        holder.release()
    }

    private func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
