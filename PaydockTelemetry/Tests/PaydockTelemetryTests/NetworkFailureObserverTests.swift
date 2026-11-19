//
//  NetworkFailureObserverTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import PaydockTelemetry
import XCTest

/// R_01, R_09: the observer, through NetworkingLib's real `HTTPClient` over `MockURLProtocol`. The observer is
/// installed in a test slot that also sets `NetworkingLib.shared.requestObserver` and restores it after each test.
final class NetworkFailureObserverTests: XCTestCase {

    /// The events the observer reported, from whichever thread ran the attempt.
    private final class ReportedEvents: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [TelemetryEvent] = []

        var events: [TelemetryEvent] {
            lock.lock()
            defer { lock.unlock() }
            return items
        }

        func append(_ event: TelemetryEvent) {
            lock.lock()
            items.append(event)
            lock.unlock()
        }
    }

    private typealias Endpoint = NetworkObservations.TestEndpoint
    private typealias ErrorInfo = TelemetryEvent.ErrorInfo

    private static let telemetryHost = URL(string: TelemetryFixtures.endpoint)?.host
    private static let realId = "5f8a1c2e9b3d4a6f7e8c9d0a"

    private let slot = FakeRequestObserverSlot(alsoSetsTheLibrary: true)
    private let reported = ReportedEvents()
    private let client = MockURLProtocol.makeClient()

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
    }

    override func tearDown() {
        slot.restoreTheLibrary()
        MockURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - One event per failed attempt

    func testA4xxWithAnApiBody_GivesOneEvent_WithTheBodysCodes() async throws {
        install()
        MockURLProtocol.answer(.response(status: 400, headers: ["Content-Type": "application/json"], body: Self.apiBody()))

        await send(Endpoint(path: "/v1/payment_sources/tokens", method: .post))

        XCTAssertEqual(reported.events, [.networkFailure(
            method: .post, urlTemplate: "/v1/payment_sources/tokens", serverAddress: "api-sandbox.paydock.com",
            failure: .httpStatus(code: 400), attempt: 1,
            apiError: TelemetryEvent.APIError(status: 400, code: "invalid_transaction_details",
                                              summaryCode: "invalid_transaction_details",
                                              gatewayCodes: ["INVALID_REQUEST:INVALID:sourceOfFunds.provided.card.securityCode"])
        )])
    }

    func testA5xx_GivesOneEvent() async throws {
        install()
        MockURLProtocol.answer(.response(status: 503, headers: [:], body: Data("Service Unavailable".utf8)))

        await send(Endpoint(path: "/v1/gateways/\(Self.realId)/wallet-config", method: .get))

        XCTAssertEqual(reported.events, [.networkFailure(
            method: .get, urlTemplate: "/v1/gateways/{id}/wallet-config", serverAddress: "api-sandbox.paydock.com",
            failure: .httpStatus(code: 503)
        )])
    }

    func testATimeout_GivesOneTimeoutEvent() async throws {
        install()
        MockURLProtocol.answer(.silence)

        await send(Endpoint(path: "/v1/charges/wallet/capture"), timeout: 0.3)

        XCTAssertEqual(reported.events, [.networkFailure(
            method: .post, urlTemplate: "/v1/charges/wallet/capture", serverAddress: "api-sandbox.paydock.com",
            failure: .transport(kind: .timeout, error: ErrorInfo(
                type: "NetworkingLib.RequestError.connectionError", frames: [],
                cause: ErrorInfo(type: "NSError NSURLErrorDomain -1001", frames: [])
            ))
        )])
    }

    func testAnOfflineFailure_GivesOneConnectionEvent() async throws {
        install()
        MockURLProtocol.answer(.error(.notConnectedToInternet))

        await send(Endpoint(path: "/v1/payment_sources/external_checkout"))

        let event = try XCTUnwrap(reported.events.first)
        XCTAssertEqual(reported.events.count, 1)
        guard case let .networkFailure(method, template, host, .transport(kind, error), attempt, apiError, widget) = event else {
            return XCTFail("not a transport failure")
        }
        XCTAssertEqual(method, .post)
        XCTAssertEqual(template, "/v1/payment_sources/external_checkout")
        XCTAssertEqual(host, "api-sandbox.paydock.com")
        XCTAssertEqual(kind, .connection)
        XCTAssertEqual(error?.type, "NetworkingLib.RequestError.connectionError")
        XCTAssertEqual(error?.causeTypes.first, "NSError NSURLErrorDomain -1009")
        XCTAssertEqual(error?.frames, [])
        XCTAssertEqual(attempt, 1)
        XCTAssertNil(apiError)
        XCTAssertNil(widget)
    }

    func testA2xx_GivesNone() async throws {
        install()
        MockURLProtocol.answer(.response(status: 200, headers: [:], body: Data("{\"resource\": \"ok\"}".utf8)))

        await send(Endpoint())

        XCTAssertEqual(reported.events, [])
    }

    func testADecodeFailure_GivesDecode_WithTheStatus() async throws {
        install()
        MockURLProtocol.answer(.response(status: 201, headers: [:], body: Data("{}".utf8)))

        await send(Endpoint(path: "/v1/payment_sources/setup-tokens"))

        XCTAssertEqual(reported.events, [.networkFailure(
            method: .post, urlTemplate: "/v1/payment_sources/setup-tokens", serverAddress: "api-sandbox.paydock.com",
            failure: .decode(statusCode: 201, error: ErrorInfo(type: "NetworkingLib.RequestError.decode", frames: []))
        )])
    }

    func testAnotherHost_AndTheTelemetryEndpointsHost_GiveNone() async throws {
        install()
        MockURLProtocol.answer(.response(status: 500, headers: [:], body: Data()))

        await send(Endpoint(host: "example.com"))
        await send(Endpoint(host: try XCTUnwrap(Self.telemetryHost), path: "/v1/logs"))

        XCTAssertEqual(reported.events, [])
    }

    /// The excluded host wins even when it is an API host.
    func testTheExcludedHost_GivesNone_EvenOnAnApiHost() async throws {
        install(excludedHost: "api-sandbox.paydock.com")
        MockURLProtocol.answer(.response(status: 500, headers: [:], body: Data()))

        await send(Endpoint())

        XCTAssertEqual(reported.events, [])
        XCTAssertEqual(MockURLProtocol.requests.count, 1)
    }

    func testARetriedConnectionFailure_GivesAttemptsOneAndTwo() async throws {
        install()
        MockURLProtocol.answer(.error(.networkConnectionLost))

        await send(Endpoint(path: "/v1/charges/wallet/callback", parameters: [URLQueryItem(name: "mobile", value: "true")]),
                   maxRetries: 1)

        XCTAssertEqual(MockURLProtocol.requests.count, 2)
        let attempts = reported.events.compactMap { event -> Int? in
            guard case let .networkFailure(_, template, _, .transport(.connection, _), attempt, _, _) = event,
                  template == "/v1/charges/wallet/callback" else {
                return nil
            }
            return attempt
        }
        XCTAssertEqual(attempts, [1, 2])
    }

    /// A real ID in the path, a query, a card-like body and token-like headers reach no field of the event or of the
    /// record built from it.
    func testPlantedValues_ReachNoFieldOfTheEventOrTheRecord() async throws {
        install()
        let planted = "\(SensitiveSamples.message) \(SensitiveSamples.cardNumber) \(SensitiveSamples.email)"
        let responseBody = NetworkObservations.json([
            "status": 400,
            "error": ["message": planted, "code": "invalid_card",
                      "details": ["path": planted, "messages": [["gateway_specific_code": "G1", "description": planted,
                                                                 "gateway_specific_description": planted]]]],
            "error_summary": ["message": planted, "code": "invalid_card"]
        ])
        MockURLProtocol.answer(.response(status: 400, headers: ["Set-Cookie": "session=\(SensitiveSamples.jwt)",
                                                                "X-Echo": SensitiveSamples.bearer],
                                         body: responseBody))
        let endpoint = Endpoint(
            path: "/v1/charges/wallet/\(Self.realId)/decline",
            header: ["Authorization": SensitiveSamples.bearer, "x-access-token": SensitiveSamples.jwt],
            body: NetworkObservations.json(["card_number": SensitiveSamples.cardNumber, "email": SensitiveSamples.email]),
            parameters: [URLQueryItem(name: "reference", value: SensitiveSamples.groupedCardNumber)]
        )

        await send(endpoint)

        let event = try XCTUnwrap(reported.events.first)
        XCTAssertEqual(reported.events.count, 1)
        let record = RecordFactory.create(PendingRecord(id: "\(SensitiveSamples.sessionId)-1", sessionId: SensitiveSamples.sessionId,
                                                        event: event, createdAt: SensitiveSamples.builtAt), connection: .wifi)
        XCTAssertEqual(record.value("url.template"), .string("/v1/charges/wallet/{id}/decline"))
        XCTAssertEqual(record.value("paydock.api.gateway.codes"), .string("G1"))
        let texts = [String(describing: event), record.body] + record.attributes.map { String(describing: $0.value) }
        let forbidden = [Self.realId, SensitiveSamples.cardNumber, SensitiveSamples.groupedCardNumber, SensitiveSamples.email,
                         SensitiveSamples.message, SensitiveSamples.jwt, SensitiveSamples.bearer, "reference", "session="]
        for (index, value) in forbidden.enumerated() {
            XCTAssertFalse(texts.contains { $0.contains(value) }, "planted value \(index) reached the event or the record")
        }
        XCTAssertEqual(Allowlist.filter(record), record)
    }

    // MARK: - Keep and forward

    func testThePreviousObserver_ReceivesEveryObservation() async throws {
        let previous = RecordingRequestObserver()
        install(previous: previous)

        MockURLProtocol.answer(.response(status: 200, headers: [:], body: Data("{\"resource\": \"ok\"}".utf8)))
        await send(Endpoint())
        MockURLProtocol.answer(.response(status: 500, headers: [:], body: Data()))
        await send(Endpoint())
        await send(Endpoint(host: "example.com"))
        MockURLProtocol.answer(.error(.notConnectedToInternet))
        await send(Endpoint(), maxRetries: 1)

        XCTAssertEqual(previous.observations.map(\.statusCode), [200, 500, 500, nil, nil])
        XCTAssertEqual(previous.observations.map(\.host), ["api-sandbox.paydock.com", "api-sandbox.paydock.com", "example.com",
                                                           "api-sandbox.paydock.com", "api-sandbox.paydock.com"])
        XCTAssertEqual(previous.observations.map(\.attempt), [1, 1, 1, 1, 2])
        XCTAssertEqual(reported.events.count, 3)
    }

    // MARK: - Never on the caller's thread

    /// `requestDidFinish` only hands the event to the dispatcher: the reducer has not run when the request returns.
    func testRequestDidFinish_ReturnsWithoutRunningTheReducer() async throws {
        let dispatcher = QueueingDispatcher()
        let store = RecordingDurableStore()
        let telemetry = ActiveTelemetry(endpoint: TelemetryFixtures.endpoint,
                                        deviceContextProvider: FakeDeviceContextProvider(), dispatcher: dispatcher,
                                        ports: ActiveTelemetry.Ports(store: store, requestObservers: slot))
        telemetry.start()
        XCTAssertEqual(slot.setCount, 1)
        let queuedAfterStart = dispatcher.queuedCount
        MockURLProtocol.answer(.response(status: 502, headers: [:], body: Data()))

        await send(Endpoint())

        XCTAssertEqual(dispatcher.queuedCount, queuedAfterStart + 1)
        XCTAssertEqual(telemetry.currentState().pending, 0)
        XCTAssertEqual(store.saved, [])
        dispatcher.runQueued()
        XCTAssertEqual(store.saved.map(\.eventName), ["paydock.network.failure"])
        XCTAssertEqual(store.saved.first?.value("http.response.status_code"), .int(502))
    }

    // MARK: - Helpers

    private func install(previous: (any RequestObserver)? = nil, excludedHost: String? = NetworkFailureObserverTests.telemetryHost) {
        slot.set(NetworkFailureObserver(report: { [reported] in reported.append($0) }, excludedHost: excludedHost,
                                        previous: previous))
    }

    /// Sends the request through the real client; its outcome is not the subject.
    private func send(_ endpoint: Endpoint, timeout: TimeInterval = 5, maxRetries: Int = 0) async {
        _ = try? await client.sendRequest(endpoint: endpoint, responseModel: NetworkObservations.Answer.self, timeout: timeout,
                                          maxRetries: maxRetries)
    }

    /// The shared `http-error` fixture's codes, as the API writes them.
    private static func apiBody() -> Data {
        NetworkObservations.json([
            "status": 400,
            "error": ["message": SensitiveSamples.message, "code": "invalid_transaction_details",
                      "details": ["messages": [["gateway_specific_code": "INVALID_REQUEST:INVALID:sourceOfFunds.provided.card.securityCode",
                                                "description": SensitiveSamples.message]]]],
            "error_summary": ["message": SensitiveSamples.message, "code": "invalid_transaction_details"]
        ])
    }
}
