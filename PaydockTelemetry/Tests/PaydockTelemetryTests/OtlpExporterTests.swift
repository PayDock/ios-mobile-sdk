//
//  OtlpExporterTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_03, R_12: the exporter's request and its mapping of every transport result.
final class OtlpExporterTests: XCTestCase {

    private static let session = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"

    private let batch = ExportBatch(resource: FakeDeviceContextProvider.attributes, records: [OtlpExporterTests.record()])

    private static let contentHeaders = ["Content-Encoding": "gzip", "Content-Type": "application/json"]

    func testSuccess_SendsTheGzippedBatch_WithTheTwoContentHeaders() throws {
        let transport = RecordingTransport([.success(status: 204, rejectedRecords: 0)])

        XCTAssertEqual(exporter(transport).export(batch), .success(rejectedRecords: 0))

        let call = try XCTUnwrap(transport.calls.first)
        XCTAssertEqual(transport.calls.count, 1)
        XCTAssertEqual(call.headers, Self.contentHeaders)
        XCTAssertEqual(call.payload, Gzip.compress(OtlpLogEncoder.encode(resource: batch.resource, records: batch.records)))
    }

    /// R_05, D22: every request carries exactly the two content headers, whatever the response, and never an
    /// authorization header.
    func testEveryRequest_CarriesExactlyTheTwoContentHeaders() throws {
        let results: [TransportResult] = [
            .success(status: 200, rejectedRecords: 0), .httpError(status: 400, retryAfterMilliseconds: nil),
            .httpError(status: 401, retryAfterMilliseconds: nil), .httpError(status: 503, retryAfterMilliseconds: 1_000),
            .timeout, .connectionFailure
        ]
        let transport = RecordingTransport(results)
        let exporter = exporter(transport)

        for _ in results {
            _ = exporter.export(batch)
        }

        XCTAssertEqual(transport.calls.count, results.count)
        for call in transport.calls {
            XCTAssertEqual(call.headers, Self.contentHeaders)
        }
    }

    /// D22: a 400 is rejected, not retried.
    func test400_IsRejected() {
        XCTAssertEqual(result(.httpError(status: 400, retryAfterMilliseconds: nil)), .rejected)
        XCTAssertEqual(result(.httpError(status: 400, retryAfterMilliseconds: 1_000)), .rejected)
    }

    /// D22: 429, 502, 503 and 504 are retried, with the `Retry-After` carried.
    func testD22RetryStatuses_AreRetried_WithRetryAfterCarried() {
        for status in [429, 502, 503, 504] {
            XCTAssertEqual(result(.httpError(status: status, retryAfterMilliseconds: 4_000)),
                           .retry(retryAfterMilliseconds: 4_000), "\(status)")
            XCTAssertEqual(result(.httpError(status: status, retryAfterMilliseconds: nil)),
                           .retry(retryAfterMilliseconds: nil), "\(status)")
        }
    }

    func testPartialSuccess_PassesTheRejectedCount() {
        XCTAssertEqual(result(.success(status: 200, rejectedRecords: 3)), .success(rejectedRecords: 3))
    }

    func test401And403_AreUnauthorized() {
        XCTAssertEqual(result(.httpError(status: 401, retryAfterMilliseconds: nil)), .unauthorized)
        XCTAssertEqual(result(.httpError(status: 403, retryAfterMilliseconds: 5_000)), .unauthorized)
    }

    func test413_IsTooLarge() {
        XCTAssertEqual(result(.httpError(status: 413, retryAfterMilliseconds: nil)), .tooLarge)
    }

    func test408And429And5xx_AreRetried_WithRetryAfter() {
        XCTAssertEqual(result(.httpError(status: 408, retryAfterMilliseconds: nil)), .retry(retryAfterMilliseconds: nil))
        XCTAssertEqual(result(.httpError(status: 429, retryAfterMilliseconds: 7_000)), .retry(retryAfterMilliseconds: 7_000))
        XCTAssertEqual(result(.httpError(status: 500, retryAfterMilliseconds: nil)), .retry(retryAfterMilliseconds: nil))
        XCTAssertEqual(result(.httpError(status: 503, retryAfterMilliseconds: 2_000)), .retry(retryAfterMilliseconds: 2_000))
        XCTAssertEqual(result(.httpError(status: 599, retryAfterMilliseconds: nil)), .retry(retryAfterMilliseconds: nil))
    }

    func testAnyOtherStatus_IsRejected() {
        for status in [300, 400, 404, 409, 422, 600] {
            XCTAssertEqual(result(.httpError(status: status, retryAfterMilliseconds: 1_000)), .rejected, "\(status)")
        }
    }

    func testTimeoutConnectionFailureAndFailure_AreRetried_WithoutRetryAfter() {
        XCTAssertEqual(result(.timeout), .retry(retryAfterMilliseconds: nil))
        XCTAssertEqual(result(.connectionFailure), .retry(retryAfterMilliseconds: nil))
        XCTAssertEqual(result(.failure), .retry(retryAfterMilliseconds: nil))
    }

    func testOneAttempt_PerExport() {
        let transport = RecordingTransport([.timeout, .timeout])

        _ = exporter(transport).export(batch)

        XCTAssertEqual(transport.calls.count, 1)
    }

    // MARK: - Helpers

    private func exporter(_ transport: RecordingTransport) -> OtlpExporter {
        OtlpExporter(transport: transport)
    }

    private func result(_ transportResult: TransportResult) -> ExportResult {
        exporter(RecordingTransport([transportResult])).export(batch)
    }

    private static func record() -> TelemetryRecord {
        let pending = PendingRecord(id: "\(session)-1", sessionId: session, event: TelemetryFixtures.sdkError(),
                                    createdAt: 1_793_852_047_512)
        return Allowlist.filter(RecordFactory.create(pending, connection: .wifi))
    }
}
