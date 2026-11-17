//
//  UIKitAppLifecycle.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG && canImport(UIKit)
import Foundation
import UIKit

/// Observes `UIApplication.didEnterBackgroundNotification`. On each, begins a background task named
/// `com.paydock.telemetry.flush` with an expiration handler, then calls `onBackground(finished)`; `finished` and the
/// expiration both end the task, once. Nothing is observed before `register`.
package final class UIKitAppLifecycle: AppLifecycle, @unchecked Sendable {
    package static let taskName = "com.paydock.telemetry.flush"

    /// Ends one background task the first time it is asked to.
    private final class TaskEnder: @unchecked Sendable {
        private let lock = NSLock()
        private var identifier: UIBackgroundTaskIdentifier = .invalid
        private var ended = false

        func begun(_ identifier: UIBackgroundTaskIdentifier) {
            lock.lock()
            let alreadyEnded = ended
            if !alreadyEnded {
                self.identifier = identifier
            }
            lock.unlock()
            if alreadyEnded {
                UIKitAppLifecycle.endTask(identifier)
            }
        }

        func end() {
            lock.lock()
            let wasEnded = ended
            let toEnd = identifier
            ended = true
            identifier = .invalid
            lock.unlock()
            if !wasEnded, toEnd != .invalid {
                UIKitAppLifecycle.endTask(toEnd)
            }
        }
    }

    private let lock = NSLock()
    private var observer: NSObjectProtocol?

    package init() {}

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    package func register(onBackground: @escaping @Sendable (_ finished: @escaping @Sendable () -> Void) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        guard observer == nil else {
            return
        }
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            let ender = TaskEnder()
            let identifier = UIApplication.shared.beginBackgroundTask(withName: Self.taskName) { ender.end() }
            ender.begun(identifier)
            onBackground { ender.end() }
        }
    }

    /// Ends the task at once, on the calling thread: inside the expiration handler, as the system requires, or on the
    /// telemetry queue after the flush. `endBackgroundTask` may be called from any thread.
    private static func endTask(_ identifier: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(identifier)
    }
}
#endif
