//
//  FileStateStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// `<directory>/state/frame-points.json` and `<directory>/state/crash-marker.json`, JSON, written atomically
/// (`Data.write(to:options: .atomic)`); `state/` and the telemetry directory created on the first write, the telemetry
/// directory excluded from backup. One NSLock; reads return empty or nil on any error, and an unreadable file is
/// removed. The directory is resolved on first use, like the file store's. The record store ignores `state/`: it reads
/// only the `.json` files at its top level.
package final class FileStateStore: TelemetryStateStore, @unchecked Sendable {
    package static let subdirectory = "state"

    private static let framePointsName = "frame-points.json"
    private static let crashMarkerName = "crash-marker.json"

    private let resolveDirectory: @Sendable () -> URL?
    private let files = FileManager.default
    private let lock = NSLock()
    private var isResolved = false
    private var resolvedDirectory: URL?
    private var isDirectoryReady = false

    /// `directory` (the telemetry directory) is resolved on first use; nothing touches the disk before.
    package init(directory: @escaping @Sendable () -> URL?) {
        resolveDirectory = directory
    }

    package func loadFramePoints() -> [FramePoints] {
        locked { read([FramePoints].self, Self.framePointsName) } ?? []
    }

    package func saveFramePoints(_ builds: [FramePoints]) {
        locked { _ = write(builds, Self.framePointsName) }
    }

    package func loadCrashMarker() -> CrashMarker? {
        locked { read(CrashMarker.self, Self.crashMarkerName) }
    }

    @discardableResult
    package func saveCrashMarker(_ marker: CrashMarker, timeout: TimeInterval) -> Bool {
        guard lock.lock(before: Date(timeIntervalSinceNow: timeout)) else {
            return false
        }
        defer { lock.unlock() }
        return write(marker, Self.crashMarkerName)
    }

    package func clearCrashMarker() {
        locked {
            guard let url = fileURL(Self.crashMarkerName), files.fileExists(atPath: url.path) else {
                return
            }
            try? files.removeItem(at: url)
        }
    }

    // MARK: - Under the lock

    private func directory() -> URL? {
        if !isResolved {
            resolvedDirectory = resolveDirectory()
            isResolved = true
        }
        return resolvedDirectory
    }

    private func stateDirectory() -> URL? {
        directory()?.appendingPathComponent(Self.subdirectory, isDirectory: true)
    }

    private func fileURL(_ name: String) -> URL? {
        stateDirectory()?.appendingPathComponent(name)
    }

    /// The decoded file; nil when it is missing, and nil when it cannot be read or decoded, after removing it.
    private func read<Value: Decodable>(_ type: Value.Type, _ name: String) -> Value? {
        guard let url = fileURL(name), files.fileExists(atPath: url.path) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url), let value = try? JSONDecoder().decode(type, from: data) else {
            try? files.removeItem(at: url)
            return nil
        }
        return value
    }

    private func write<Value: Encodable>(_ value: Value, _ name: String) -> Bool {
        guard let directory = directory(), let state = stateDirectory(), prepare(directory, state) else {
            return false
        }
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: state.appendingPathComponent(name), options: .atomic)
            return true
        } catch {
            return false
        }
    }

    /// Creates `state/` and the telemetry directory when missing, then marks the telemetry directory excluded from
    /// backup, once per instance.
    private func prepare(_ directory: URL, _ state: URL) -> Bool {
        if isDirectoryReady {
            return true
        }
        do {
            if !files.fileExists(atPath: state.path) {
                try files.createDirectory(at: state, withIntermediateDirectories: true)
            }
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            var marked = directory
            try marked.setResourceValues(values)
            isDirectoryReady = true
            return true
        } catch {
            return false
        }
    }

    private func locked<Value>(_ body: () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
#endif
