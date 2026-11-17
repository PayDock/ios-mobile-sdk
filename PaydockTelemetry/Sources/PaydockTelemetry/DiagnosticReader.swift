//
//  DiagnosticReader.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Turns the diagnostics MetricKit delivers on a later launch into crash events (I10). Pure: the marker, the
/// classifier and the time come in, the events and whether to clear the marker go out.
package enum DiagnosticReader {
    /// The signal an uncaught Objective-C exception ends the process with.
    private static let sigabrt = 6

    /// R_10, R_11: skips a diagnostic older than recordMaxAgeMilliseconds; skips the first SIGABRT (signal 6) crash
    /// whose frames hold the marker's UUID and offset (clearMarker true); the rest become crash events in input order,
    /// frames described `<binaryName> 0x<offset>`. A marker older than recordMaxAgeMilliseconds is cleared and not
    /// matched.
    package static func events(_ diagnostics: [MetricKitDiagnostic], marker: CrashMarker?,
                               classifier: FrameClassifier?, now: Int64) -> (events: [TelemetryEvent], clearMarker: Bool) {
        // Compared against `now - maxAge`, so a corrupt time in a diagnostic or a marker can't overflow.
        let oldest = now - TelemetryLimits.recordMaxAgeMilliseconds
        var pending = marker
        var clearMarker = false
        if let marker, marker.time < oldest {
            pending = nil
            clearMarker = true
        }
        var events: [TelemetryEvent] = []
        for diagnostic in diagnostics where diagnostic.timeEnd >= oldest {
            if let current = pending, matches(diagnostic, current) {
                pending = nil
                clearMarker = true
                continue
            }
            events.append(event(diagnostic, classifier: classifier))
        }
        return (events, clearMarker)
    }

    /// The SIGABRT crash of the exception the handler already recorded: a frame at the marker's UUID and offset.
    private static func matches(_ diagnostic: MetricKitDiagnostic, _ marker: CrashMarker) -> Bool {
        let uuid = marker.imageUUID.uppercased()
        return diagnostic.kind == .crash && diagnostic.signal == sigabrt
            && diagnostic.frames.contains { $0.binaryUUID == uuid && $0.offset == marker.topFrameOffset }
    }

    /// A crash: a signal crash with the Mach exception's name as its type, the signal's name as its reason and the
    /// payload's end as its time. A hang: frames only, and the payload's end as its time too (R_10, D20).
    private static func event(_ diagnostic: MetricKitDiagnostic, classifier: FrameClassifier?) -> TelemetryEvent {
        let frames = diagnostic.frames.map { "\($0.binaryName) 0x\(String($0.offset, radix: 16))" }
        let inSdk = classifier?.inSdk(diagnostic.frames.map {
            FrameAddress(imageName: $0.binaryName, uuid: $0.binaryUUID, offset: $0.offset)
        })
        switch diagnostic.kind {
        case .crash:
            return .crash(
                error: TelemetryEvent.ErrorInfo(type: diagnostic.exceptionType.map(MetricKitPayload.exceptionName), frames: frames),
                source: .metricKit, kind: .signal, inSdk: inSdk, crashReason: diagnostic.signal.map(MetricKitPayload.signalName),
                occurredAt: diagnostic.timeEnd
            )
        case .hang:
            return .crash(error: TelemetryEvent.ErrorInfo(type: nil, frames: frames), source: .metricKit, kind: .hang,
                          inSdk: inSdk, occurredAt: diagnostic.timeEnd)
        }
    }
}
