//
//  RequestError+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.09.2025..
//

import NetworkingLib

extension RequestError {
    public var uiMessage: String {
        switch self {
        case .connectionError(let urlError): return urlError.localizedDescription
        case .decode: return "Error while mapping a JSON response"
        case .invalidRequest(let urlError): return urlError.localizedDescription
        case .invalidURL: return "Invalid URL - please try again later"
        case .noResponse: return "No response received - - please try again later"
        case .serverError(let urlError): return urlError.localizedDescription
        case .unexpectedErrorModel: return "Unexpected error model - unable to decode JSON"
        case .requestError(let errorRes): return errorRes.error?.message ?? "Request error - please try again later"
        case .unknown(let urlError): return urlError.localizedDescription
        }
    }
}
