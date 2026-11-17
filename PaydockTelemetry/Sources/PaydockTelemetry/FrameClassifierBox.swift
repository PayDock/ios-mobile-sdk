//
//  FrameClassifierBox.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The classifier once start has built it; nil before. NSLock.
package final class FrameClassifierBox: @unchecked Sendable {
    private let lock = NSLock()
    private var classifier: FrameClassifier?

    package init() {}

    package var current: FrameClassifier? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return classifier
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            classifier = newValue
        }
    }
}
