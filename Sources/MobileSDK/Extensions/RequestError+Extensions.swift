//
//  RequestError+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.09.2025..
//

import Foundation
import NetworkingLib

extension RequestError {
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
