//
//  RecordingRequestObserver.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// An app's own request observer: keeps every observation it receives.
final class RecordingRequestObserver: RequestObserver, @unchecked Sendable {
    private let lock = NSLock()
    private var received: [RequestObservation] = []

    var observations: [RequestObservation] {
        lock.lock()
        defer { lock.unlock() }
        return received
    }

    func requestDidFinish(_ observation: RequestObservation) {
        lock.lock()
        received.append(observation)
        lock.unlock()
    }
}
