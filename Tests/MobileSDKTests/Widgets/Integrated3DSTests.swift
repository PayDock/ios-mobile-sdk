//
//  Integrated3DSTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.02.2025..
//  Copyright © 2025 Paydock Ltd.
//

import XCTest
import WebKit
@testable import MobileSDK

@MainActor
class Integrated3DSTests: XCTestCase {
    var coordinator: Integrated3DSWidget.Coordinator!
    var receivedResult: Result<Integrated3DSResult, Integrated3DSError>?
    var base64Decoder: Base64Decoder!
    var activityIndicator: UIActivityIndicatorView!

    override func setUp() {
        super.setUp()
        receivedResult = nil
        coordinator = Integrated3DSWidget.Coordinator { result in
            self.receivedResult = result
        }
        base64Decoder = Base64Decoder()
    }

    override func tearDown() {
        coordinator = nil
        base64Decoder = nil
        super.tearDown()
    }

    func testUserContentController_handlesValidMessage() {
        let messageBody: [String: Any] = ["event": "chargeAuthSuccess", "charge3dsId": "testToken"]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthSuccess)
            XCTAssertEqual(result.charge3dsId, "testToken")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUserContentController_handlesChargeReject() {
        let messageBody: [String: Any] = ["event": "chargeAuthReject", "charge3dsId": ""]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthReject)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUserContentController_handlesChargeAuthCancelled() {
        let messageBody: [String: Any] = ["event": "chargeAuthCancelled", "charge3dsId": ""]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthCancelled)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUserContentController_handlesAdditionalDataCollectSuccess() {
        let messageBody: [String: Any] = ["event": "additionalDataCollectSuccess", "charge3dsId": ""]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .additionalDataCollectSuccess)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUserContentController_handlesAdditionalDataCollectReject() {
        let messageBody: [String: Any] = ["event": "additionalDataCollectReject", "charge3dsId": ""]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .additionalDataCollectReject)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUserContentController_handlesInvalidMessage() {
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: ["invalid": "data"])
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .failure(let error) = receivedResult {
            XCTAssertEqual(error, .mappingFailed)
        } else {
            XCTFail("Expected mappingFailed result")
        }
    }

    // Helper function to create a WKScriptMessage-like object
    func createMockScriptMessage(body: Any) -> WKScriptMessage {
        class MockScriptMessage: WKScriptMessage {
            private let mockBody: Any
            override var body: Any { mockBody }

            init(body: Any) {
                self.mockBody = body
                super.init()
            }
        }
        return MockScriptMessage(body: body)
    }

    func testValidateToken_withValidToken_callsCompletionWithSuccess() {
        // swiftlint:disable:next line_length
        let validToken = "eyJjb250ZW50IjoiPGRpdiBpZD1cInRocmVlZHNDaGFsbGVuZ2VSZWRpcmVjdFwiIHhtbG5zPVwiaHR0cDovL3d3dy53My5vcmcvMTk5OS9odG1sXCIgc3R5bGU9XCIgaGVpZ2h0OiAxMDB2aFwiPiA8Zm9ybSBpZCA9XCJ0aHJlZWRzQ2hhbGxlbmdlUmVkaXJlY3RGb3JtXCIgbWV0aG9kPVwiUE9TVFwiIGFjdGlvbj1cImh0dHBzOi8vbXRmLmdhdGV3YXkubWFzdGVyY2FyZC5jb20vYWNzL21hc3RlcmNhcmQvdjIvcHJvbXB0XCIgdGFyZ2V0PVwiY2hhbGxlbmdlRnJhbWVcIj4gPGlucHV0IHR5cGU9XCJoaWRkZW5cIiBuYW1lPVwiY3JlcVwiIHZhbHVlPVwiZXlKMGFISmxaVVJUVTJWeWRtVnlWSEpoYm5OSlJDSTZJbUpsTm1VME9XVmlMVFEyWVRBdE5EYzJNUzFoTjJabUxUUmlPVE5oWlRCaU9EYzJaQ0o5XCIgLz4gPC9mb3JtPiA8aWZyYW1lIGlkPVwiY2hhbGxlbmdlRnJhbWVcIiBuYW1lPVwiY2hhbGxlbmdlRnJhbWVcIiB3aWR0aD1cIjEwMCVcIiBoZWlnaHQ9XCIxMDAlXCIgPjwvaWZyYW1lPiA8c2NyaXB0IGlkPVwiYXV0aGVudGljYXRlLXBheWVyLXNjcmlwdFwiPiB2YXIgZT1kb2N1bWVudC5nZXRFbGVtZW50QnlJZChcInRocmVlZHNDaGFsbGVuZ2VSZWRpcmVjdEZvcm1cIik7IGlmIChlKSB7IGUuc3VibWl0KCk7IGlmIChlLnBhcmVudE5vZGUgIT09IG51bGwpIHsgZS5wYXJlbnROb2RlLnJlbW92ZUNoaWxkKGUpOyB9IH0gPC9zY3JpcHQ+IDwvZGl2PiIsImZvcm1hdCI6Imh0bWwiLCJjaGFyZ2VfM2RzX2lkIjoiOWEwMjkyYzgtNDZjYS00ODczLTk1NWYtMzU2NDgxNmQzZTM1In0="
        let decodedToken = base64Decoder.decodeBase64(validToken, to: Decoded3DSToken.self)

        XCTAssertNotNil(decodedToken?.charge3dsId)
        XCTAssert(decodedToken?.format == .url || decodedToken?.format == .html)

        _ = Integrated3DSWidget(config: .init(token: validToken)) { result in
            if case let .failure(error) = result {
                switch error {
                case .invalidToken: XCTFail("Token is correct - it should not fail!")
                default: XCTAssert(true) // Other errors are expected in this case
                }
            }
        }
    }

    func testValidateToken_withInvalidToken_callsCompletionWithInvalidTokenError() {
        // Arrange: Provide an invalid token (malformed base64)
        let invalidToken = "invalidBase64Token"
        let expectation = self.expectation(description: "Completion should be called with invalidToken error")

        _ = Integrated3DSWidget(config: .init(token: invalidToken)) { result in
            if case let .failure(error) = result {
                switch error {
                case .invalidToken: expectation.fulfill()
                default: break
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testValidateToken_withWrongToken_callsCompletionWithInvalidTokenError() {
        // Arrange: Provid standalone token instead of integrated one
        // swiftlint:disable:next line_length
        let wrongToken = "eyJjb250ZW50IjoiZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBaQ0k2SWpZM1l6VmlNekUxTlRObE16aGlNV015WTJNMFl6YzNaQ0lzSW0xbGRHRWlPaUpsZVVwcVlVZEdlVm95Vm1aTk1sSjZXREpzYTBscWIybFphazVzVFdwbk5VMXFhM1JPUkUwMFRWTXdNRTVxWTNsTVZHaHFUV3ByZEUxSFZtMU5WMFpxVGpKT2EwNVVaek5KYVhkcFl6SldlV1J0YkdwYVZqa3daVmhDYkVscWIybFNNVUpvWlZjeGJHSnVVbnBKYVhkcFdsaG9NRnBZU25WWlYzaG1ZVmRSYVU5cFNUUk9la0pyVFVSVmVVOVRNSGxhYW1OM1RGUlNhRmxYUlhSUFIwa3lUV2t3TlU5SFZtMU9iVlpzVGtSQk1FNUVRV2xNUTBwd1ltMXNNR0ZYUm5OaFdIQm9aRWRzZG1Kc09URmpiWGRwVDJsS2IyUklVbmRqZW05MlRETkNhR1ZYVW5aWk1uTjBaRWRXZW1SRE5XaGpla1YxV2pOQ2FHVlhNV3hpYmxKNlRHMDFiR1JET1doalIydDJaR3BKZGxsdVNqTk1NazVvWWtkNGFWbFhUbkpRTTFKNVdWYzFlbE5YVVRsUFJHTjNXa1JCTVUxcWEzUk5iVmt6VFVNd01GbFhSbWhNVkdocFRtcEpkRTlVYUd4YWFscHNXbFJSZDA1RVVYZEtibEU1WTBWU1EwNVlTWGxQVjJoQ1RUSTVOVkpyYkUxa1ZWRjVaSHBrZUdReVNsZGFXR2hYVkRGR1UwNXJWbEpVYlRGMVlVZHdWMXBJUmtoYVJsVjRWMnN3TkU1R1pIaE5NWEJzV1RKNFJWZEhUalJqYkVaeVdtNUNZVmt6UW1GU1NFcG9TV2wzYVZsWVZqQmhSemw1WVZod2FHUkhiSFppYkRreFkyMTNhVTlwU205a1NGSjNZM3B2ZGt3elFtaGxWMUoyV1RKemRHUkhWbnBrUXpWb1kwZHJkVmxZVFhoTWJXUjNXVmhzZEZwWE5UQmplVFYxV2xoUmRsbFlRbkJNTTFsNVRESkdNV1JIWjNaWmJrb3pVRE5ST1UxNlRUSlphbFY2V1RKWk1rNUVRVEJhVkdoc1dsUnJlbGx0VFRGYWJWazBUbTFaZUZsVVNYaE9WR3R0WTBReFlWWkhZM2RVYkdSaFlXeHNkRlpZWkZCU1JrVjZWR3BLUjJKR2NGaFhiWFJhWWxac05sUlhNVnBOVlRsWVUyMTBUbFpHYXpGWGJURktaV3hzY1ZaVVNscFdSa1Y0VkcxamFVeERTbnBhVjA1MlltMVNhR051Ykdaa1dFcHpTV3B2YVdGSVVqQmpTRTAyVEhrNWQxbFliR3RpTWs1eVRGaFNiR016VVhWWldFMTRURzFrZDFsWWJIUmFWelV3WTNrMWRWcFlVWFpaV0VKd1RETlplVXd5U25sa2VUbHdZbTFzTUV3eU1YWmlhamt3VUZSbk0wMUhVWGRPVkVrMVRGUktiVTU2UVhST1IwWm9XVk13TkZscVdYbE1WR3MwV2xkWk1scFhWVEJOUkZFd1RVTktPU0lzSW1saGRDSTZNVGMwTVRBd09UWTROU3dpWlhod0lqb3hOelF4TURrMk1EZzFmUS5kMXRxSFQ0VjBTQ2JDOUdKLTBpSEpBSTdXT3ZLd2lza09HaWVaNkN5MVJjIiwiZm9ybWF0Ijoic3RhbmRhbG9uZV8zZHMifQ=="
        let expectation = self.expectation(description: "Completion should be called with invalidToken error")

        let decodedToken = base64Decoder.decodeBase64(wrongToken, to: Decoded3DSToken.self)

        XCTAssertNil(decodedToken?.charge3dsId)
        XCTAssertFalse(decodedToken?.format == .url || decodedToken?.format == .html)

        _ = Integrated3DSWidget(config: .init(token: wrongToken)) { result in
            if case let .failure(error) = result {
                switch error {
                case .invalidToken: expectation.fulfill()
                default: break
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
