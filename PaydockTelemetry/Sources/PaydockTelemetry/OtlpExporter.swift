//
//  OtlpExporter.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Encodes a batch as OTLP/HTTP JSON, gzips it and posts it with the content-encoding, content-type and basic
/// authorization headers (R_03), then maps the transport's result to the retry rules (R_12).
package final class OtlpExporter: Exporter, @unchecked Sendable {
    private static let basicPrefix = "Basic "

    private let transport: any TelemetryTransport
    private let headers: [String: String]

    package init(transport: any TelemetryTransport, credentials: TelemetryCredentials) {
        self.transport = transport
        let authorization = credentials.authorization
        self.headers = [
            "Content-Encoding": "gzip",
            "Content-Type": "application/json",
            "Authorization": authorization.hasPrefix(Self.basicPrefix) ? authorization : Self.basicPrefix + authorization
        ]
    }

    package func export(_ batch: ExportBatch) -> ExportResult {
        let json = OtlpLogEncoder.encode(resource: batch.resource, records: batch.records)
        guard let payload = Gzip.compress(json) else {
            return .retry(retryAfterMilliseconds: nil)
        }
        switch transport.send(payload, headers: headers) {
        case let .success(_, rejectedRecords):
            return .success(rejectedRecords: rejectedRecords)
        case let .httpError(status, retryAfterMilliseconds):
            switch status {
            case 401, 403:
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
