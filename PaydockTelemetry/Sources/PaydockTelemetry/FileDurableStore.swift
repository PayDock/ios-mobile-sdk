//
//  FileDurableStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// The disk is the queue (R_05, R_06): one `<id>.json` file per record, holding `OtlpLogEncoder.recordJSON`, in a
/// directory created on the first save and excluded from backup. An in-memory index (id → time, byte count, is-notice)
/// is built once from the directory on first use, then kept by every save and remove; count, ordering and the cap and
/// age checks read it. Byte counts come from the data written or read, never from file attributes, and times from the
/// records. Every method runs under one `NSLock`: a crash handler will write from the crashing thread.
package final class FileDurableStore: DurableStore, @unchecked Sendable {
    package static let directoryName = "paydock_telemetry"

    private static let fileSuffix = ".json"
    private static let temporarySuffix = ".json.tmp"
    private static let noticeName = "paydock.telemetry.dropped"

    private struct Entry {
        let time: Int64
        let bytes: Int
        let isNotice: Bool
    }

    private let resolveDirectory: @Sendable () -> URL?
    private let files = FileManager.default
    private let lock = NSLock()
    private var isResolved = false
    private var resolvedDirectory: URL?
    private var isDirectoryReady = false
    private var index: [String: Entry]?

    /// `<Application Support>/paydock_telemetry`, or nil when the system gives no application-support URL.
    package static func defaultDirectory() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent(directoryName, isDirectory: true)
    }

    /// `directory` is resolved on first use, on the telemetry queue; nothing touches the disk before.
    package init(directory: @escaping @Sendable () -> URL?) {
        resolveDirectory = directory
    }

    package func save(_ record: TelemetryRecord) {
        locked { write(record) }
    }

    /// The crash path: waits at most `timeout` seconds for the lock (`NSLock.lock(before:)`), then writes the record's
    /// file; false when it gave up or the write failed. Never prunes, and never reads the directory: an index not yet
    /// built is left to be built from the files, this one included.
    @discardableResult
    package func saveCrash(_ record: TelemetryRecord, timeout: TimeInterval) -> Bool {
        guard lock.lock(before: Date(timeIntervalSinceNow: timeout)) else {
            return false
        }
        defer { lock.unlock() }
        return writeFile(record)
    }

    package func oldest(max: Int) -> [TelemetryRecord] {
        locked { read(max: max) }
    }

    package func remove(ids: [String]) {
        locked { delete(ids) }
    }

    /// Deletes leftover temporary files, removes records older than the age limit, merges duplicates when the store is
    /// over a cap, then removes the oldest records until it is within both: every other record before any notice.
    package func prune(now: Int64) -> PruneResult {
        locked {
            var result = PruneResult()
            sweepTemporaryFiles()
            for id in orderedIds() {
                guard let entry = loadIndex()[id], now - entry.time > TelemetryLimits.recordMaxAgeMilliseconds else {
                    continue
                }
                delete([id])
                result.tooOld += entry.isNotice ? 0 : 1
            }
            guard isOverCap() else {
                return result
            }
            mergeDuplicates()
            let ordered = orderedIds()
            let current = loadIndex()
            let victims = ordered.filter { current[$0]?.isNotice == false } + ordered.filter { current[$0]?.isNotice == true }
            for id in victims where isOverCap() {
                delete([id])
                result.storeFull += current[id]?.isNotice == true ? 0 : 1
            }
            return result
        }
    }

    package func count() -> Int {
        locked { loadIndex().count }
    }

    // MARK: - Under the lock

    private func directory() -> URL? {
        if !isResolved {
            resolvedDirectory = resolveDirectory()
            isResolved = true
        }
        return resolvedDirectory
    }

    /// The index, built from the directory on first use; a missing directory gives an empty index and creates nothing.
    /// A file that does not parse, or whose name is not its record's, is deleted and skipped. A file that cannot be
    /// read (an I/O or data-protection error, as before the device's first unlock) is skipped and kept for a later run.
    private func loadIndex() -> [String: Entry] {
        if let index {
            return index
        }
        var built: [String: Entry] = [:]
        if let directory = directory(), files.fileExists(atPath: directory.path) {
            for url in listing(directory) where url.lastPathComponent.hasSuffix(Self.fileSuffix) {
                guard let data = try? Data(contentsOf: url) else {
                    continue
                }
                guard let record = OtlpLogEncoder.parseRecord(data), url.lastPathComponent == Self.fileName(record.id) else {
                    try? files.removeItem(at: url)
                    continue
                }
                built[record.id] = Self.entry(record, bytes: data.count)
            }
        }
        index = built
        return built
    }

    private func write(_ record: TelemetryRecord) {
        _ = loadIndex()
        writeFile(record)
    }

    /// Writes `<id>.json.tmp`, then replaces `<id>.json` with it; keeps the index when it is built.
    @discardableResult
    private func writeFile(_ record: TelemetryRecord) -> Bool {
        guard Self.isFileName(record.id), let directory = directory(), prepare(directory) else {
            return false
        }
        let data = OtlpLogEncoder.recordJSON(record)
        let target = directory.appendingPathComponent(Self.fileName(record.id))
        let temporary = directory.appendingPathComponent(record.id + Self.temporarySuffix)
        do {
            try data.write(to: temporary)
            if files.fileExists(atPath: target.path) {
                _ = try files.replaceItemAt(target, withItemAt: temporary)
            } else {
                try files.moveItem(at: temporary, to: target)
            }
            index?[record.id] = Self.entry(record, bytes: data.count)
            return true
        } catch {
            try? files.removeItem(at: temporary)
            return false
        }
    }

    /// Up to `max` records, oldest first; a file that no longer parses is deleted and skipped, and a file that cannot
    /// be read is skipped and kept: the next read tries it again, and the age limit removes it in the end.
    private func read(max: Int) -> [TelemetryRecord] {
        var records: [TelemetryRecord] = []
        guard max > 0, let directory = directory() else {
            return records
        }
        for id in orderedIds() {
            let url = directory.appendingPathComponent(Self.fileName(id))
            guard let data = try? Data(contentsOf: url) else {
                continue
            }
            if let record = OtlpLogEncoder.parseRecord(data), record.id == id {
                records.append(record)
            } else {
                try? files.removeItem(at: url)
                index?[id] = nil
            }
            if records.count >= max {
                break
            }
        }
        return records
    }

    private func delete(_ ids: [String]) {
        var current = loadIndex()
        guard let directory = directory() else {
            return
        }
        for id in ids where Self.isFileName(id) {
            current[id] = nil
            try? files.removeItem(at: directory.appendingPathComponent(Self.fileName(id)))
        }
        index = current
    }

    /// Saves each merged record under its kept id first, then removes its other sources.
    private func mergeDuplicates() {
        for merged in DuplicateGate.merge(read(max: Int.max)) where merged.sourceIds.count > 1 {
            write(merged.record)
            delete(merged.sourceIds.filter { $0 != merged.record.id })
        }
    }

    /// Creates the directory when it is missing, then marks it excluded from backup, once per instance.
    private func prepare(_ directory: URL) -> Bool {
        if isDirectoryReady {
            return true
        }
        do {
            if !files.fileExists(atPath: directory.path) {
                try files.createDirectory(at: directory, withIntermediateDirectories: true)
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

    private func sweepTemporaryFiles() {
        guard let directory = directory(), files.fileExists(atPath: directory.path) else {
            return
        }
        for url in listing(directory) where url.lastPathComponent.hasSuffix(Self.temporarySuffix) {
            try? files.removeItem(at: url)
        }
    }

    private func listing(_ directory: URL) -> [URL] {
        (try? files.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])) ?? []
    }

    private func isOverCap() -> Bool {
        let current = loadIndex()
        return current.count > TelemetryLimits.storeMaxRecords
            || current.values.reduce(0) { $0 + $1.bytes } > TelemetryLimits.storeMaxBytes
    }

    /// By time, then the id's sequence as a number, then the id.
    private func orderedIds() -> [String] {
        loadIndex().sorted { lhs, rhs in
            if lhs.value.time != rhs.value.time {
                return lhs.value.time < rhs.value.time
            }
            let lhsSequence = Self.sequence(of: lhs.key)
            let rhsSequence = Self.sequence(of: rhs.key)
            return lhsSequence != rhsSequence ? lhsSequence < rhsSequence : lhs.key < rhs.key
        }.map(\.key)
    }

    private func locked<Value>(_ body: () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    // MARK: - Names and entries

    private static func entry(_ record: TelemetryRecord, bytes: Int) -> Entry {
        Entry(time: record.timeUnixMillis, bytes: bytes, isNotice: record.eventName == noticeName)
    }

    private static func fileName(_ id: String) -> String {
        id + fileSuffix
    }

    /// A record id is used as a file name only when it holds nothing but ASCII letters, digits, `-` and `_`.
    private static func isFileName(_ id: String) -> Bool {
        !id.isEmpty && id.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") }
    }

    /// The number after the id's last `-`; an id without one sorts last.
    private static func sequence(of id: String) -> Int64 {
        id.split(separator: "-").last.flatMap { Int64($0) } ?? Int64.max
    }
}
#endif
