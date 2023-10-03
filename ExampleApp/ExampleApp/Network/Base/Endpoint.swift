//
//  Endpoint.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

protocol Endpoint {

    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var body: Data? { get }
    var parameters: [URLQueryItem] { get }

}

extension Endpoint {

    var scheme: String {
        return "https"
    }

    var host: String {
        return ProjectEnvironment.shared.getEnvironmentEndpoint(for: ProjectEnvironment.shared.environment.rawValue)
    }

}
