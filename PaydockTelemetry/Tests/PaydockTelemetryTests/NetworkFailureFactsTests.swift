//
//  NetworkFailureFactsTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import PaydockTelemetry
import XCTest

/// R_02–R_06, R_08: one observation gives one network failure event, or none.
final class NetworkFailureFactsTests: XCTestCase {

    private typealias Facts = NetworkFailureFacts
    private typealias ErrorInfo = TelemetryEvent.ErrorInfo

    private static let timeoutInfo = ErrorInfo(type: "NetworkingLib.RequestError.connectionError", frames: [],
                                               cause: ErrorInfo(type: "NSError NSURLErrorDomain -1001", frames: []))

    private struct PlainError: Error {}

    // MARK: - Hosts

    func testTheApiHosts_AreTheThreeEnvironments() {
        XCTAssertEqual(Facts.apiHosts, ["api.paydock.com", "api-sandbox.paydock.com", "apista.paydock.com"])
        XCTAssertTrue(Facts.apiHosts.isSubset(of: Facts.reportableHosts))
    }

    func testEveryApiHost_IsReported() {
        for host in Facts.apiHosts {
            XCTAssertNotNil(Facts.event(NetworkObservations.observation(host: host, statusCode: 500), excludedHost: nil), host)
        }
    }

    func testAHostOutsideTheReportableSet_GivesNone() {
        for host in ["example.com", "api.paydock.com.evil.example", "API.PAYDOCK.COM", "otlp.invalid", ""] {
            XCTAssertNil(Facts.event(NetworkObservations.observation(host: host, statusCode: 500), excludedHost: nil), host)
        }
    }

    func testTheExcludedHost_GivesNone_EvenWhenReportable() {
        let observation = NetworkObservations.observation(statusCode: 500)

        XCTAssertNil(Facts.event(observation, excludedHost: NetworkObservations.sandboxHost))
        XCTAssertNotNil(Facts.event(observation, excludedHost: "otlp.invalid"))
    }

    #if DEBUG
    /// R_02, R_12: a debug build accepts the example app's stand-in hosts.
    func testAStandInHost_IsAccepted_InADebugBuild() throws {
        XCTAssertEqual(DebugStandInHosts.all, ["10.255.255.1", "127.0.0.1"])
        XCTAssertEqual(Facts.reportableHosts, Facts.apiHosts.union(DebugStandInHosts.all))
        for host in DebugStandInHosts.all {
            let event = Facts.event(NetworkObservations.observation(host: host, error: RequestError.connectionError(URLError(.timedOut))),
                                    excludedHost: nil)
            XCTAssertEqual(event, .networkFailure(method: .post, urlTemplate: "/v1/payment_sources/tokens", serverAddress: host,
                                                  failure: .transport(kind: .timeout, error: Self.timeoutInfo)))
        }
    }
    #endif

    // MARK: - No event

    func testASuccessfulAttempt_GivesNone() {
        XCTAssertNil(Facts.event(NetworkObservations.observation(statusCode: 200), excludedHost: nil))
        XCTAssertNil(Facts.event(NetworkObservations.observation(statusCode: 204), excludedHost: nil))
        XCTAssertNil(Facts.event(NetworkObservations.observation(statusCode: nil), excludedHost: nil))
    }

