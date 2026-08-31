//
//  RequestError+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.09.2025..
//

import Foundation
import NetworkingLib

extension RequestError {
    /// Stable, machine-readable suffix identifying the *class* of networking failure. Combined by
    /// each widget error's `code` (e.g. `"APPLE_PAY_" + requestError.diagnosticCode`) so integrators
    /// can log/alert on a consistent token — most importantly distinguishing a response-decode
    /// failure (`RESPONSE_DECODE`) from a generic unknown.
    public var diagnosticCode: String {
        switch self {
        case .decode: return "RESPONSE_DECODE"
        case .unexpectedErrorModel: return "UNEXPECTED_RESPONSE_MODEL"
        case .noResponse: return "NO_RESPONSE"
        case .invalidURL: return "INVALID_URL"
        case .connectionError, .invalidRequest, .serverError, .unknown: return "NETWORK"
        case .requestError: return "SERVER_ERROR"
        }
    }

    /// Non-user-facing technical detail for logs — embeds the underlying cause. Distinct from
    /// `uiMessage` (which is a friendly, localised string shown to end users).
    public var technicalDescription: String {
        switch self {
        case .decode(let context):
            if let context {
                return "RequestError.decode (\(context.summary))"
            }
            return "RequestError.decode (response body did not match the expected model)"
        case .unexpectedErrorModel:
            return "RequestError.unexpectedErrorModel (error body did not match ErrorRes)"
        case .noResponse:
            return "RequestError.noResponse"
        case .invalidURL:
            return "RequestError.invalidURL"
        case .connectionError(let urlError):
            return "RequestError.connectionError(URLError code \(urlError.errorCode))"
        case .invalidRequest(let urlError):
            return "RequestError.invalidRequest(URLError code \(urlError.errorCode))"
        case .serverError(let urlError):
            return "RequestError.serverError(URLError code \(urlError.errorCode))"
        case .unknown(let urlError):
            return "RequestError.unknown(URLError code \(urlError.errorCode))"
        case .requestError(let errorRes):
            let code = errorRes.error?.code ?? errorRes.errorSummary?.code ?? "nil"
            return "RequestError.requestError(status: \(errorRes.status), code: \(code))"
        }
    }

    public var uiMessage: String {
        switch self {
        case .connectionError(let urlError):
            return urlError.userFriendlyMessage
        case .decode:
            return "Unable to process server response. Please try again later."
        case .invalidRequest(let urlError):
            return urlError.userFriendlyMessage
        case .invalidURL:
            return "Invalid request. Please try again later."
        case .noResponse:
            return "No response from server. Please check your connection and try again."
        case .serverError(let urlError):
            return urlError.userFriendlyMessage
        case .unexpectedErrorModel:
            return "Unexpected server response. Please try again later."
        case .requestError(let errorRes):
            return errorRes.error?.message ?? "Request failed. Please try again later."
        case .unknown(let urlError):
            return urlError.userFriendlyMessage
        }
    }
}

extension URLError {
    var userFriendlyMessage: String {
        switch code {
        case .timedOut:
            return "The request timed out. Please check your connection and try again."
        case .notConnectedToInternet:
            return "The Internet connection appears to be offline. Please check your network."
        case .networkConnectionLost:
            return "The network connection was lost. Please try again."
        case .cannotFindHost:
            return "The server could not be found. Please check the address and try again."
        case .cannotConnectToHost, .dnsLookupFailed:
            return "Could not connect to the server. Please try again."
        case .secureConnectionFailed:
            return "A secure connection could not be established. Please try again."
        case .serverCertificateUntrusted, .serverCertificateHasBadDate, .serverCertificateNotYetValid, .serverCertificateHasUnknownRoot:
            return "Server certificate error. Please try again later."
        case .cancelled:
            return "The request was cancelled."
        case .badServerResponse:
            return "Invalid server response. Please try again later."
        case .resourceUnavailable:
            return "Service temporarily unavailable. Please try again later."
        case .httpTooManyRedirects:
            return "Request failed. Please try again later."
        case .dataNotAllowed:
            return "Cellular data is not allowed for this app. Please use Wi-Fi or enable data."
        case .internationalRoamingOff:
            return "Data roaming is off. Please enable it or connect to Wi-Fi."
        default:
            return "Connection error. Please check your connection and try again."
        }
    }
}
