//
//  SdkTelemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

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
}
