//
//  TelemetryEndpoint.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// The collector request: a `POST` of the gzipped batch to the telemetry endpoint. Kept out of NetworkingLib's debug
/// log (`logsTraffic` false), so telemetry's own traffic never reaches the console.
package struct TelemetryEndpoint: Endpoint {
    package let scheme: String
    package let host: String
    package let path: String
    package let method: RequestMethod = .post
    package let header: [String: String]?
    package let body: Data?
    package let parameters: [URLQueryItem] = []
    package let mockFile: String? = nil
    package let bundle: Bundle? = nil
    package let logsTraffic = false

    /// Nil unless `url` is https with a host. The scheme, host and path come from the URL.
    package init?(url: String, header: [String: String], body: Data) {
        guard let components = URLComponents(string: url),
              components.scheme?.lowercased() == "https",
              let host = components.host, !host.isEmpty else {
            return nil
        }
        self.scheme = "https"
        self.host = host
        self.path = components.path
        self.header = header
        self.body = body
    }
}
