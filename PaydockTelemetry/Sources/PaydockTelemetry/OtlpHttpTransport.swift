//
//  OtlpHttpTransport.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Posts a payload through telemetry's own NetworkingLib client (R_03): one attempt, any status back with its headers,
/// `TelemetryLimits.requestTimeoutSeconds`. Every response's `Date` header measures the clock offset (R_04). The client
/// is built on the first send, never otherwise.
package final class OtlpHttpTransport: TelemetryTransport, @unchecked Sendable {
    private static let maxPartialSuccessBytes = 65_536

    /// Carries the response, or the failure's result, from the request's task back to the blocked caller.
    private final class Outcome: @unchecked Sendable {
        private let lock = NSLock()
        private var storedResponse: RawResponse?
        private var storedFailure: TransportResult = .failure

        var response: RawResponse? {
            lock.lock()
            defer { lock.unlock() }
            return storedResponse
        }

        var failure: TransportResult {
            lock.lock()
            defer { lock.unlock() }
            return storedFailure
        }

        func succeed(_ response: RawResponse) {
            lock.lock()
            storedResponse = response
            lock.unlock()
        }

        func fail(_ result: TransportResult) {
            lock.lock()
            storedFailure = result
            lock.unlock()
        }
    }

    private let endpoint: String
    private let clockOffset: ClockOffset
    private let clientFactory: @Sendable () -> any HTTPClient
    private let waitLimitSeconds: TimeInterval
    private let lock = NSLock()
    private var builtClient: (any HTTPClient)?

    package init(endpoint: String, clockOffset: ClockOffset,
                 clientFactory: @escaping @Sendable () -> any HTTPClient = { TelemetryHTTPClient() },
                 waitLimitSeconds: TimeInterval = TelemetryLimits.requestTimeoutSeconds + 5) {
        self.endpoint = endpoint
        self.clockOffset = clockOffset
        self.clientFactory = clientFactory
        self.waitLimitSeconds = waitLimitSeconds
    }

    /// Blocks the calling thread (the telemetry queue, never the main thread) until the request ends, or for at most
    /// `waitLimitSeconds` (by default the request timeout plus 5 s), which is a `.timeout`: the session's own timeouts
    /// end every request first, so the limit only guards the queue against a request task that never runs.
    package func send(_ payload: Data, headers: [String: String]) -> TransportResult {
        guard let target = TelemetryEndpoint(url: endpoint, header: headers, body: payload) else {
            return .failure
        }
        let client = client()
        let outcome = Outcome()
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                let response = try await client.sendRequestForAnyStatus(endpoint: target,
                                                                        timeout: TelemetryLimits.requestTimeoutSeconds)
                outcome.succeed(response)
            } catch {
                outcome.fail(Self.result(of: error))
            }
            semaphore.signal()
        }
        guard semaphore.wait(timeout: .now() + waitLimitSeconds) == .success else {
            return .timeout
        }
        guard let response = outcome.response else {
            return outcome.failure
        }
        return result(of: response)
    }

    // MARK: - Mapping

    private func result(of response: RawResponse) -> TransportResult {
        if let date = response.headerValue("Date").flatMap(HttpDate.epochMilliseconds) {
            clockOffset.measure(serverDateMilliseconds: date)
        }
        let status = response.statusCode
        guard (200...299).contains(status) else {
            return .httpError(status: status, retryAfterMilliseconds: Self.retryAfter(response.headerValue("Retry-After")))
        }
        return .success(status: status, rejectedRecords: Self.rejectedRecords(response.data))
    }

    /// `partialSuccess.rejectedLogRecords` of a JSON body of at most 64 KB, a string or a number; 0 otherwise. The
    /// partial success's error message is never read.
    private static func rejectedRecords(_ body: Data) -> Int64 {
        guard !body.isEmpty, body.count <= maxPartialSuccessBytes,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
              let partial = json["partialSuccess"] as? [String: Any] else {
            return 0
        }
        let count: Int64?
        switch partial["rejectedLogRecords"] {
        case let text as String:
            count = Int64(text)
        case let number as NSNumber:
            count = Int64(exactly: number.doubleValue)
        default:
            count = nil
        }
        return max(0, count ?? 0)
    }

    /// Non-negative integer seconds × 1000; nil for anything else, an HTTP date included.
    private static func retryAfter(_ value: String?) -> Int64? {
        guard let text = value?.trimmingCharacters(in: .whitespaces), !text.isEmpty,
              text.allSatisfy({ $0.isASCII && $0.isNumber }), let seconds = Int64(text) else {
            return nil
        }
        let (milliseconds, overflow) = seconds.multipliedReportingOverflow(by: 1_000)
        return overflow ? nil : milliseconds
    }

    private static func result(of error: any Error) -> TransportResult {
        guard let requestError = error as? RequestError else {
            return .failure
        }
        switch requestError {
        case let .connectionError(urlError):
            return urlError.code == .timedOut ? .timeout : .connectionFailure
        case let .serverError(urlError), let .invalidRequest(urlError), let .unknown(urlError):
            return isConnectivityOrTLS(urlError.code) ? .connectionFailure : .failure
        default:
            return .failure
        }
    }

    private static func isConnectivityOrTLS(_ code: URLError.Code) -> Bool {
        let codes: Set<URLError.Code> = [
            .notConnectedToInternet, .cannotFindHost, .cannotConnectToHost, .networkConnectionLost, .dnsLookupFailed,
            .internationalRoamingOff, .callIsActive, .dataNotAllowed, .secureConnectionFailed,
            .serverCertificateHasBadDate, .serverCertificateUntrusted, .serverCertificateHasUnknownRoot,
            .serverCertificateNotYetValid, .clientCertificateRejected, .clientCertificateRequired,
            .appTransportSecurityRequiresSecureConnection
        ]
        return codes.contains(code)
    }

    // MARK: - Client

    /// Built on the first send, then reused.
    private func client() -> any HTTPClient {
        lock.lock()
        defer { lock.unlock() }
        if let builtClient {
            return builtClient
        }
        let client = clientFactory()
        builtClient = client
        return client
    }
}
