//
//  Endpoint.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 11.07.2023..
//

import Foundation

protocol Endpoint {

    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }

}

extension Endpoint {

    var scheme: String {
        return "https"
    }

    var host: String {
    // TODO: - Move to proper base URL after testing
        return "api.themoviedb.org"
        //return Constants.baseURL
    }

}
