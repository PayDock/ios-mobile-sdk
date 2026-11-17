//
//  RecordingCrashRecorder.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Records the name of every exception it is given, then runs the test's action, if any (to re-enter the chain, or
/// to stand for a recorder that saves nothing).
final class RecordingCrashRecorder: CrashRecording, @unchecked Sendable {
    private let lock = NSLock()
    private let action: (@Sendable (NSException) -> Void)?
    private var names: [String] = []

    init(action: (@Sendable (NSException) -> Void)? = nil) {
        self.action = action
    }

    var recorded: [String] {
        lock.lock()
        defer { lock.unlock() }
        return names
    }

    func record(_ exception: NSException) {
        lock.lock()
        names.append(exception.name.rawValue)
        lock.unlock()
        action?(exception)
    }
}
