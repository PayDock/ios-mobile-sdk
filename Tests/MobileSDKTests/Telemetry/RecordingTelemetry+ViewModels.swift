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

    /// A payment record as the widget tests read it (D24): the widget, the outcome and the error code.
    enum PaymentReport: Equatable {
        case started(SdkWidget?)
        case finished(SdkWidget?, TelemetryEvent.PaymentOutcome, String?)
    }

    /// Every `.paymentStarted` and `.paymentFinished` reported, in order.
    var payments: [PaymentReport] {
        events.compactMap { event in
            switch event {
            case let .paymentStarted(widget, _):
                return .started(SdkWidget(rawValue: widget))
            case let .paymentFinished(widget, _, outcome, errorCode, _):
                return .finished(SdkWidget(rawValue: widget), outcome, errorCode)
            default:
                return nil
            }
        }
    }

    /// The payment ID of each entry of `payments`, in the same order, to compare the pairing of a start and its
    /// finish.
    var paymentIds: [String] {
        events.compactMap { event in
            switch event {
            case let .paymentStarted(_, paymentId), let .paymentFinished(_, paymentId, _, _, _):
                return paymentId
            default:
                return nil
            }
        }
    }

    /// True when the payments are start-finish pairs, each finish with the ID of the start right before it, and every
    /// pair has its own ID.
    var paymentsArePaired: Bool {
        let ids = paymentIds
        guard ids.count.isMultiple(of: 2) else {
            return false
        }
        let pairs = stride(from: 0, to: ids.count, by: 2).map { (ids[$0], ids[$0 + 1]) }
        return pairs.allSatisfy { $0.0 == $0.1 } && Set(pairs.map(\.0)).count == pairs.count
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
