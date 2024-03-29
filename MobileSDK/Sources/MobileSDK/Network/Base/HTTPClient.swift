//
//  HTTPClient.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.07.2023..
//

import Foundation

protocol HTTPClient {

    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T

}

extension HTTPClient {

    // MARK: - Variables

    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300

        return URLSession(configuration: configuration, delegate: sslPinningManager, delegateQueue: nil)
    }

    var sslPinningManager: SSLPinningManager {
        return SSLPinningManager()
    }

    // MARK: - Default implementation

    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path

        guard let url = urlComponents.url else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header

        if let body = endpoint.body {
            request.httpBody = body
        }

        do {
            NetworkLogger.log(request: request)
            let (data, response) = try await session.data(for: request, delegate: nil)
            NetworkLogger.log(data: data, response: response as? HTTPURLResponse, error: nil)

            guard let response = response as? HTTPURLResponse else {
                throw RequestError.noResponse
            }

            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
                    throw RequestError.decode
                }
                return decodedResponse

            case 401:
                throw RequestError.unauthorized

            default:
                throw RequestError.unexpectedStatusCode
            }

        } catch {
            throw RequestError.unknown
        }
    }

}
