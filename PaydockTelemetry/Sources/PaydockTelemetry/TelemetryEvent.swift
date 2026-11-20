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
    /// `inSdk`: the frame classifier's answer (spec § 7.2), nil when it cannot tell (no record attribute then);
    /// `occurredAt`: UTC epoch ms from the OS report, nil when the event has no time of its own (an in-process
    /// exception, a hang without one).
    case crash(error: ErrorInfo?, source: CrashSource, kind: CrashKind, inSdk: Bool?, crashReason: String? = nil,
               threadName: String? = nil, occurredAt: Int64? = nil)

    /// An error that escaped SDK-owned code (a `Task` or an async entry point) while the process kept running —
    /// unlike `.crash(source: .nsException)`, which is the process dying.
    /// `inSdk`: the frame classifier's answer over the report site (spec § 7.2), nil when it cannot tell.
    case uncaughtException(error: ErrorInfo, threadName: String? = nil, widget: String? = nil, inSdk: Bool? = true)

    /// `errorCode` is `WidgetError.code` where one exists.
    /// `apiError`: the § 5.4 API codes when the error carries a Paydock API error body (Android R_03, MD-8).
    /// `inSdk`: the frame classifier's answer over the report site (spec § 7.2), nil when it cannot tell.
    case sdkError(error: ErrorInfo, errorCode: String? = nil, widget: String? = nil, apiError: APIError? = nil,
                  inSdk: Bool? = true)

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

    /// D19: the first time a widget appears on screen in an SDK session.
    case widgetOpened(widget: String)

    /// D24, D25, § 5.9: an attempt started in a payment widget. `paymentId`: a random lowercase UUID, new per attempt.
    /// `charge3dsId`: 3DS widgets only, when known.
    case paymentStarted(widget: String, paymentId: String, charge3dsId: String? = nil)

    /// D24, D25, § 5.9. `errorCode` only for `.error`: the code the merchant receives. `durationMs` is the reducer's: any
    /// value a caller passes is replaced by the measured duration. `charge3dsId`: 3DS widgets only, when known. `flow`:
    /// `Standalone3DSWidget` only, on `.success` and `.declined`.
    case paymentFinished(widget: String, paymentId: String, outcome: PaymentOutcome, errorCode: String? = nil,
                         durationMs: Int64? = nil, charge3dsId: String? = nil, flow: ThreeDSFlow? = nil)

    /// Spec § 5.8. Only the telemetry target creates it (I7); SDK code never reports it.
    case dropped(reason: DroppedReason, count: Int)

    /// A sanitised error: its fully qualified type (an Objective-C exception's name), its stack frames and its cause, never a message,
    /// `localizedDescription`, `NSException.reason`, `userInfo` values or `description` output (spec § 5.5).
    package struct ErrorInfo: Sendable, Equatable {
        package static let maxFrames = 64
        package static let maxCauses = 8

        package let type: String?              // nil only for frames without an exception (a MetricKit hang)
        package let frames: [String]           // sanitised symbol frames, at most maxFrames
        private let causeStorage: [ErrorInfo]  // zero or one element: a struct cannot hold itself

        package var cause: ErrorInfo? { causeStorage.first }

        /// Ordered non-nil types down the cause chain, outermost cause first (paydock.exception.cause_types).
        package var causeTypes: [String] {
            var types: [String] = []
            var next = cause
            while let current = next {
                if let type = current.type {
                    types.append(type)
                }
                next = current.cause
            }
            return types
        }

        package init(type: String?, frames: [String], cause: ErrorInfo? = nil) {
            self.type = type
            self.frames = Array(frames.prefix(Self.maxFrames))
            self.causeStorage = cause.map { [$0] } ?? []
        }

        /// A Swift or bridged error. `frames` is the capture site's call stack where it has one.
        /// Reads only the error's type and its `NSUnderlyingErrorKey`, never its message or other user info.
        /// Frames pass through `StackFrame.sanitise`.
        package static func from(_ error: any Error, frames: [String] = []) -> ErrorInfo {
            ErrorInfo(
                type: String(reflecting: Swift.type(of: error)),
                frames: frames.prefix(maxFrames).map(StackFrame.sanitise),
                cause: causeInfo(of: (error as NSError).userInfo[NSUnderlyingErrorKey], depth: 0)
            )
        }

        /// An Objective-C exception. Type: the exception's name (`exception.name.rawValue`, spec § 5.3), never its
        /// class, reason or user info. Frames: as given, already described by `StackFrame.describe` (R_08).
        package static func from(_ exception: NSException, frames: [String]) -> ErrorInfo {
            ErrorInfo(
                type: exception.name.rawValue,
                frames: Array(frames.prefix(maxFrames)),
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
        package let status: Int?               // spec § 5.4 (2026-11-06)
        package let code: String?
        package let summaryCode: String?
        package let gatewayCodes: [String]

        package init(status: Int? = nil, code: String? = nil, summaryCode: String? = nil, gatewayCodes: [String] = []) {
            self.status = status
            self.code = code
            self.summaryCode = summaryCode
            self.gatewayCodes = gatewayCodes
        }
    }

    /// Raw values are the wire names (`paydock.crash.source`).
    package enum CrashSource: String, Sendable, Equatable { case nsException = "nsexception", metricKit = "metrickit" }

    /// Raw values are the wire names (`paydock.crash.kind`).
    package enum CrashKind: String, Sendable, Equatable { case exception, signal, hang, osKill = "os_kill" }

    /// Raw values are the wire names (`paydock.payment.outcome`).
    package enum PaymentOutcome: String, Sendable, Equatable, CaseIterable { case success, declined, error, cancelled }

    /// Raw values are the wire names (`paydock.3ds.flow`).
    package enum ThreeDSFlow: String, Sendable, Equatable, CaseIterable { case frictionless, challenge, decoupled }

    /// Raw values are the wire names (`paydock.dropped.reason`).
    package enum DroppedReason: String, Sendable, Equatable {
        case rateLimit = "rate_limit", storeFull = "store_full", tooOld = "too_old", rejected
    }

    /// Raw values are the wire names (`error.type` of a transport failure).
    package enum TransportKind: String, Sendable, Equatable { case timeout, connection, tls, unknown }

    /// Raw values are the wire names (`http.request.method`).
    package enum HTTPMethod: String, Sendable, Equatable {
        case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE", head = "HEAD", options = "OPTIONS"
    }
}
