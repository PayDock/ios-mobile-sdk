//
//  ExampleService.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

protocol ExampleService {

    func getExample(id: Int) async throws -> Example

}

struct ExampleServiceImpl: HTTPClient, ExampleService {

    func getExample(id: Int) async throws -> Example {
        return try await sendRequest(endpoint: ExampleEndpoint.example(id: id), responseModel: Example.self)
    }

}
