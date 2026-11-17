//
//  SdkErrorFacts.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib
import PaydockTelemetry

/// What telemetry reads from an SDK error: types, codes, case names and `NSError` domains with codes, never text.
enum SdkErrorFacts {
    /// `exception.type`: a `RequestError` → "NetworkingLib.RequestError.<case>"; an `NSError` (an error whose
    /// `type(of:)` is `NSError` or a subclass, `URLError` included) → "NSError <domain> <code>"; anything else →
    /// `String(reflecting: type(of: error))`.
    static func typeName(of error: any Error) -> String {
        if let requestError = error as? RequestError {
            return "NetworkingLib.RequestError." + caseName(of: requestError)
        }
        if error is URLError || type(of: error) is NSError.Type {
            let nsError = error as NSError
            return "NSError \(nsError.domain) \(nsError.code)"
        }
        return String(reflecting: type(of: error))
    }

    /// The type, no frames (the site gives them), and the cause chain: `telemetryCause` for a facts error, the
    /// `URLError` of a `RequestError` case that holds one, else `NSUnderlyingErrorKey`; at most
    /// `ErrorInfo.maxCauses`, so a loop ends.
    static func errorInfo(_ error: any Error) -> TelemetryEvent.ErrorInfo {
        TelemetryEvent.ErrorInfo(type: typeName(of: error), frames: [], cause: causeInfo(of: cause(of: error), depth: 0))
    }

    /// `telemetryCode` for a facts error, `WidgetError.code` for another widget error, else nil.
    static func code(_ error: any Error) -> String? {
        if let facts = error as? any TelemetryErrorFacts {
            return facts.telemetryCode
        }
        if let widgetError = error as? any WidgetError {
            return widgetError.code
        }
        return nil
    }

    /// True for a `RequestError` itself or a facts error whose `isRequestCaused` is true.
    static func isRequestCaused(_ error: any Error) -> Bool {
        if error is RequestError {
            return true
        }
        return (error as? any TelemetryErrorFacts)?.isRequestCaused ?? false
    }

    private static func causeInfo(of error: (any Error)?, depth: Int) -> TelemetryEvent.ErrorInfo? {
        guard depth < TelemetryEvent.ErrorInfo.maxCauses, let error else {
            return nil
        }
        return TelemetryEvent.ErrorInfo(type: typeName(of: error), frames: [],
                                        cause: causeInfo(of: cause(of: error), depth: depth + 1))
    }

    private static func cause(of error: any Error) -> (any Error)? {
        if let facts = error as? any TelemetryErrorFacts {
            return facts.telemetryCause
        }
        if let requestError = error as? RequestError, let urlError = urlError(of: requestError) {
            return urlError
        }
        return (error as NSError).userInfo[NSUnderlyingErrorKey] as? any Error
    }

    private static func urlError(of requestError: RequestError) -> URLError? {
        switch requestError {
        case let .connectionError(urlError), let .invalidRequest(urlError), let .serverError(urlError),
             let .unknown(urlError):
            return urlError
        case .decode, .invalidURL, .noResponse, .unexpectedErrorModel, .requestError:
            return nil
        }
    }

    private static func caseName(of requestError: RequestError) -> String {
        switch requestError {
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
