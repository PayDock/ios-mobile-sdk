//
//  ExampleEndpoint.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

enum ExampleEndpoint {

    case example(id: Int)

}

extension ExampleEndpoint: Endpoint {

    var path: String {
        switch self {
        case .example(let id):
            return "/something/example/\(id)"
        }
    }

    var method: RequestMethod {
        switch self {
        case .example: return .get
        }
    }

    var header: [String: String]? {
        // Access Token to use in Bearer header
        let accessToken = "some token"
        switch self {
        case .example:
            return [
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: [String: String]? {
        switch self {
        case .example: return nil
        }
    }
    
}
