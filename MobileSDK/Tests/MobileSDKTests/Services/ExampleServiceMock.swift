//
//  ExampleServiceMock.swift
//  MobileSDKTests
//
//  Created by Domagoj Grizelj on 13.07.2023..
//

import XCTest
@testable import MobileSDK

class ExampleServiceMock: Mockable, ExampleService {

    func getExample(id: Int) async throws -> Example {
        return loadJSON(filename: "example_response", type: Example.self)
    }

}
