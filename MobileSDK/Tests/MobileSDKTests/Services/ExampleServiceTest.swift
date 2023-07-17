//
//  ExampleServiceTest.swift
//  
//
//  Created by Domagoj Grizelj on 13.07.2023..
//

import XCTest
@testable import MobileSDK

final class ExampleServiceTest: XCTestCase {

    func testExampleServiceMock() async {
        let serviceMock = ExampleServiceMock()

        do {
            let example = try await serviceMock.getExample(id: 0)
            XCTAssertEqual(example.name, "Some Name")
        } catch {
            XCTFail("The request should not fail")
        }
    }

}
