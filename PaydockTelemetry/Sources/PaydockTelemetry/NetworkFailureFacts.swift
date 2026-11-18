//
//  NetworkFailureFacts.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// One observation → one network failure event, or nil (R_02–R_06, R_08). Pure.
package enum NetworkFailureFacts {
    package static let apiHosts: Set<String> = ["api.paydock.com", "api-sandbox.paydock.com", "apista.paydock.com"]

    /// `apiHosts`; in a debug build also `DebugStandInHosts.all`. A release build has the three hosts only.
    package static var reportableHosts: Set<String> {
        #if DEBUG
        apiHosts.union(DebugStandInHosts.all)
        #else
        apiHosts
        #endif
    }

    /// Nil when: the host is `excludedHost`; the host is not in `reportableHosts`; the attempt succeeded (no error and
    /// a nil or 2xx status); the error is a cancellation (`CancellationError`, or a URL error with code `cancelled`,
    /// wrapped or not); the method has no `TelemetryEvent.HTTPMethod`. Otherwise `.networkFailure(method:,
    /// urlTemplate: RouteTemplates.template(path), serverAddress: host, failure:, attempt: max(1, attempt), apiError:,
    /// widget: nil)` where failure and apiError are:
    /// a non-2xx status → `.httpStatus(code:)`, `ApiErrorBody.apiError(from: errorBody)`;
    /// `RequestError.decode` → `.decode(statusCode: status, error: errorInfo(error))`, nil;
    /// a URL error (raw, or inside `connectionError`, `invalidRequest`, `serverError`, `unknown`) →
    /// `.transport(kind: transportKind(code), error: errorInfo(error))`, nil;
    /// anything else → `.transport(kind: .unknown, error: errorInfo(error))`, nil.
    package static func event(_ observation: RequestObservation, excludedHost: String?) -> TelemetryEvent? {
        let host = observation.host
        let status = observation.statusCode
        let isSuccessStatus = status.map { (200...299).contains($0) } ?? true
        guard host != excludedHost, reportableHosts.contains(host),
              observation.error != nil || !isSuccessStatus,
              !(observation.error.map(isCancellation) ?? false),
              let method = TelemetryEvent.HTTPMethod(rawValue: observation.method.rawValue) else {
            return nil
        }
        let failure: TelemetryEvent.NetworkError
        var apiError: TelemetryEvent.APIError?
        if let status, !isSuccessStatus {
            failure = .httpStatus(code: status)
            apiError = ApiErrorBody.apiError(from: observation.errorBody)
        } else if let error = observation.error {
            failure = transportOrDecode(error, status: status)
        } else {
            return nil
        }
        return .networkFailure(method: method, urlTemplate: RouteTemplates.template(observation.path),
                               serverAddress: host, failure: failure, attempt: max(1, observation.attempt),
                               apiError: apiError, widget: nil)
    }

    /// `timedOut` → timeout; `notConnectedToInternet`, `networkConnectionLost`, `cannotFindHost`,
    /// `cannotConnectToHost`, `dnsLookupFailed`, `dataNotAllowed`, `internationalRoamingOff`, `callIsActive` →
    /// connection; `secureConnectionFailed`, `serverCertificateHasBadDate`, `serverCertificateUntrusted`,
    /// `serverCertificateHasUnknownRoot`, `serverCertificateNotYetValid`, `clientCertificateRejected`,
    /// `clientCertificateRequired`, `appTransportSecurityRequiresSecureConnection` → tls; else unknown.
    package static func transportKind(_ code: URLError.Code) -> TelemetryEvent.TransportKind {
        switch code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed,
             .dataNotAllowed, .internationalRoamingOff, .callIsActive:
            return .connection
        case .secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted,
             .serverCertificateHasUnknownRoot, .serverCertificateNotYetValid, .clientCertificateRejected,
             .clientCertificateRequired, .appTransportSecurityRequiresSecureConnection:
            return .tls
        default:
            return .unknown
        }
    }

    /// Type: "NetworkingLib.RequestError.<case>" for a request error, "NSError <domain> <code>" for an NSError (a URL
    /// error included), else `String(reflecting: type(of:))`. Causes: a request error's URL error, then
    /// `NSUnderlyingErrorKey`, each written the same way, at most `ErrorInfo.maxCauses`. No frames. Never a message,
    /// user info value or `DecodingFailureContext`.
    package static func errorInfo(_ error: any Error) -> TelemetryEvent.ErrorInfo {
        TelemetryEvent.ErrorInfo(type: typeName(error), frames: [], cause: cause(after: error, depth: 0))
    }

    // MARK: - Helpers

    private static func transportOrDecode(_ error: any Error, status: Int?) -> TelemetryEvent.NetworkError {
        if case .decode = error as? RequestError {
            return .decode(statusCode: status, error: errorInfo(error))
        }
        if let urlError = urlError(in: error) {
            return .transport(kind: transportKind(urlError.code), error: errorInfo(error))
        }
        return .transport(kind: .unknown, error: errorInfo(error))
    }

    private static func isCancellation(_ error: any Error) -> Bool {
        error is CancellationError || urlError(in: error)?.code == .cancelled
    }

    /// The error itself when it is a URL error, or the one a request error carries.
    private static func urlError(in error: any Error) -> URLError? {
        if let urlError = error as? URLError {
            return urlError
        }
        switch error as? RequestError {
        case let .connectionError(urlError), let .invalidRequest(urlError), let .serverError(urlError),
             let .unknown(urlError):
            return urlError
        default:
            return nil
        }
    }

    private static func cause(after error: any Error, depth: Int) -> TelemetryEvent.ErrorInfo? {
        guard depth < TelemetryEvent.ErrorInfo.maxCauses, let next = next(after: error) else {
            return nil
        }
        return TelemetryEvent.ErrorInfo(type: typeName(next), frames: [], cause: cause(after: next, depth: depth + 1))
    }

    /// A request error's URL error; otherwise the error's `NSUnderlyingErrorKey`.
    private static func next(after error: any Error) -> (any Error)? {
        if let request = error as? RequestError {
            return urlError(in: request)
        }
        return (error as NSError).userInfo[NSUnderlyingErrorKey] as? Error
    }

    private static func typeName(_ error: any Error) -> String {
        if let request = error as? RequestError {
            return "NetworkingLib.RequestError.\(caseName(request))"
        }
        if let urlError = error as? URLError {
            return "NSError \(URLError.errorDomain) \(urlError.errorCode)"
        }
        if Swift.type(of: error) is NSError.Type {
            let nsError = error as NSError
            return "NSError \(nsError.domain) \(nsError.code)"
        }
        return String(reflecting: Swift.type(of: error))
    }

    private static func caseName(_ error: RequestError) -> String {
        switch error {
        case .connectionError: return "connectionError"
        case .decode: return "decode"
        case .invalidRequest: return "invalidRequest"
        case .invalidURL: return "invalidURL"
        case .noResponse: return "noResponse"
        case .serverError: return "serverError"
        case .unexpectedErrorModel: return "unexpectedErrorModel"
        case .requestError: return "requestError"
        case .unknown: return "unknown"
        }
    }
}
