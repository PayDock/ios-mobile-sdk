//
//  NetworkObservations.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Synthetic request observations and endpoints for the network failure tests. No real card, token or ID.
enum NetworkObservations {
    static let sandboxHost = "api-sandbox.paydock.com"

    static func observation(
        method: RequestMethod = .post,
        host: String = sandboxHost,
        path: String = "/v1/payment_sources/tokens",
        attempt: Int = 1,
        statusCode: Int? = nil,
        responseHeaders: [String: String] = [:],
        error: Error? = nil,
        errorBody: Data? = nil
    ) -> RequestObservation {
        let started = Date(timeIntervalSince1970: 1_793_852_047)
        return RequestObservation(method: method, host: host, path: path, attempt: attempt, startedAt: started,
                                  endedAt: started.addingTimeInterval(0.25), statusCode: statusCode,
                                  responseHeaders: responseHeaders, error: error, errorBody: errorBody)
    }

    /// A JSON body.
    static func json(_ object: Any) -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        } catch {
            preconditionFailure("not JSON: \(error)")
        }
    }

    /// An SDK-shaped endpoint on an explicit host.
    struct TestEndpoint: Endpoint {
        var host: String = sandboxHost
        var path: String = "/v1/payment_sources/tokens"
        var method: RequestMethod = .post
        var header: [String: String]? = ["Content-Type": "application/json"]
        var body: Data?
        var parameters: [URLQueryItem] = []
        var mockFile: String?
        var bundle: Bundle?
        /// Off, so NetworkingLib's debug log never prints a planted value.
        var logsTraffic = false
    }

    /// Any decodable answer.
    struct Answer: Decodable {
        let resource: String
    }
}
