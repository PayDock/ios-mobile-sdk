//
//  PlatformInfo.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What the platform reports. Never a hardware or advertising identifier (principle 10).
package protocol PlatformInfo: Sendable {
    var osVersion: String { get }
    var modelIdentifier: String { get }
    var appId: String { get }
    var appVersion: String { get }
    var appDebuggable: Bool { get }
}
