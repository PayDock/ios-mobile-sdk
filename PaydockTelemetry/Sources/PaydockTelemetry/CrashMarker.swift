//
//  CrashMarker.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The one crash both capture paths see (R_07): the handler saves it with its record when a frame lies in the SDK's
/// image, and the next launch's MetricKit SIGABRT report holding the same frame is skipped. Codable: saved as JSON.
package struct CrashMarker: Sendable, Equatable, Codable {
    package let sessionId: String
    package let imageUUID: String
    package let topFrameOffset: UInt64   // the top frame in the SDK's image
    package let time: Int64              // UTC epoch ms

    package init(sessionId: String, imageUUID: String, topFrameOffset: UInt64, time: Int64) {
        self.sessionId = sessionId
        self.imageUUID = imageUUID
        self.topFrameOffset = topFrameOffset
        self.time = time
    }
}
