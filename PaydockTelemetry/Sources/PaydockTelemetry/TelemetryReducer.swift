//
//  TelemetryReducer.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Pure: no I/O, no clock, no randomness. Same inputs, same outputs.
package enum TelemetryReducer {
    package static let flushIntervalMilliseconds: Int64 = 10_000
    package static let flushThreshold = 20
    package static let maxBatch = 50
    package static let collapseWindowMilliseconds: Int64 = 60_000
    /// Module names that mark a frame as Paydock code.
    package static let paydockModules = ["MobileSDK", "PaydockTelemetry", "BinProcessing", "CommonModels",
        "DataCharges", "DataCustomer", "DataGateways", "DataMPGS3ds", "DataPaymentSources", "DataStandalone3ds", "DataVault"]

    package static func reduce(_ state: TelemetryState, _ intent: TelemetryIntent, now: Int64)
        -> (state: TelemetryState, effects: [TelemetryEffect]) {
        switch intent {
        case let .reported(event):
            return reported(event, state, now: now)
        case .flush:
            return flush(state, now: now)
        case .appBackgrounded:
            return appBackgrounded(state, now: now)
        case let .levelChanged(level):
            var next = state
            next.level = level
            return (next, [])
        }
    }

    /// `"<name>|<exceptionType>|<topPaydockFrame>"`; a network failure appends `"|<method>|<urlTemplate>|<failure>"`.
    package static func fingerprint(_ event: TelemetryEvent) -> String {
        switch event {
        case let .crash(error, _, _, _):
            return key("paydock.crash", error)
        case let .uncaughtException(error, _, _), let .sdkError(error, _, _):
            return key("paydock.error", error)
        case let .networkFailure(method, urlTemplate, _, failure, _, _, _):
            let base = key("paydock.network.failure", failureError(failure))
            return "\(base)|\(methodName(method))|\(urlTemplate)|\(failureName(failure))"
        }
    }

    /// True for all four kinds today.
    package static func isError(_ event: TelemetryEvent) -> Bool {
        switch event {
        case .crash, .uncaughtException, .sdkError, .networkFailure:
            return true
        }
    }

    // MARK: - Intents

    private static func reported(_ event: TelemetryEvent, _ state: TelemetryState, now: Int64)
        -> (state: TelemetryState, effects: [TelemetryEffect]) {
        guard state.enabled else {
            return (state, [.drop(.disabled)])
        }
        if state.level == .off {
            return (state, [.drop(.levelOff)])
        }
        if state.level == .errors && !isError(event) {
            return (state, [.drop(.levelFiltered)])
        }

        var next = state
        var effects: [TelemetryEffect] = []
        let record = PendingRecord(id: "\(next.sessionId)-\(next.nextSequence)", sessionId: next.sessionId, event: event,
                                   firstSeenAt: now)
        next.nextSequence += 1

        if case .crash = event {
            effects += [.persist(record), .enqueue(record)]
            next.persisted += 1
            next.queued += 1
        } else {
            let fingerprintKey = fingerprint(event)
            if var held = next.collapsing[fingerprintKey], now - held.firstSeenAt < collapseWindowMilliseconds {
                held.occurrences += 1
                next.collapsing[fingerprintKey] = held
            } else {
                effects += release(fingerprintKey, from: &next)
                next.collapsing[fingerprintKey] = record
                effects.append(.persist(record))
                next.persisted += 1
            }
        }

        if next.queued >= flushThreshold {
            effects.append(.export(maxRecords: maxBatch))
            next.queued -= min(next.queued, maxBatch)
            next.lastExport = now
        }
        effects += reschedule(&next)
        return (next, effects)
    }

    private static func flush(_ state: TelemetryState, now: Int64) -> (state: TelemetryState, effects: [TelemetryEffect]) {
        var next = state
        next.flushScheduled = false
        var effects: [TelemetryEffect] = []
        for fingerprintKey in next.collapsing.keys.sorted() {
            if let held = next.collapsing[fingerprintKey], now - held.firstSeenAt >= collapseWindowMilliseconds {
                effects += release(fingerprintKey, from: &next)
            }
        }
        effects += exportAll(&next, now: now)
        effects += reschedule(&next)
        return (next, effects)
    }

    private static func appBackgrounded(_ state: TelemetryState, now: Int64)
        -> (state: TelemetryState, effects: [TelemetryEffect]) {
        var next = state
        var effects: [TelemetryEffect] = []
        for fingerprintKey in next.collapsing.keys.sorted() {
            effects += release(fingerprintKey, from: &next)
        }
        effects += exportAll(&next, now: now)
        return (next, effects)
    }

    // MARK: - Rules

    /// Rule R: removes the held record for `fingerprintKey`, enqueues it, and persists it again when it collapsed others.
    private static func release(_ fingerprintKey: String, from state: inout TelemetryState) -> [TelemetryEffect] {
        guard let held = state.collapsing.removeValue(forKey: fingerprintKey) else {
            return []
        }
        state.queued += 1
        return held.occurrences > 1 ? [.enqueue(held), .persist(held)] : [.enqueue(held)]
    }

    /// Exports in batches of `maxBatch` while anything is queued.
    private static func exportAll(_ state: inout TelemetryState, now: Int64) -> [TelemetryEffect] {
        var effects: [TelemetryEffect] = []
        while state.queued > 0 {
            effects.append(.export(maxRecords: maxBatch))
            state.queued -= min(state.queued, maxBatch)
        }
        if !effects.isEmpty {
            state.lastExport = now
        }
        return effects
    }

    private static func reschedule(_ state: inout TelemetryState) -> [TelemetryEffect] {
        guard (state.queued > 0 || !state.collapsing.isEmpty) && !state.flushScheduled else {
            return []
        }
        state.flushScheduled = true
        return [.scheduleFlush(delayMilliseconds: flushIntervalMilliseconds)]
    }

    // MARK: - Fingerprint parts

    private static func key(_ name: String, _ error: TelemetryEvent.ErrorInfo?) -> String {
        "\(name)|\(error?.type ?? "")|\(topPaydockFrame(error?.frames ?? []))"
    }

    private static func failureError(_ failure: TelemetryEvent.NetworkError) -> TelemetryEvent.ErrorInfo? {
        switch failure {
        case .httpStatus:
            return nil
        case let .transport(_, error), let .decode(_, error):
            return error
        }
    }

    private static func failureName(_ failure: TelemetryEvent.NetworkError) -> String {
        switch failure {
        case let .httpStatus(code):
            return "http_\(code)"
        case let .transport(kind, _):
            return "transport_\(kindName(kind))"
        case .decode:
            return "decode"
        }
    }

    private static func kindName(_ kind: TelemetryEvent.TransportKind) -> String {
        switch kind {
        case .timeout: return "timeout"
        case .connection: return "connection"
        case .tls: return "tls"
        case .unknown: return "unknown"
        }
    }

    private static func methodName(_ method: TelemetryEvent.HTTPMethod) -> String {
        switch method {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        case .head: return "HEAD"
        case .options: return "OPTIONS"
        }
    }

    /// The first frame that holds a Paydock module name as a whole word, or `""`.
    private static func topPaydockFrame(_ frames: [String]) -> String {
        frames.first { frame in paydockModules.contains { containsWord($0, in: frame) } } ?? ""
    }

    private static func containsWord(_ word: String, in text: String) -> Bool {
        var searchStart = text.startIndex
        while let range = text.range(of: word, range: searchStart..<text.endIndex) {
            let before = range.lowerBound == text.startIndex ? nil : text[text.index(before: range.lowerBound)]
            let after = range.upperBound == text.endIndex ? nil : text[range.upperBound]
            if !isWordCharacter(before) && !isWordCharacter(after) {
                return true
            }
            searchStart = text.index(after: range.lowerBound)
        }
        return false
    }

    private static func isWordCharacter(_ character: Character?) -> Bool {
        guard let character else {
            return false
        }
        return character.isLetter || character.isNumber || character == "_"
    }
}
