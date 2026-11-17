//
//  ReportSite.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Where SDK code reported an error: the calling thread's return addresses, captured there and described on the
/// telemetry queue (spec § 5.5, § 7.2).
package struct ReportSite: Sendable, Equatable {
    package let returnAddresses: [UInt]     // innermost first, at most TelemetryEvent.ErrorInfo.maxFrames
    package let threadName: String?         // "main" on the main thread, else the thread's name when not empty, else nil

    package init(returnAddresses: [UInt], threadName: String?) {
        self.returnAddresses = Array(returnAddresses.prefix(TelemetryEvent.ErrorInfo.maxFrames))
        self.threadName = threadName
    }

    /// `Thread.callStackReturnAddresses` of the calling thread, at most 64, and its name. No other work.
    package static func capture() -> ReportSite {
        let addresses = Thread.callStackReturnAddresses.prefix(TelemetryEvent.ErrorInfo.maxFrames).map(\.uintValue)
        return ReportSite(returnAddresses: addresses, threadName: currentThreadName())
    }

    private static func currentThreadName() -> String? {
        if Thread.isMainThread {
            return "main"
        }
        guard let name = Thread.current.name, !name.isEmpty else {
            return nil
        }
        return name
    }
}
