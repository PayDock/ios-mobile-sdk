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
    /// D25: `charge3dsId` is evaluated only when telemetry is active and `widget` is `.standalone3ds` or `.mpgs3ds`;
    /// an empty value counts as none.
    static func startPayment(_ widget: SdkWidget, charge3dsId: @autoclosure () -> String? = nil,
                             telemetry: any Telemetry = TelemetryBinding.current) -> PaymentAttempt? {
        guard telemetry.isActive else {
            return nil
        }
        let known = isThreeDS(widget) ? nonEmpty(charge3dsId()) : nil
        let attempt = PaymentAttempt(widget: widget, id: UUID().uuidString.lowercased(), charge3dsId: known)
        telemetry.report(.paymentStarted(widget: widget.rawValue, paymentId: attempt.id, charge3dsId: attempt.charge3dsId))
        return attempt
    }

    /// D25: sets `attempt.charge3dsId` when the attempt is open, holds none yet, and `charge3dsId` is non-empty.
    /// Reports nothing.
    static func notePaymentCharge3dsId(_ charge3dsId: String?, on attempt: inout PaymentAttempt?) {
        guard var open = attempt, open.charge3dsId == nil, let known = nonEmpty(charge3dsId) else {
            return
        }
        open.charge3dsId = known
        attempt = open
    }

    /// D24: returns at once for a nil attempt. Sets it to nil, then, when active, reports `.paymentFinished` with the
    /// end's outcome and, for `.failed` and `.failedWithCode`, its code. A second call on the same variable does nothing.
    /// D25: sends the attempt's `charge3dsId`. `flow` is sent only for `.standalone3ds` and an end of `.success` or
    /// `.declined` (mapped by raw value to `TelemetryEvent.ThreeDSFlow`); otherwise dropped.
    static func finishPayment(_ attempt: inout PaymentAttempt?, _ end: PaymentEnd,
                              flow: Standalone3DSResult.AuthenticationFlow? = nil,
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
        let sentFlow = finished.widget == .standalone3ds && (outcome == .success || outcome == .declined)
            ? flow.flatMap { TelemetryEvent.ThreeDSFlow(rawValue: $0.rawValue) } : nil
        telemetry.report(.paymentFinished(widget: finished.widget.rawValue, paymentId: finished.id, outcome: outcome,
                                          errorCode: errorCode, charge3dsId: finished.charge3dsId, flow: sentFlow))
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

    /// D25: the two widgets whose payment records may carry the 3DS charge id.
    private static func isThreeDS(_ widget: SdkWidget) -> Bool {
        widget == .standalone3ds || widget == .mpgs3ds
    }

    private static func nonEmpty(_ text: String?) -> String? {
        guard let text, !text.isEmpty else {
            return nil
        }
        return text
    }
}
