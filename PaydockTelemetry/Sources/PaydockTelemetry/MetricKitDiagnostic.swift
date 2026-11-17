//
//  MetricKitDiagnostic.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One crash or hang diagnostic MetricKit delivered, reduced to the fields the reader uses (I10).
package struct MetricKitDiagnostic: Sendable, Equatable {
    package enum Kind: Sendable, Equatable { case crash, hang }

    package let kind: Kind
    package let exceptionType: Int?    // crash only
    package let signal: Int?           // crash only
    package let frames: [DiagnosticFrame]  // the attributed thread (else the first), innermost first, at most 64
    package let timeEnd: Int64         // the payload's timeStampEnd, UTC epoch ms

    package init(kind: Kind, exceptionType: Int?, signal: Int?, frames: [DiagnosticFrame], timeEnd: Int64) {
        self.kind = kind
        self.exceptionType = exceptionType
        self.signal = signal
        self.frames = frames
        self.timeEnd = timeEnd
    }
}
