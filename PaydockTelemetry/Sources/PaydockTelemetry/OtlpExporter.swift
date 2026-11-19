//
//  OtlpExporter.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Encodes a batch as OTLP/HTTP JSON, gzips it and posts it with exactly the content-encoding and content-type headers
/// (R_03, R_05), then maps the transport's result to the retry rules (R_12).
package final class OtlpExporter: Exporter, @unchecked Sendable {
    /// Every request's headers, and no other.
    private static let headers = [
        "Content-Encoding": "gzip",
        "Content-Type": "application/json"
    ]

    private let transport: any TelemetryTransport

    package init(transport: any TelemetryTransport) {
        self.transport = transport
    }

    package func export(_ batch: ExportBatch) -> ExportResult {
        let json = OtlpLogEncoder.encode(resource: batch.resource, records: batch.records)
        guard let payload = Gzip.compress(json) else {
            return .retry(retryAfterMilliseconds: nil)
        }
        switch transport.send(payload, headers: Self.headers) {
        case let .success(_, rejectedRecords):
            return .success(rejectedRecords: rejectedRecords)
        case let .httpError(status, retryAfterMilliseconds):
            switch status {
            case 401, 403:
                // The collector refuses this app: stop sending for the process.
                return .unauthorized
            case 413:
                return .tooLarge
            case 408, 429, 500...599:
                return .retry(retryAfterMilliseconds: retryAfterMilliseconds)
            default:
                return .rejected
            }
        case .timeout, .connectionFailure, .failure:
            return .retry(retryAfterMilliseconds: nil)
        }
    }
}
