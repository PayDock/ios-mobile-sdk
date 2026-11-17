//
//  CrashRecording.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Records an uncaught Objective-C exception on the crashing thread, before the process dies (R_04).
package protocol CrashRecording: Sendable { func record(_ exception: NSException) }
