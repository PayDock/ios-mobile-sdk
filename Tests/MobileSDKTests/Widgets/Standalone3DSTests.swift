//
//  Standalone3DSTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.02.2025..
//  Copyright © 2025 Paydock Ltd.
//

import XCTest
import WebKit
import SwiftUI
@testable import MobileSDK

@MainActor
class Standalone3DSTests: XCTestCase {
    var coordinator: Standalone3DSWidget.Coordinator!
    var receivedResult: Result<Standalone3DSResult, Standalone3DSError>?
    var webView: WKWebView!
    var base64Decoder: Base64Decoder!

    override func setUp() {
        super.setUp()
        receivedResult = nil
        coordinator = Standalone3DSWidget.Coordinator { result in
            self.receivedResult = result
        }
        base64Decoder = Base64Decoder()
        webView = WKWebView()
    }

    override func tearDown() {
        coordinator = nil
        webView = nil
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

    func testUserContentController_handlesChargeAuthChallenge() {
        let messageBody: [String: Any] = ["event": "chargeAuthChallenge", "charge3dsId": ""]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthChallenge)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUserContentController_handlesChargeAuthDecoupled() {
        let messageBody: [String: Any] = ["event": "chargeAuthDecoupled", "charge3dsId": ""]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthDecoupled)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUserContentController_handlesChargeAuthInfo() {
        let messageBody: [String: Any] = ["event": "chargeAuthInfo", "charge3dsId": ""]
        let userContentController = WKUserContentController()

        let mockMessage = createMockScriptMessage(body: messageBody)
        coordinator.userContentController(userContentController, didReceive: mockMessage)

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthInfo)
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
            XCTFail("Expected fallback error result")
        }
    }

    // MARK: - Error event

    func testUserContentController_mapsErrorEventToChargeError() {
        coordinator.handleMessage(["event": "error", "charge3dsId": "chargeId"])

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeError)
            XCTAssertEqual(result.charge3dsId, "chargeId")
        } else {
            XCTFail("Expected chargeError result")
        }
    }

    func testUserContentController_errorWithoutId_usesLastSeenChargeId() {
        coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId", "status": "pending"])
        coordinator.handleMessage(["event": "error"])

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeError)
            XCTAssertEqual(result.charge3dsId, "chargeId")
        } else {
            XCTFail("Expected chargeError result")
        }
    }

    func testUserContentController_errorWithoutAnyId_usesEmptyChargeId() {
        coordinator.handleMessage(["event": "error"])

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeError)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected chargeError result")
        }
    }

    func testUserContentController_infoWithoutId_isDeliveredNotMappingFailure() {
        coordinator.handleMessage(["event": "chargeAuthInfo"])

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthInfo)
            XCTAssertEqual(result.charge3dsId, "")
        } else {
            XCTFail("Expected chargeAuthInfo result")
        }
    }

    func testUserContentController_ignoresUnknownEvent() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthSomethingNew", "charge3dsId": "chargeId"])

        XCTAssertTrue(recorder.results.isEmpty)
        XCTAssertTrue(recorder.progress.isEmpty)
        XCTAssertTrue(recorder.coordinator.isLoading)
    }

    // MARK: - Status / resultDescription

    func testResult_successCarriesStatusAndDescription() {
        coordinator.handleMessage([
            "event": "chargeAuthSuccess", "charge3dsId": "chargeId", "status": "success", "description": "frictionless"
        ])

        if case .success(let result) = receivedResult {
            XCTAssertEqual(result.event, .chargeAuthSuccess)
            XCTAssertEqual(result.charge3dsId, "chargeId")
            XCTAssertEqual(result.status, "success")
            XCTAssertEqual(result.resultDescription, "frictionless")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testResult_challengeOutcomeCarriesStatusWithoutDescription() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId", "status": "pending"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeLoaded", "charge3dsId": "chargeId", "reason": "load"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeCompleted", "charge3dsId": "chargeId", "source": "poll"])
        recorder.coordinator.handleMessage(["event": "chargeAuthReject", "charge3dsId": "chargeId", "status": "rejected"])

        let results = recorder.results.compactMap { try? $0.get() }
        XCTAssertEqual(results.map(\.event), [.chargeAuthChallenge, .chargeAuthReject])
        XCTAssertEqual(results.map(\.status), ["pending", "rejected"])
        XCTAssertEqual(results.map(\.resultDescription), [nil, nil])
        XCTAssertEqual(results.map(\.charge3dsId), ["chargeId", "chargeId"])
    }

    func testResult_missingOrEmptyStatusAndDescriptionAreNil() {
        let bodies: [[String: Any]] = [
            ["event": "chargeAuthSuccess", "charge3dsId": "chargeId"],
            ["event": "chargeAuthSuccess", "charge3dsId": "chargeId", "status": "", "description": ""],
            ["event": "chargeAuthSuccess", "charge3dsId": "chargeId", "status": 1, "description": NSNull()]
        ]
        for body in bodies {
            receivedResult = nil
            coordinator.handleMessage(body)

            guard case .success(let result) = receivedResult else {
                XCTFail("Expected success result")
                continue
            }
            XCTAssertEqual(result.event, .chargeAuthSuccess)
            XCTAssertEqual(result.charge3dsId, "chargeId")
            XCTAssertNil(result.status)
            XCTAssertNil(result.resultDescription)
        }
    }

    func testResult_errorAndInfoCarryStatusAndKeepExistingFields() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthInfo", "status": "pending", "description": "frictionless"])
        recorder.coordinator.handleMessage(["event": "error", "charge3dsId": "chargeId", "status": "error"])

        let results = recorder.results.compactMap { try? $0.get() }
        XCTAssertEqual(results.map(\.event), [.chargeAuthInfo, .chargeError])
        XCTAssertEqual(results.map(\.charge3dsId), ["", "chargeId"])
        XCTAssertEqual(results.map(\.status), ["pending", "error"])
        XCTAssertEqual(results.map(\.resultDescription), ["frictionless", nil])
    }

    func testResult_decoupledProgressDescriptionUnchanged() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage([
            "event": "chargeAuthDecoupled", "charge3dsId": "chargeId", "status": "pending", "description": "Approve in app"
        ])

        XCTAssertEqual(recorder.progress, [.decoupled(charge3dsId: "chargeId", description: "Approve in app")])
        let result = try? recorder.results.first?.get()
        XCTAssertEqual(result?.status, "pending")
        XCTAssertEqual(result?.resultDescription, "Approve in app")
    }

    // MARK: - Progress

    func testProgress_challengeStarted() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId", "status": "pending"])

        XCTAssertEqual(recorder.progress, [.challengeStarted(charge3dsId: "chargeId")])
        XCTAssertEqual(recorder.events, [.chargeAuthChallenge])
    }

    func testProgress_challengeLoadedReasons() {
        let cases: [(String?, Standalone3DSProgress.ChallengeLoadedReason)] = [
            ("load", .load), ("timeout", .timeout), ("somethingElse", .unknown), (nil, .unknown)
        ]
        for (raw, expected) in cases {
            let recorder = makeRecordingCoordinator()
            var body: [String: Any] = ["event": "chargeAuthChallengeLoaded", "charge3dsId": "chargeId"]
            body["reason"] = raw

            recorder.coordinator.handleMessage(body)

            XCTAssertEqual(recorder.progress, [.challengeLoaded(charge3dsId: "chargeId", reason: expected)])
            XCTAssertTrue(recorder.results.isEmpty, "chargeAuthChallengeLoaded must not reach completion")
        }
    }

    func testProgress_challengeCompletedSources() {
        let cases: [(String?, Standalone3DSProgress.ChallengeCompletedSource)] = [
            ("poll", .poll), ("callback", .callback), ("somethingElse", .unknown), (nil, .unknown)
        ]
        for (raw, expected) in cases {
            let recorder = makeRecordingCoordinator()
            var body: [String: Any] = ["event": "chargeAuthChallengeCompleted"]
            body["source"] = raw

            recorder.coordinator.handleMessage(body)

            XCTAssertEqual(recorder.progress, [.challengeCompleted(charge3dsId: nil, source: expected)])
            XCTAssertTrue(recorder.results.isEmpty, "chargeAuthChallengeCompleted must not reach completion")
        }
    }

    func testProgress_decoupledCarriesDescription() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage([
            "event": "chargeAuthDecoupled", "charge3dsId": "chargeId", "status": "pending", "description": "Approve in app"
        ])
        recorder.coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "chargeId"])

        XCTAssertEqual(recorder.progress, [
            .decoupled(charge3dsId: "chargeId", description: "Approve in app"),
            .decoupled(charge3dsId: "chargeId", description: nil)
        ])
        XCTAssertEqual(recorder.events, [.chargeAuthDecoupled, .chargeAuthDecoupled])
    }

    func testProgress_notEmittedForFinalEvents() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthInfo"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "chargeId"])

        XCTAssertTrue(recorder.progress.isEmpty)
        XCTAssertEqual(recorder.events, [.chargeAuthInfo, .chargeAuthSuccess])
    }

    // MARK: - Loading sequencing

    func testLoading_frictionless() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthInfo"])
        XCTAssertEqual(recorder.loading.calls, [.start], "chargeAuthInfo must not change loading state")

        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "chargeId"])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish])
    }

    func testLoading_challenge() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        XCTAssertEqual(recorder.loading.calls, [.start], "Loading stays up until the challenge page has loaded")

        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeLoaded", "charge3dsId": "chargeId", "reason": "load"])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish])

        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeCompleted", "charge3dsId": "chargeId", "source": "poll"])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish, .start])

        recorder.coordinator.handleMessage(["event": "chargeAuthReject", "charge3dsId": "chargeId"])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish, .start, .finish])
        XCTAssertEqual(recorder.events, [.chargeAuthChallenge, .chargeAuthReject])
    }

    func testLoading_decoupled() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "chargeId"])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish])

        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeCompleted", "charge3dsId": "chargeId", "source": "callback"])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish, .start])

        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "chargeId"])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish, .start, .finish])
    }

    func testLoading_errorAfterChallengeFinishesOnce() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeLoaded", "charge3dsId": "chargeId", "reason": "timeout"])
        recorder.coordinator.handleMessage(["event": "error"])
        recorder.coordinator.handleMessage(["event": "error"])

        XCTAssertEqual(recorder.loading.calls, [.start, .finish], "Start/finish must stay balanced")
    }

    func testLoading_mappingFailureFinishes() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["invalid": "data"])

        XCTAssertEqual(recorder.loading.calls, [.start, .finish])
        XCTAssertFalse(recorder.coordinator.isLoading)
    }

    // MARK: - Helpers

    enum LoadingCall { case start, finish }

    final class LoadingRecorder: WidgetLoadingDelegate {
        private(set) var calls: [LoadingCall] = []
        func loadingDidStart() { calls.append(.start) }
        func loadingDidFinish() { calls.append(.finish) }
    }

    @MainActor
    final class Recorder {
        let loading = LoadingRecorder()
        var results: [Result<Standalone3DSResult, Standalone3DSError>] = []
        var progress: [Standalone3DSProgress] = []
        var coordinator: Standalone3DSWidget.Coordinator!

        var events: [Standalone3DSResult.EventType] {
            results.compactMap { try? $0.get().event }
        }
    }

    /// Coordinator wired to a recording loading delegate, already loading as it is after `makeUIView`.
    func makeRecordingCoordinator() -> Recorder {
        let recorder = Recorder()
        recorder.coordinator = Standalone3DSWidget.Coordinator(
            completion: { [unowned recorder] in recorder.results.append($0) },
            loadingDelegate: recorder.loading,
            onProgress: { [unowned recorder] in recorder.progress.append($0) })
        recorder.coordinator.notifyLoadingStart()
        return recorder
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
        let validToken = "eyJjb250ZW50IjoiZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBaQ0k2SWpZM1l6VmlNekUxTlRObE16aGlNV015WTJNMFl6YzNaQ0lzSW0xbGRHRWlPaUpsZVVwcVlVZEdlVm95Vm1aTk1sSjZXREpzYTBscWIybFphazVzVFdwbk5VMXFhM1JPUkUwMFRWTXdNRTVxWTNsTVZHaHFUV3ByZEUxSFZtMU5WMFpxVGpKT2EwNVVaek5KYVhkcFl6SldlV1J0YkdwYVZqa3daVmhDYkVscWIybFNNVUpvWlZjeGJHSnVVbnBKYVhkcFdsaG9NRnBZU25WWlYzaG1ZVmRSYVU5cFNUUk9la0pyVFVSVmVVOVRNSGxhYW1OM1RGUlNhRmxYUlhSUFIwa3lUV2t3TlU5SFZtMU9iVlpzVGtSQk1FNUVRV2xNUTBwd1ltMXNNR0ZYUm5OaFdIQm9aRWRzZG1Kc09URmpiWGRwVDJsS2IyUklVbmRqZW05MlRETkNhR1ZYVW5aWk1uTjBaRWRXZW1SRE5XaGpla1YxV2pOQ2FHVlhNV3hpYmxKNlRHMDFiR1JET1doalIydDJaR3BKZGxsdVNqTk1NazVvWWtkNGFWbFhUbkpRTTFKNVdWYzFlbE5YVVRsUFJHTjNXa1JCTVUxcWEzUk5iVmt6VFVNd01GbFhSbWhNVkdocFRtcEpkRTlVYUd4YWFscHNXbFJSZDA1RVVYZEtibEU1WTBWU1EwNVlTWGxQVjJoQ1RUSTVOVkpyYkUxa1ZWRjVaSHBrZUdReVNsZGFXR2hYVkRGR1UwNXJWbEpVYlRGMVlVZHdWMXBJUmtoYVJsVjRWMnN3TkU1R1pIaE5NWEJzV1RKNFJWZEhUalJqYkVaeVdtNUNZVmt6UW1GU1NFcG9TV2wzYVZsWVZqQmhSemw1WVZod2FHUkhiSFppYkRreFkyMTNhVTlwU205a1NGSjNZM3B2ZGt3elFtaGxWMUoyV1RKemRHUkhWbnBrUXpWb1kwZHJkVmxZVFhoTWJXUjNXVmhzZEZwWE5UQmplVFYxV2xoUmRsbFlRbkJNTTFsNVRESkdNV1JIWjNaWmJrb3pVRE5ST1UxNlRUSlphbFY2V1RKWk1rNUVRVEJhVkdoc1dsUnJlbGx0VFRGYWJWazBUbTFaZUZsVVNYaE9WR3R0WTBReFlWWkhZM2RVYkdSaFlXeHNkRlpZWkZCU1JrVjZWR3BLUjJKR2NGaFhiWFJhWWxac05sUlhNVnBOVlRsWVUyMTBUbFpHYXpGWGJURktaV3hzY1ZaVVNscFdSa1Y0VkcxamFVeERTbnBhVjA1MlltMVNhR051Ykdaa1dFcHpTV3B2YVdGSVVqQmpTRTAyVEhrNWQxbFliR3RpTWs1eVRGaFNiR016VVhWWldFMTRURzFrZDFsWWJIUmFWelV3WTNrMWRWcFlVWFpaV0VKd1RETlplVXd5U25sa2VUbHdZbTFzTUV3eU1YWmlhamt3VUZSbk0wMUhVWGRPVkVrMVRGUktiVTU2UVhST1IwWm9XVk13TkZscVdYbE1WR3MwV2xkWk1scFhWVEJOUkZFd1RVTktPU0lzSW1saGRDSTZNVGMwTVRBd09UWTROU3dpWlhod0lqb3hOelF4TURrMk1EZzFmUS5kMXRxSFQ0VjBTQ2JDOUdKLTBpSEpBSTdXT3ZLd2lza09HaWVaNkN5MVJjIiwiZm9ybWF0Ijoic3RhbmRhbG9uZV8zZHMifQ=="
        let decodedToken = base64Decoder.decodeBase64(validToken, to: Decoded3DSToken.self)

        XCTAssertNil(decodedToken?.charge3dsId)
        XCTAssert(decodedToken?.format == .standalone3ds)

        _ = Standalone3DSWidget(config: .init(token: validToken)) { result in
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

        _ = Standalone3DSWidget(config: .init(token: invalidToken)) { result in
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
        // Arrange: Provid integrated token instead of standalone one
        // swiftlint:disable:next line_length
        let wrongToken = "eyJjb250ZW50IjoiPGRpdiBpZD1cInRocmVlZHNDaGFsbGVuZ2VSZWRpcmVjdFwiIHhtbG5zPVwiaHR0cDovL3d3dy53My5vcmcvMTk5OS9odG1sXCIgc3R5bGU9XCIgaGVpZ2h0OiAxMDB2aFwiPiA8Zm9ybSBpZCA9XCJ0aHJlZWRzQ2hhbGxlbmdlUmVkaXJlY3RGb3JtXCIgbWV0aG9kPVwiUE9TVFwiIGFjdGlvbj1cImh0dHBzOi8vbXRmLmdhdGV3YXkubWFzdGVyY2FyZC5jb20vYWNzL21hc3RlcmNhcmQvdjIvcHJvbXB0XCIgdGFyZ2V0PVwiY2hhbGxlbmdlRnJhbWVcIj4gPGlucHV0IHR5cGU9XCJoaWRkZW5cIiBuYW1lPVwiY3JlcVwiIHZhbHVlPVwiZXlKMGFISmxaVVJUVTJWeWRtVnlWSEpoYm5OSlJDSTZJbUpsTm1VME9XVmlMVFEyWVRBdE5EYzJNUzFoTjJabUxUUmlPVE5oWlRCaU9EYzJaQ0o5XCIgLz4gPC9mb3JtPiA8aWZyYW1lIGlkPVwiY2hhbGxlbmdlRnJhbWVcIiBuYW1lPVwiY2hhbGxlbmdlRnJhbWVcIiB3aWR0aD1cIjEwMCVcIiBoZWlnaHQ9XCIxMDAlXCIgPjwvaWZyYW1lPiA8c2NyaXB0IGlkPVwiYXV0aGVudGljYXRlLXBheWVyLXNjcmlwdFwiPiB2YXIgZT1kb2N1bWVudC5nZXRFbGVtZW50QnlJZChcInRocmVlZHNDaGFsbGVuZ2VSZWRpcmVjdEZvcm1cIik7IGlmIChlKSB7IGUuc3VibWl0KCk7IGlmIChlLnBhcmVudE5vZGUgIT09IG51bGwpIHsgZS5wYXJlbnROb2RlLnJlbW92ZUNoaWxkKGUpOyB9IH0gPC9zY3JpcHQ+IDwvZGl2PiIsImZvcm1hdCI6Imh0bWwiLCJjaGFyZ2VfM2RzX2lkIjoiOWEwMjkyYzgtNDZjYS00ODczLTk1NWYtMzU2NDgxNmQzZTM1In0="
        let expectation = self.expectation(description: "Completion should be called with invalidToken error")

        let decodedToken = base64Decoder.decodeBase64(wrongToken, to: Decoded3DSToken.self)

        XCTAssertNotNil(decodedToken?.charge3dsId)
        XCTAssertFalse(decodedToken?.format == .standalone3ds)

        _ = Standalone3DSWidget(config: .init(token: "")) { result in
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
