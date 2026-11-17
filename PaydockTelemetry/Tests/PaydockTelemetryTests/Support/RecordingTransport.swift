//
//  RecordingTransport.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Records every send, with the thread it ran on, and answers with its scripted results in order, then `fallback`.
final class RecordingTransport: TelemetryTransport, @unchecked Sendable {
    struct Call {
        let payload: Data
        let headers: [String: String]
        let isMainThread: Bool
        let queueLabel: String
    }

    private let lock = NSLock()
    private var script: [TransportResult]
    private let fallback: TransportResult
    private var callLog: [Call] = []

    init(_ script: [TransportResult] = [], fallback: TransportResult = .success(status: 204, rejectedRecords: 0)) {
        self.script = script
        self.fallback = fallback
    }

    var calls: [Call] {
        lock.lock()
        defer { lock.unlock() }
        return callLog
    }

    func send(_ payload: Data, headers: [String: String]) -> TransportResult {
        let label = String(cString: __dispatch_queue_get_label(nil))
        lock.lock()
        defer { lock.unlock() }
        callLog.append(Call(payload: payload, headers: headers, isMainThread: Thread.isMainThread, queueLabel: label))
        return script.isEmpty ? fallback : script.removeFirst()
    }
}
