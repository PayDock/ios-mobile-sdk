//
//  OtlpHttpTransportTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import PaydockTelemetry
import XCTest

/// R_03, R_04, MD-35: the transport posts through its own NetworkingLib client, maps any status to a typed result and
/// measures the clock offset from every response. The client's session uses a mock `URLProtocol`: no network.
final class OtlpHttpTransportTests: XCTestCase {

    private final class FactoryCount: @unchecked Sendable {
        private let lock = NSLock()
        private var calls = 0

        var value: Int {
            lock.lock()
            defer { lock.unlock() }
            return calls
        }

        func increment() {
            lock.lock()
            calls += 1
            lock.unlock()
        }
    }

    private static let endpoint = "https://otlp.invalid/otlp/v1/logs"
    private static let deviceNow: Int64 = 1_793_852_047_512
    private static let headers = ["Content-Encoding": "gzip", "Content-Type": "application/json"]

    private let clock = FixedClock(OtlpHttpTransportTests.deviceNow)
    private lazy var offset = ClockOffset(clock: clock)
    private let factoryCount = FactoryCount()

    override func setUp() {
        MockURLProtocol.reset()
    }

    override func tearDown() {
        MockURLProtocol.reset()
    }

    // MARK: - MD-35

    func testGzippedOtlpBody_WithTheTwoContentHeaders_And204_IsSuccess() throws {
        MockURLProtocol.answer(.response(status: 204, headers: [:], body: Data()))
        let exporter = OtlpExporter(transport: makeTransport())
        let record = Self.record()
        let batch = ExportBatch(resource: FakeDeviceContextProvider.attributes, records: [record])

        XCTAssertEqual(exporter.export(batch), .success(rejectedRecords: 0))

        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(MockURLProtocol.requests.count, 1)
        let url = try XCTUnwrap(request.url)
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "otlp.invalid")
        XCTAssertEqual(url.path, "/otlp/v1/logs")
        XCTAssertEqual(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? [], [])
        XCTAssertEqual(request.method, "POST")
        XCTAssertEqual(request.headers["Content-Encoding"], "gzip")
        XCTAssertEqual(request.headers["Content-Type"], "application/json")
        XCTAssertFalse(request.headers.keys.contains { $0.lowercased() == "authorization" }, "an authorization header was sent")
        XCTAssertEqual(Array(request.body.prefix(3)), [0x1F, 0x8B, 0x08])
        let json = OtlpLogEncoder.encode(resource: FakeDeviceContextProvider.attributes, records: [record])
        XCTAssertEqual(request.body, Gzip.compress(json))
    }

    func test204_IsSuccess() {
        MockURLProtocol.answer(.response(status: 204, headers: [:], body: Data()))

        XCTAssertEqual(send(), .success(status: 204, rejectedRecords: 0))
    }

    // MARK: - Endpoint and client

    func testEndpoint_DoesNotLogTraffic_AndPostsToTheUrl() throws {
        let endpoint = try XCTUnwrap(TelemetryEndpoint(url: Self.endpoint, header: Self.headers, body: Data([1])))

        XCTAssertFalse(endpoint.logsTraffic)
        XCTAssertEqual(endpoint.scheme, "https")
        XCTAssertEqual(endpoint.host, "otlp.invalid")
        XCTAssertEqual(endpoint.path, "/otlp/v1/logs")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertEqual(endpoint.header, Self.headers)
        XCTAssertEqual(endpoint.body, Data([1]))
        XCTAssertEqual(endpoint.parameters, [])
        XCTAssertNil(endpoint.mockFile)
        XCTAssertNil(endpoint.bundle)
    }

    func testEndpoint_IsNilUnlessHttpsWithAHost() {
        for url in ["http://otlp.invalid/v1/logs", "https:///v1/logs", "otlp.invalid/v1/logs", "", "ftp://otlp.invalid"] {
            XCTAssertNil(TelemetryEndpoint(url: url, header: [:], body: Data()), url)
        }
    }

    func testAnInvalidEndpoint_IsAFailure_WithoutAClient() {
        let transport = OtlpHttpTransport(endpoint: "http://otlp.invalid/v1/logs", clockOffset: offset,
                                          clientFactory: countingFactory())

        XCTAssertEqual(transport.send(Data([1]), headers: Self.headers), .failure)
        XCTAssertEqual(factoryCount.value, 0)
        XCTAssertTrue(MockURLProtocol.requests.isEmpty)
    }

    func testTelemetryClient_HasItsOwnUnpinnedSession() {
        let client = TelemetryHTTPClient()
        let configuration = client.session.configuration

        XCTAssertNil(client.sslPinningManager)
        XCTAssertNil(client.session.delegate)
        XCTAssertFalse(configuration.waitsForConnectivity)
        XCTAssertEqual(configuration.timeoutIntervalForRequest, TelemetryLimits.requestTimeoutSeconds)
        XCTAssertEqual(configuration.timeoutIntervalForResource, TelemetryLimits.requestTimeoutSeconds)
        XCTAssertEqual(TelemetryLimits.requestTimeoutSeconds, 15)
    }

    func testClient_IsBuiltOnTheFirstSendOnly() {
        let transport = makeTransport()
        XCTAssertEqual(factoryCount.value, 0)

        _ = transport.send(Data([1]), headers: Self.headers)
        _ = transport.send(Data([2]), headers: Self.headers)

        XCTAssertEqual(factoryCount.value, 1)
        XCTAssertEqual(MockURLProtocol.requests.map(\.body), [Data([1]), Data([2])])
    }

    // MARK: - 2xx

    func testPartialSuccess_CountIsRead_AsAStringOrANumber() {
        let body = #"{"partialSuccess":{"rejectedLogRecords":"3","errorMessage":"synthetic message"}}"#
        MockURLProtocol.answer(.response(status: 200, headers: ["Content-Type": "application/json"], body: Data(body.utf8)))
        XCTAssertEqual(send(), .success(status: 200, rejectedRecords: 3))

        MockURLProtocol.answer(.response(status: 200, headers: [:], body: Data(#"{"partialSuccess":{"rejectedLogRecords":2}}"#.utf8)))
        XCTAssertEqual(send(), .success(status: 200, rejectedRecords: 2))
    }

    /// D22: the collector's `200 {"partialSuccess":{}}` is a success with nothing rejected.
    func testD22EmptyPartialSuccess_IsSuccess_WithZeroRejected() {
        let body = Data(#"{"partialSuccess":{}}"#.utf8)
        MockURLProtocol.answer(.response(status: 200, headers: ["Content-Type": "application/json"], body: body))
        XCTAssertEqual(send(), .success(status: 200, rejectedRecords: 0))

        MockURLProtocol.answer(.response(status: 200, headers: ["Content-Type": "application/json"], body: body))
        let batch = ExportBatch(resource: FakeDeviceContextProvider.attributes, records: [Self.record()])
        XCTAssertEqual(OtlpExporter(transport: makeTransport()).export(batch), .success(rejectedRecords: 0))
    }

    func testPartialSuccess_AnythingElse_IsZero() {
        let oversized = #"{"partialSuccess":{"rejectedLogRecords":"3"},"padding":""# + String(repeating: "x", count: 70_000) + #""}"#
        let bodies = [
            "", "not json", #"{"partialSuccess":{}}"#, #"{"partialSuccess":{"rejectedLogRecords":"many"}}"#,
            #"{"partialSuccess":{"errorMessage":"synthetic message"}}"#, #"[1,2]"#, oversized
        ]
        for body in bodies {
            MockURLProtocol.answer(.response(status: 200, headers: [:], body: Data(body.utf8)))
            XCTAssertEqual(send(), .success(status: 200, rejectedRecords: 0), String(body.prefix(60)))
        }
    }

    // MARK: - Non-2xx

    func testNon2xx_IsAnHttpError_WithItsStatus() {
        for status in [401, 403, 408, 413, 500, 503] {
            MockURLProtocol.answer(.response(status: status, headers: [:], body: Data(#"{"error":"synthetic"}"#.utf8)))
            XCTAssertEqual(send(), .httpError(status: status, retryAfterMilliseconds: nil), "\(status)")
        }
    }

    func test429_WithRetryAfterSeconds_IsMilliseconds() {
        MockURLProtocol.answer(.response(status: 429, headers: ["Retry-After": "7"], body: Data()))

        XCTAssertEqual(send(), .httpError(status: 429, retryAfterMilliseconds: 7_000))
    }

    func testRetryAfter_AsAnHttpDateOrAnythingElse_IsNil() {
        for value in ["Sun, 06 Nov 2026 08:49:37 GMT", "-1", "1.5", "soon"] {
            MockURLProtocol.answer(.response(status: 503, headers: ["Retry-After": value], body: Data()))
            XCTAssertEqual(send(), .httpError(status: 503, retryAfterMilliseconds: nil), value)
        }
    }

    // MARK: - Failures

    func testTimeout_IsTimeout() {
        MockURLProtocol.answer(.error(.timedOut))

        XCTAssertEqual(send(), .timeout)
    }

    /// The telemetry queue never waits past the limit, even for a request that never ends.
    func testARequestThatNeverEnds_IsATimeout_AtTheWaitLimit() {
        MockURLProtocol.answer(.silence)
        let transport = OtlpHttpTransport(endpoint: Self.endpoint, clockOffset: offset, clientFactory: countingFactory(),
                                          waitLimitSeconds: 0.2)
        let started = Date()

        XCTAssertEqual(transport.send(Data("payload".utf8), headers: Self.headers), .timeout)
        XCTAssertLessThan(Date().timeIntervalSince(started), 5)
    }

    func testOffline_IsAConnectionFailure() {
        for code: URLError.Code in [.notConnectedToInternet, .cannotFindHost, .cannotConnectToHost, .networkConnectionLost] {
            MockURLProtocol.answer(.error(code))
            XCTAssertEqual(send(), .connectionFailure, "\(code.rawValue)")
        }
    }

    func testTlsFailure_IsAConnectionFailure() {
        for code: URLError.Code in [.secureConnectionFailed, .serverCertificateUntrusted, .serverCertificateHasBadDate,
                                    .serverCertificateHasUnknownRoot, .clientCertificateRejected] {
            MockURLProtocol.answer(.error(code))
            XCTAssertEqual(send(), .connectionFailure, "\(code.rawValue)")
        }
    }

    func testAnyOtherError_IsAFailure() {
        for code: URLError.Code in [.badServerResponse, .cancelled, .unknown] {
            MockURLProtocol.answer(.error(code))
            XCTAssertEqual(send(), .failure, "\(code.rawValue)")
        }
    }

    // MARK: - Clock offset

    func testDateHeader_IsMeasured_On2xx() {
        MockURLProtocol.answer(.response(status: 204, headers: ["Date": "Sun, 06 Nov 2026 08:49:37 GMT"], body: Data()))

        _ = send()

        XCTAssertEqual(offset.milliseconds, Self.epoch("Sun, 06 Nov 2026 08:49:37 GMT") - Self.deviceNow)
    }

    func testDateHeader_IsMeasured_OnNon2xx() {
        MockURLProtocol.answer(.response(status: 503, headers: ["Date": "Mon, 07 Dec 2026 10:00:00 GMT"], body: Data()))

        _ = send()

        XCTAssertEqual(offset.milliseconds, Self.epoch("Mon, 07 Dec 2026 10:00:00 GMT") - Self.deviceNow)
    }

    func testMalformedOrOutOfWindowDate_IsNotMeasured() {
        for date in ["yesterday", "Sun, 06 Nov 1994 08:49:37 GMT"] {
            MockURLProtocol.answer(.response(status: 204, headers: ["Date": date], body: Data()))
            _ = send()
        }

        XCTAssertEqual(offset.milliseconds, 0)
    }

    // MARK: - Helpers

    private func makeTransport() -> OtlpHttpTransport {
        OtlpHttpTransport(endpoint: Self.endpoint, clockOffset: offset, clientFactory: countingFactory())
    }

    private func countingFactory() -> @Sendable () -> any HTTPClient {
        { [factoryCount] in
            factoryCount.increment()
            return MockURLProtocol.makeClient()
        }
    }

    private func send() -> TransportResult {
        makeTransport().send(Data("payload".utf8), headers: Self.headers)
    }

    private static func epoch(_ date: String) -> Int64 {
        HttpDate.epochMilliseconds(date) ?? 0
    }

    private static func record() -> TelemetryRecord {
        let session = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
        let pending = PendingRecord(id: "\(session)-1", sessionId: session, event: TelemetryFixtures.sdkError(),
                                    createdAt: deviceNow)
        return Allowlist.filter(RecordFactory.create(pending, connection: .wifi))
    }
}
