//
//  TelemetryEvent.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Something that happened in the SDK and becomes a record. Typed fields only, no free-form maps,
/// and never a raw `Error` or `NSException`: they enter an event only as a sanitised `ErrorInfo`.
package enum TelemetryEvent: Sendable, Equatable {

    /// The process died: an uncaught Objective-C exception seen by the chained handler (`.nsException`),
    /// or a crash diagnostic MetricKit delivers on a later launch (`.metricKit`).
    /// `crashReason` is the exception name or the signal (spec § 5.3), never `NSException.reason`.
    case crash(error: ErrorInfo?, source: CrashSource, crashReason: String? = nil, threadName: String? = nil)

    /// An error that escaped SDK-owned code (a `Task` or an async entry point) while the process kept running —
    /// unlike `.crash(source: .nsException)`, which is the process dying.
    case uncaughtException(error: ErrorInfo, threadName: String? = nil, widget: String? = nil)

    /// `errorCode` is `WidgetError.code` where one exists.
    case sdkError(error: ErrorInfo, errorCode: String? = nil, widget: String? = nil)

    /// `urlTemplate` is a path template, never real ids. The status code and the failure kind cannot disagree.
    case networkFailure(
        method: HTTPMethod,
        urlTemplate: String,
        serverAddress: String,
        failure: NetworkError,
        attempt: Int = 1,
        apiError: APIError? = nil,
        widget: String? = nil
    )

    /// A sanitised error: its fully qualified type, its stack frames and its cause, never a message,
    /// `localizedDescription`, `NSException.reason`, `userInfo` values or `description` output (spec § 5.5).
    package struct ErrorInfo: Sendable, Equatable {
        package static let maxFrames = 64
        package static let maxCauses = 8

        package let type: String               // String(reflecting: type(of: error))
        package let frames: [String]           // symbol frames as reported, at most maxFrames
        private let causeStorage: [ErrorInfo]  // zero or one element: a struct cannot hold itself

        package var cause: ErrorInfo? { causeStorage.first }

        /// Ordered types down the cause chain, outermost cause first (paydock.exception.cause_types).
        package var causeTypes: [String] {
            var types: [String] = []
            var next = cause
            while let current = next {
                types.append(current.type)
                next = current.cause
            }
            return types
        }

        package init(type: String, frames: [String], cause: ErrorInfo? = nil) {
            self.type = type
            self.frames = Array(frames.prefix(Self.maxFrames))
            self.causeStorage = cause.map { [$0] } ?? []
        }

        /// A Swift or bridged error. `frames` is the capture site's call stack where it has one.
        /// Reads only the error's type and its `NSUnderlyingErrorKey`, never its message or other user info.
        package static func from(_ error: any Error, frames: [String] = []) -> ErrorInfo {
            ErrorInfo(
                type: String(reflecting: Swift.type(of: error)),
                frames: frames,
                cause: causeInfo(of: (error as NSError).userInfo[NSUnderlyingErrorKey], depth: 0)
            )
        }

        /// An Objective-C exception: its class and `callStackSymbols`, never its name, reason or user info.
        /// `callStackSymbols` is kept as reported, unsymbolicated addresses included (spec § 5.5).
        package static func from(_ exception: NSException) -> ErrorInfo {
            ErrorInfo(
                type: String(reflecting: Swift.type(of: exception)),
                frames: exception.callStackSymbols,
                cause: causeInfo(of: exception.userInfo?[NSUnderlyingErrorKey], depth: 0)
            )
        }

        /// The cause chain follows only `NSUnderlyingErrorKey`. A cause has no frames, and the chain stops
        /// after `maxCauses` causes, so a chain that loops terminates.
        private static func causeInfo(of underlying: Any?, depth: Int) -> ErrorInfo? {
            guard depth < maxCauses, let error = underlying as? Error else {
                return nil
            }
            return ErrorInfo(
                type: String(reflecting: Swift.type(of: error)),
                frames: [],
                cause: causeInfo(of: (error as NSError).userInfo[NSUnderlyingErrorKey], depth: depth + 1)
            )
        }
    }

    /// How a Paydock API call failed. One enum, so a status code and a transport failure never coexist.
    package enum NetworkError: Sendable, Equatable {
        case httpStatus(code: Int)                                    // error.type http_4xx / http_5xx by code
        case transport(kind: TransportKind, error: ErrorInfo? = nil)
        case decode(statusCode: Int? = nil, error: ErrorInfo? = nil)
    }

    /// Structured fields of a Paydock error body. Never its message text.
    package struct APIError: Sendable, Equatable {
        package let status: String?
        package let code: String?
        package let summaryCode: String?
        package let gatewayCodes: [String]

        package init(status: String? = nil, code: String? = nil, summaryCode: String? = nil, gatewayCodes: [String] = []) {
            self.status = status
            self.code = code
            self.summaryCode = summaryCode
            self.gatewayCodes = gatewayCodes
        }
    }

    package enum CrashSource: Sendable, Equatable { case nsException, metricKit }

    package enum TransportKind: Sendable, Equatable { case timeout, connection, tls, unknown }

    package enum HTTPMethod: Sendable, Equatable { case get, post, put, patch, delete, head, options }
}
