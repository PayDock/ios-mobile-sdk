//
//  DiagnosticFrame.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One frame of a MetricKit call stack: its image's name and UUID, and its offset in that image.
package struct DiagnosticFrame: Sendable, Equatable {
    package let binaryName: String
    package let binaryUUID: String     // uppercased
    package let offset: UInt64         // offsetIntoBinaryTextSegment (R_12)

    package init(binaryName: String, binaryUUID: String, offset: UInt64) {
        self.binaryName = binaryName
        self.binaryUUID = binaryUUID
        self.offset = offset
    }
}
