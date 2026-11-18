//
//  RecordingTelemetry+ViewModels.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
@testable import MobileSDK
import PaydockTelemetry

/// What the view-model tests read from a `RecordingTelemetry`: the SDK errors it received, by code and widget.
extension RecordingTelemetry {
    struct SdkErrorReport: Equatable {
        let code: String?
        let widget: String?
        let hasSite: Bool
    }

    /// Every `.sdkError` reported, in order, with whether it came with a report site.
    var sdkErrors: [SdkErrorReport] {
        reports.compactMap { report in
            guard case let .sdkError(_, errorCode, widget, _, _) = report.event else {
                return nil
            }
            return SdkErrorReport(code: errorCode, widget: widget, hasSite: report.site != nil)
        }
    }

    /// Binds this facade as `TelemetryBinding.current`; `RecordingTelemetry.unbind()` rebinds the no-op. Unbinds
    /// first: an active selection never replaces an active facade that is already bound.
    func bindAsCurrent() {
        Self.unbind()
        TelemetryBinding.bind(TelemetrySelection(telemetry: self, runtime: NoOpTelemetry()))
    }

    static func unbind() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
    }

    /// Waits until at least `count` reports arrived, or `timeout` passed, for paths that deliver nothing.
    @MainActor
    func waitForReports(count: Int, timeout: TimeInterval = 2.0) async {
        let deadline = Date().addingTimeInterval(timeout)
        while reports.count < count, Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}

extension RecordingTelemetry.SdkErrorReport {
    /// A reported SDK error with its site, as every reporting call sends it.
    static func reported(_ code: String, _ widget: SdkWidget?) -> Self {
        Self(code: code, widget: widget?.rawValue, hasSite: true)
    }
}