    func testACancellation_GivesNone_WrappedOrNot() {
        let cancellations: [Error] = [
            CancellationError(),
            URLError(.cancelled),
            NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled),
            RequestError.unknown(URLError(.cancelled)),
            RequestError.connectionError(URLError(.cancelled))
        ]
        for error in cancellations {
            XCTAssertNil(Facts.event(NetworkObservations.observation(error: error), excludedHost: nil), "\(error)")
        }
    }

    /// Every NetworkingLib method has a telemetry method of the same name, so no observation is dropped for its method.
    func testEveryRequestMethod_MapsToTheSameName() throws {
        let methods: [RequestMethod] = [.delete, .get, .patch, .post, .put]
        for method in methods {
            let event = try XCTUnwrap(Facts.event(NetworkObservations.observation(method: method, statusCode: 500),
                                                  excludedHost: nil))
            guard case let .networkFailure(mapped, _, _, _, _, _, _) = event else {
                return XCTFail("not a network failure")
            }
            XCTAssertEqual(mapped.rawValue, method.rawValue)
        }
    }

    // MARK: - HTTP status

    func testANon2xxStatus_GivesHttpStatus_WithTheBodysCodes() {
        let body = NetworkObservations.json(["status": 400, "error": ["code": "invalid_transaction_details",
                                                                     "message": SensitiveSamples.message]])
        let observation = NetworkObservations.observation(
            path: "/v1/payment_sources/tokens", statusCode: 400,
            error: RequestError.requestError(Self.errorRes()), errorBody: body
        )

        XCTAssertEqual(Facts.event(observation, excludedHost: nil), .networkFailure(
            method: .post, urlTemplate: "/v1/payment_sources/tokens", serverAddress: "api-sandbox.paydock.com",
            failure: .httpStatus(code: 400), attempt: 1,
            apiError: TelemetryEvent.APIError(status: 400, code: "invalid_transaction_details"), widget: nil
        ))
    }

    func testANon2xxStatusWithoutAnError_AndWithoutABody_GivesHttpStatus_NoApiError() {
        let observation = NetworkObservations.observation(method: .get, path: "/v1/gateways/63f0c1d2/wallet-config",
                                                          attempt: 2, statusCode: 503)

        XCTAssertEqual(Facts.event(observation, excludedHost: nil), .networkFailure(
            method: .get, urlTemplate: "/v1/gateways/{id}/wallet-config", serverAddress: "api-sandbox.paydock.com",
            failure: .httpStatus(code: 503), attempt: 2
        ))
    }

    func testTheAttempt_IsAtLeastOne() {
        let event = Facts.event(NetworkObservations.observation(attempt: 0, statusCode: 500), excludedHost: nil)

        XCTAssertEqual(event, .networkFailure(method: .post, urlTemplate: "/v1/payment_sources/tokens",
                                              serverAddress: "api-sandbox.paydock.com", failure: .httpStatus(code: 500),
                                              attempt: 1))
    }

    // MARK: - Decode

    func testADecodeFailure_GivesDecode_WithTheStatus_AndNoContext() throws {
        let context = DecodingFailureContext(kind: .keyNotFound, codingPath: "resource.\(SensitiveSamples.email)",
                                             summary: SensitiveSamples.message, debugDescription: SensitiveSamples.message)
        let observation = NetworkObservations.observation(statusCode: 201, error: RequestError.decode(context))

        let event = try XCTUnwrap(Facts.event(observation, excludedHost: nil))

        XCTAssertEqual(event, .networkFailure(
            method: .post, urlTemplate: "/v1/payment_sources/tokens", serverAddress: "api-sandbox.paydock.com",
            failure: .decode(statusCode: 201, error: ErrorInfo(type: "NetworkingLib.RequestError.decode", frames: []))
        ))
        XCTAssertFalse(String(describing: event).contains(SensitiveSamples.email))
        XCTAssertFalse(String(describing: event).contains(SensitiveSamples.message))
    }

    // MARK: - Transport

    func testAUrlError_RawOrInsideARequestError_GivesTransport() {
        /// A URL error, the kind it gives, and its error info.
        struct Case {
            let error: Error
            let kind: TelemetryEvent.TransportKind
            let info: ErrorInfo
        }
        func wrapped(_ type: String, _ cause: String) -> ErrorInfo {
            ErrorInfo(type: type, frames: [], cause: ErrorInfo(type: cause, frames: []))
        }
        let cases = [
            Case(error: URLError(.timedOut), kind: .timeout, info: ErrorInfo(type: "NSError NSURLErrorDomain -1001", frames: [])),
            Case(error: RequestError.connectionError(URLError(.notConnectedToInternet)), kind: .connection,
                 info: wrapped("NetworkingLib.RequestError.connectionError", "NSError NSURLErrorDomain -1009")),
            Case(error: RequestError.invalidRequest(URLError(.badURL)), kind: .unknown,
                 info: wrapped("NetworkingLib.RequestError.invalidRequest", "NSError NSURLErrorDomain -1000")),
            Case(error: RequestError.serverError(URLError(.badServerResponse)), kind: .unknown,
                 info: wrapped("NetworkingLib.RequestError.serverError", "NSError NSURLErrorDomain -1011")),
            Case(error: RequestError.unknown(URLError(.serverCertificateUntrusted)), kind: .tls,
                 info: wrapped("NetworkingLib.RequestError.unknown", "NSError NSURLErrorDomain -1202")),
            Case(error: RequestError.connectionError(URLError(.secureConnectionFailed)), kind: .tls,
                 info: wrapped("NetworkingLib.RequestError.connectionError", "NSError NSURLErrorDomain -1200"))
        ]
        for item in cases {
            let event = Facts.event(NetworkObservations.observation(error: item.error), excludedHost: nil)
            XCTAssertEqual(event, .networkFailure(method: .post, urlTemplate: "/v1/payment_sources/tokens",
                                                  serverAddress: "api-sandbox.paydock.com",
                                                  failure: .transport(kind: item.kind, error: item.info)), "\(item.error)")
        }
    }

    func testAnyOtherError_GivesUnknownTransport() {
        let cases: [(error: Error, type: String)] = [
            (RequestError.noResponse, "NetworkingLib.RequestError.noResponse"),
            (RequestError.invalidURL, "NetworkingLib.RequestError.invalidURL"),
            (RequestError.unexpectedErrorModel, "NetworkingLib.RequestError.unexpectedErrorModel"),
            (PlainError(), String(reflecting: PlainError.self)),
            (NSError(domain: "SampleDomain", code: 7), "NSError SampleDomain 7")
        ]
        for item in cases {
            let event = Facts.event(NetworkObservations.observation(error: item.error), excludedHost: nil)
            XCTAssertEqual(event, .networkFailure(method: .post, urlTemplate: "/v1/payment_sources/tokens",
                                                  serverAddress: "api-sandbox.paydock.com",
                                                  failure: .transport(kind: .unknown, error: ErrorInfo(type: item.type, frames: []))),
                           "\(item.error)")
        }
    }

    func testTransportKind_EveryListedCode() {
        XCTAssertEqual(Facts.transportKind(.timedOut), .timeout)
        let connection: [URLError.Code] = [.notConnectedToInternet, .networkConnectionLost, .cannotFindHost,
                                           .cannotConnectToHost, .dnsLookupFailed, .dataNotAllowed,
                                           .internationalRoamingOff, .callIsActive]
        let tls: [URLError.Code] = [.secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted,
                                    .serverCertificateHasUnknownRoot, .serverCertificateNotYetValid,
                                    .clientCertificateRejected, .clientCertificateRequired,
                                    .appTransportSecurityRequiresSecureConnection]
        for code in connection {
            XCTAssertEqual(Facts.transportKind(code), .connection, "\(code.rawValue)")
        }
        for code in tls {
            XCTAssertEqual(Facts.transportKind(code), .tls, "\(code.rawValue)")
        }
        for code in [URLError.Code.badURL, .badServerResponse, .unknown, .cancelled, .zeroByteResource] {
            XCTAssertEqual(Facts.transportKind(code), .unknown, "\(code.rawValue)")
        }
    }

    // MARK: - Error info

    func testErrorInfo_FollowsUnderlyingErrors_WithNoMessageOrUserInfoValue() {
        let inner = NSError(domain: "kCFErrorDomainCFNetwork", code: 310,
                            userInfo: [NSLocalizedDescriptionKey: SensitiveSamples.message])
        let urlError = URLError(.secureConnectionFailed, userInfo: [NSUnderlyingErrorKey: inner,
                                                                    NSLocalizedDescriptionKey: SensitiveSamples.email,
                                                                    "detail": SensitiveSamples.cardNumber])

        let info = Facts.errorInfo(RequestError.connectionError(urlError))

        XCTAssertEqual(info, ErrorInfo(type: "NetworkingLib.RequestError.connectionError", frames: [], cause: ErrorInfo(
            type: "NSError NSURLErrorDomain -1200", frames: [],
            cause: ErrorInfo(type: "NSError kCFErrorDomainCFNetwork 310", frames: [])
        )))
        let text = String(describing: info)
        for forbidden in [SensitiveSamples.message, SensitiveSamples.email, SensitiveSamples.cardNumber] {
            XCTAssertFalse(text.contains(forbidden), "a planted value reached the result")
        }
    }

    func testErrorInfo_StopsAfterMaxCauses() {
        var error = NSError(domain: "Sample", code: 0)
        for code in 1...20 {
            error = NSError(domain: "Sample", code: code, userInfo: [NSUnderlyingErrorKey: error])
        }

        let info = Facts.errorInfo(error)

        XCTAssertEqual(info.type, "NSError Sample 20")
        XCTAssertEqual(info.causeTypes.count, ErrorInfo.maxCauses)
        XCTAssertEqual(info.causeTypes.first, "NSError Sample 19")
        XCTAssertTrue(info.frames.isEmpty)
    }

    // MARK: - Helpers

    private static func errorRes() -> ErrorRes {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(ErrorRes.self, from: Data("{\"status\": 400}".utf8))
        } catch {
            preconditionFailure("ErrorRes did not decode: \(error)")
        }
    }
}
