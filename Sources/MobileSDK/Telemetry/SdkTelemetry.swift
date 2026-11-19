//
//  SdkTelemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PaydockTelemetry

/// The SDK's only reporting calls (RS-4). Each returns at once when `telemetry.isActive` is false (R_11).
enum SdkTelemetry {
    /// R_01, R_05: returns for a `CancellationError`, a request-caused error and an outcome; otherwise
    /// `telemetry.report(.sdkError(error: SdkErrorFacts.errorInfo(error), errorCode: SdkErrorFacts.code(error),
    /// widget: widget?.rawValue), site: ReportSite.capture())`. With `once`, only the first report of its key in its
    /// memory is sent, for a failure that repeats without a new cause.
    static func reportSdkError(_ error: any Error, widget: SdkWidget?,
                               once: (memory: ReportOnce, key: AnyHashable)? = nil,
                               telemetry: any Telemetry = TelemetryBinding.current) {
        guard telemetry.isActive,
              !(error is CancellationError),
              !SdkErrorFacts.isRequestCaused(error),
              !((error as? any TelemetryErrorFacts)?.isOutcome ?? false) else {
            return
        }
        if let once, !once.memory.claim(once.key) {
            return
        }
        let site = ReportSite.capture()
        telemetry.report(.sdkError(error: SdkErrorFacts.errorInfo(error), errorCode: SdkErrorFacts.code(error),
                                   widget: widget?.rawValue), site: site)
    }

    /// R_04: returns for a `CancellationError`; otherwise `telemetry.report(.uncaughtException(error:
    /// SdkErrorFacts.errorInfo(error), widget: widget?.rawValue), site: ReportSite.capture())`.
    static func reportUncaught(_ error: any Error, widget: SdkWidget?,
                               telemetry: any Telemetry = TelemetryBinding.current) {
        guard telemetry.isActive, !(error is CancellationError) else {
            return
        }
        let site = ReportSite.capture()
        telemetry.report(.uncaughtException(error: SdkErrorFacts.errorInfo(error), widget: widget?.rawValue), site: site)
    }

    /// R_08: `telemetry.report(.widgetOpened(widget: widget.rawValue))`.
    static func reportWidgetOpened(_ widget: SdkWidget, telemetry: any Telemetry = TelemetryBinding.current) {
        guard telemetry.isActive else {
            return
        }
        telemetry.report(.widgetOpened(widget: widget.rawValue))
    }

    /// D24: nil while inactive; else reports `.paymentStarted` with a new id and returns the attempt.
    static func startPayment(_ widget: SdkWidget, telemetry: any Telemetry = TelemetryBinding.current) -> PaymentAttempt? {
        guard telemetry.isActive else {
            return nil
        }
        let attempt = PaymentAttempt(widget: widget, id: UUID().uuidString.lowercased())
        telemetry.report(.paymentStarted(widget: widget.rawValue, paymentId: attempt.id))
        return attempt
    }

    /// D24: returns at once for a nil attempt. Sets it to nil, then, when active, reports `.paymentFinished` with the
    /// end's outcome and, for `.failed` and `.failedWithCode`, its code. A second call on the same variable does nothing.
    static func finishPayment(_ attempt: inout PaymentAttempt?, _ end: PaymentEnd,
                              telemetry: any Telemetry = TelemetryBinding.current) {
        guard let finished = attempt else {
            return
        }
        attempt = nil
        guard telemetry.isActive else {
            return
        }
        let outcome: TelemetryEvent.PaymentOutcome
        var errorCode: String?
        switch end {
        case .success:
            outcome = .success
        case .declined:
            outcome = .declined
        case .cancelled:
            outcome = .cancelled
        case let .failed(error):
            outcome = .error
            errorCode = SdkErrorFacts.code(error)
        case let .failedWithCode(code):
            outcome = .error
            errorCode = code
        }
        telemetry.report(.paymentFinished(widget: finished.widget.rawValue, paymentId: finished.id, outcome: outcome,
                                          errorCode: errorCode))
    }

    /// D24: an attempt that fails before its widget loads (an invalid 3DS token): when active and the key is new in
    /// its memory, a start and an error finish with the error's code.
    static func recordFailedPayment(_ widget: SdkWidget, error: any Error, once: (memory: ReportOnce, key: AnyHashable),
                                    telemetry: any Telemetry = TelemetryBinding.current) {
        guard telemetry.isActive, once.memory.claim(once.key) else {
            return
        }
        var attempt = startPayment(widget, telemetry: telemetry)
        finishPayment(&attempt, .failed(error), telemetry: telemetry)
    }
}
