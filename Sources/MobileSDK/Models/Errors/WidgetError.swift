//
//  WidgetError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Common surface shared by every widget error type so integrators can log and report failures
/// uniformly.
///
/// Integrators typically forward failures to their own loggers and quote them back to us. To make
/// that reliable, every widget error exposes:
/// - `code`: a **stable, machine-readable** identifier (e.g. `"APPLE_PAY_RESPONSE_DECODE"`) that is
///   safe to key alerts/metrics on. This value is treated as an API contract and is covered by tests.
/// - `customMessage`: the existing **user-facing** message (unchanged).
/// - `debugDescription`: **technical detail** for logs, embedding the underlying cause (the wrapped
///   `RequestError`, `NSError`, or `ErrorRes`). Never show this to end users.
///
/// Conforming to `CustomDebugStringConvertible` means `String(reflecting: error)` and
/// string-interpolating the error in a logger both yield `debugDescription` automatically.
public protocol WidgetError: Error, CustomDebugStringConvertible {
    /// Stable, machine-readable identifier — safe to log/alert on. e.g. `"APPLE_PAY_RESPONSE_DECODE"`.
    var code: String { get }
    /// User-facing message describing the failure.
    var customMessage: String { get }
    /// Technical detail for logs; embeds the underlying cause. Not intended for end users.
    var debugDescription: String { get }
}
