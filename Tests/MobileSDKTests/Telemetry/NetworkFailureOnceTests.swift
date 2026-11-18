//
//  NetworkFailureOnceTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation
import XCTest
@testable import DataGateways
@testable import MobileSDK
import NetworkingLib
import PaydockTelemetry

/// R_10: an SDK call that fails with a request error is recorded once, as a network failure, and never also as an SDK
/// error. `PayPalDataCollectorUtil.initialise` runs over NetworkingLib's real `HTTPClient` and a scripted session,
/// with `RecordingTelemetry` bound and a `NetworkFailureObserver` reporting to it.
final class NetworkFailureOnceTests: XCTestCase {

    private static let host = "api-sandbox.paydock.com"
    /// Synthetic, never real.
    private static let gatewayId = "8c3d4e5f60718293a4b5c6d7"
    private static let accessToken = "synthetic-widget-token"

    private let telemetry = RecordingTelemetry()
    private var observerBefore: (any RequestObserver)?
    private var hostBefore = ""

    override func setUp() {
        super.setUp()
        observerBefore = NetworkingLib.shared.requestObserver
        hostBefore = NetworkingLib.shared.host
        NetworkingLib.shared.host = Self.host
        telemetry.bindAsCurrent()
        let telemetry = self.telemetry
        NetworkingLib.shared.requestObserver = NetworkFailureObserver(report: { telemetry.report($0) },
                                                                      excludedHost: nil, previous: observerBefore)
    }

    override func tearDown() {
        NetworkingLib.shared.requestObserver = observerBefore
        NetworkingLib.shared.host = hostBefore
        RecordingTelemetry.unbind()
        ScriptedURLProtocol.reply = nil
        super.tearDown()
    }

    func testARequestErrorThroughTheSdk_GivesOneNetworkFailure_AndNoSdkError() async {
        ScriptedURLProtocol.reply = (status: 400, body: Data(#"""
        {"status":400,"error":{"message":"synthetic","code":"access_forbidden"}}
        """#.utf8))
        let config = PayPalDataCollectorConfig(accessToken: Self.accessToken, gatewayId: Self.gatewayId)

        do {
            _ = try await PayPalDataCollectorUtil.initialise(config: config, service: ScriptedGatewayService())
            XCTFail("Expected the 400 to fail the call")
        } catch {
            XCTAssertTrue(error is PayPalDataCollectorError, "\(error)")
        }

        XCTAssertEqual(telemetry.events, [.networkFailure(
            method: .get, urlTemplate: "/v1/gateways/{id}/wallet-config", serverAddress: Self.host,
            failure: .httpStatus(code: 400), attempt: 1,
            apiError: TelemetryEvent.APIError(status: 400, code: "access_forbidden"), widget: nil
        )])
        XCTAssertEqual(telemetry.sdkErrors, [])
    }
}

/// `GatewayServiceImpl.getClientId` as written, on a session that answers from `ScriptedURLProtocol`.
private struct ScriptedGatewayService: HTTPClient, GatewayService {
    let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ScriptedURLProtocol.self]
        return URLSession(configuration: configuration)
    }()

    var sslPinningManager: SSLPinningManager? { nil }

    func getClientId(gatewayId: String, widgetAccessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: GatewayEndpoints.clientId(gatewayId: gatewayId, widgetAccessToken: widgetAccessToken),
            responseModel: PayPalConfigRes.self,
            timeout: 60,
            maxRetries: 1)
        return response.resource.data.credentials.clientAuth
    }
}

/// Answers every request with the scripted status and body. No network.
private final class ScriptedURLProtocol: URLProtocol {
    private static let lock = NSLock()
    private static var scripted: (status: Int, body: Data)?

    static var reply: (status: Int, body: Data)? {
        get { lock.withLock { scripted } }
        set { lock.withLock { scripted = newValue } }
    }

    override static func canInit(with request: URLRequest) -> Bool { true }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let reply = Self.reply, let url = request.url,
              let response = HTTPURLResponse(url: url, statusCode: reply.status, httpVersion: "HTTP/1.1",
                                             headerFields: ["Content-Type": "application/json"]) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: reply.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
#endif
