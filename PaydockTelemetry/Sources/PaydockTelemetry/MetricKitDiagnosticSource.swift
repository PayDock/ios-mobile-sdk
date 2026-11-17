//
//  MetricKitDiagnosticSource.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG && os(iOS) && canImport(MetricKit)
import Foundation
import MetricKit

/// An NSObject MXMetricManagerSubscriber added to MXMetricManager.shared once per process (a static flag under a
/// lock); didReceive(_: [MXDiagnosticPayload]) → MetricKitPayload.diagnostics(json: jsonRepresentation(), timeEnd:
/// ms of timeStampEnd) → deliver. Metric payloads ignored. Never removes a subscriber.
package final class MetricKitDiagnosticSource: NSObject, DiagnosticSource, MXMetricManagerSubscriber, @unchecked Sendable {
    /// The process's one subscription.
    private final class Subscription: @unchecked Sendable {
        private let lock = NSLock()
        private var added = false

        /// True only the first time it is called in the process.
        func claim() -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard !added else {
                return false
            }
            added = true
            return true
        }
    }

    private static let subscription = Subscription()

    private let lock = NSLock()
    private var deliver: (@Sendable ([MetricKitDiagnostic]) -> Void)?

    package override init() {
        super.init()
    }

    package func start(deliver: @escaping @Sendable ([MetricKitDiagnostic]) -> Void) {
        lock.lock()
        self.deliver = deliver
        lock.unlock()
        guard Self.subscription.claim() else {
            return
        }
        MXMetricManager.shared.add(self)
    }

    package func didReceive(_ payloads: [MXDiagnosticPayload]) {
        lock.lock()
        let deliver = self.deliver
        lock.unlock()
        guard let deliver else {
            return
        }
        let diagnostics = payloads.flatMap { payload in
            MetricKitPayload.diagnostics(json: payload.jsonRepresentation(),
                                         timeEnd: Int64((payload.timeStampEnd.timeIntervalSince1970 * 1_000).rounded()))
        }
        deliver(diagnostics)
    }
}
#endif
