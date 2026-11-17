//
//  ExceptionHandlerSlot.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The process's one uncaught-exception handler, behind a seam so the chain is tested without touching it. A handler
/// is `NSUncaughtExceptionHandler` as C declares it: a C function pointer (Swift imports the typedef's name as a Swift
/// function type, which `NSSetUncaughtExceptionHandler` cannot take).
package protocol ExceptionHandlerSlot: Sendable {
    func get() -> (@convention(c) (NSException) -> Void)?
    func set(_ handler: (@convention(c) (NSException) -> Void)?)
}
