//
//  PathConnectionMonitor.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if canImport(Network)
import Foundation
import Network

/// The connection type from an `NWPathMonitor` on its own serial queue: unsatisfied → `.none`, Wi-Fi → `.wifi`,
/// cellular → `.cell`, anything else `.unknown`. The monitor is created and started by `start()` only, once; until its
/// first update the type is `.unknown`.
package final class PathConnectionMonitor: ConnectionMonitor, @unchecked Sendable {
    package static let queueLabel = "com.paydock.telemetry.path"

    private let lock = NSLock()
    private var monitor: NWPathMonitor?
    private var type: NetworkConnectionType = .unknown

    package init() {}

    /// A released monitor stops its `NWPathMonitor`, which otherwise keeps running.
    deinit {
        monitor?.cancel()
    }

    package func start() {
        lock.lock()
        guard monitor == nil else {
            lock.unlock()
            return
        }
        let created = NWPathMonitor()
        monitor = created
        lock.unlock()
        created.pathUpdateHandler = { [weak self] path in
            self?.update(Self.connectionType(of: path))
        }
        created.start(queue: DispatchQueue(label: Self.queueLabel))
    }

    package func current() -> NetworkConnectionType {
        lock.lock()
        defer { lock.unlock() }
        return type
    }

    private func update(_ newType: NetworkConnectionType) {
        lock.lock()
        type = newType
        lock.unlock()
    }

    private static func connectionType(of path: NWPath) -> NetworkConnectionType {
        guard path.status == .satisfied else {
            return .none
        }
        if path.usesInterfaceType(.wifi) {
            return .wifi
        }
        if path.usesInterfaceType(.cellular) {
            return .cell
        }
        return .unknown
    }
}
#endif
