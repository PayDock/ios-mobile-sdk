//
//  NetworkFailureObserver.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import NetworkingLib

/// R_01, R_09: forwards to `previous` first, then reports `NetworkFailureFacts.event(observation,
/// excludedHost: excludedHost)` through `report` when non-nil. Never blocks.
package final class NetworkFailureObserver: RequestObserver, @unchecked Sendable {
    private let report: @Sendable (TelemetryEvent) -> Void
    private let excludedHost: String?
    private let previous: (any RequestObserver)?

    package init(report: @escaping @Sendable (TelemetryEvent) -> Void, excludedHost: String?,
                 previous: (any RequestObserver)?) {
        self.report = report
        self.excludedHost = excludedHost
        self.previous = previous
    }

    package func requestDidFinish(_ observation: RequestObservation) {
        previous?.requestDidFinish(observation)
        if let event = NetworkFailureFacts.event(observation, excludedHost: excludedHost) {
            report(event)
        }
    }
}
