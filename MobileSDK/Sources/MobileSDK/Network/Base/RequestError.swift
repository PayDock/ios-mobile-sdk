//
//  RequestError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unexpectedErrorModel
    case requestError(_ errorResponse: ErrorRes)
    case unknown

    var customMessage: String {
        switch self {
        case .decode: return "Error while mapping a JSON response"
        case .invalidURL: return "Invalid URL"
        case .noResponse: return "Response timeout"
        case .unauthorized: return "Unauthorized - missing or invalid access key"
        case .unexpectedStatusCode: return "Unexpected status code received"
        case .unexpectedErrorModel: return "Unexpected error model - unable to decode JSON"
        case .requestError(let errorRes): return errorRes.error?.message ?? "Request error"
        case .unknown: return "Unknown error"
        }
    }
}
