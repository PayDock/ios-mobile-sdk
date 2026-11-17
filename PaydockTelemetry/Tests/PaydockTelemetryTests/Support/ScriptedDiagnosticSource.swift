//
//  ScriptedDiagnosticSource.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Counts its starts, runs the test's action on each (to see what start had done by then), and delivers the
/// diagnostics a test emits, as MetricKit would on a later launch.
final class ScriptedDiagnosticSource: DiagnosticSource, @unchecked Sendable {
    private let lock = NSLock()
    private let onStart: (@Sendable () -> Void)?
    private var deliver: (@Sendable ([MetricKitDiagnostic]) -> Void)?
    private var starts = 0

    init(onStart: (@Sendable () -> Void)? = nil) {
        self.onStart = onStart
    }

    var startCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return starts
    }

    func start(deliver: @escaping @Sendable ([MetricKitDiagnostic]) -> Void) {
        lock.lock()
        starts += 1
        self.deliver = deliver
        lock.unlock()
        onStart?()
    }

    /// Delivers the diagnostics on the calling thread, outside the lock; false when the source was never started.
    @discardableResult
    func emit(_ diagnostics: [MetricKitDiagnostic]) -> Bool {
        lock.lock()
        let deliver = self.deliver
        lock.unlock()
        guard let deliver else {
            return false
        }
        deliver(diagnostics)
        return true
    }
}
