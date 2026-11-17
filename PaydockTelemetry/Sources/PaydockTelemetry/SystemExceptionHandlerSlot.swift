//
//  SystemExceptionHandlerSlot.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// The process's slot: `NSGetUncaughtExceptionHandler` and `NSSetUncaughtExceptionHandler`.
package struct SystemExceptionHandlerSlot: ExceptionHandlerSlot {
    package init() {}

    package func get() -> (@convention(c) (NSException) -> Void)? {
        NSGetUncaughtExceptionHandler()
    }

    package func set(_ handler: (@convention(c) (NSException) -> Void)?) {
        NSSetUncaughtExceptionHandler(handler)
    }
}
#endif
