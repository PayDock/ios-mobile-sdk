//
//  ReportSiteResolver.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// R_03, on the telemetry queue. For `.sdkError` and `.uncaughtException`: the error keeps its type and cause, its
/// frames become the site's addresses through `resolver` and `StackFrame.describe`, and `inSdk` becomes
/// `classifier?.inSdk(frames)` over `FrameAddress.of` of each resolved address (nil without a classifier). For
/// `.uncaughtException` a nil `threadName` becomes the site's. Every other event comes back unchanged.
package enum ReportSiteResolver {
    package static func resolve(_ event: TelemetryEvent, site: ReportSite, resolver: any AddressResolving,
                                image: SdkImage?, classifier: FrameClassifier?) -> TelemetryEvent {
        switch event {
        case let .sdkError(error, errorCode, widget, apiError, _):
            let resolved = describe(site, resolver: resolver, image: image, classifier: classifier)
            return .sdkError(error: located(error, resolved.frames), errorCode: errorCode, widget: widget,
                             apiError: apiError, inSdk: resolved.inSdk)
        case let .uncaughtException(error, threadName, widget, _):
            let resolved = describe(site, resolver: resolver, image: image, classifier: classifier)
            return .uncaughtException(error: located(error, resolved.frames), threadName: threadName ?? site.threadName,
                                      widget: widget, inSdk: resolved.inSdk)
        case .crash, .networkFailure, .widgetOpened, .paymentStarted, .paymentFinished, .dropped:
            return event
        }
    }

    /// The site's addresses described (R_08), and the classifier's answer over the resolved ones.
    private static func describe(_ site: ReportSite, resolver: any AddressResolving, image: SdkImage?,
                                 classifier: FrameClassifier?) -> (frames: [String], inSdk: Bool?) {
        var described: [String] = []
        var addresses: [FrameAddress] = []
        for address in site.returnAddresses.prefix(TelemetryEvent.ErrorInfo.maxFrames) {
            let resolved = resolver.resolve(address)
            described.append(StackFrame.describe(address, resolved))
            if let frame = FrameAddress.of(address, resolved, sdkImage: image) {
                addresses.append(frame)
            }
        }
        return (described, classifier?.inSdk(addresses))
    }

    /// The error's type and cause with the site's frames.
    private static func located(_ error: TelemetryEvent.ErrorInfo, _ frames: [String]) -> TelemetryEvent.ErrorInfo {
        TelemetryEvent.ErrorInfo(type: error.type, frames: frames, cause: error.cause)
    }
}
