//
//  ApiErrorBodyTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_05: the API's structured codes from a raw error body, never its messages or descriptions.
final class ApiErrorBodyTests: XCTestCase {

    private static let planted = "\(SensitiveSamples.message) \(SensitiveSamples.cardNumber) \(SensitiveSamples.email)"

    func testAllFields_AreRead() throws {
        let body = NetworkObservations.json([
            "status": 400,
            "error": [
                "message": Self.planted,
                "code": "invalid_transaction_details",
                "details": ["gateway_specific_code": "G-ERROR-DETAILS"]
            ],
            "error_summary": [
                "message": Self.planted,
                "code": "invalid_summary",
                "details": ["gateway_specific_code": "G-SUMMARY-DETAILS"]
            ]
        ])

        let apiError = try XCTUnwrap(ApiErrorBody.apiError(from: body))

        XCTAssertEqual(apiError, TelemetryEvent.APIError(status: 400, code: "invalid_transaction_details",
                                                         summaryCode: "invalid_summary",
                                                         gatewayCodes: ["G-ERROR-DETAILS", "G-SUMMARY-DETAILS"]))
    }

    /// Each of the four places gives its code alone, and together they come in order: `error.details`,
    /// `error_summary.details`, then the messages of each.
    func testEachGatewayCodePlace_AndTheirOrder() throws {
        let places: [(name: String, body: [String: Any])] = [
            ("error.details", ["error": ["details": ["gateway_specific_code": "A"]]]),
            ("error_summary.details", ["error_summary": ["details": ["gateway_specific_code": "A"]]]),
            ("error.details.messages", ["error": ["details": ["messages": [["gateway_specific_code": "A"]]]]]),
            ("error_summary.details.messages",
             ["error_summary": ["details": ["messages": [["gateway_specific_code": "A"]]]]])
        ]
        for place in places {
            XCTAssertEqual(ApiErrorBody.apiError(from: NetworkObservations.json(place.body))?.gatewayCodes, ["A"], place.name)
        }

        let all = NetworkObservations.json([
            "error": ["details": ["gateway_specific_code": "A",
                                  "messages": [["gateway_specific_code": "C"], ["gateway_specific_code": "D"]]]],
            "error_summary": ["details": ["gateway_specific_code": "B", "messages": [["gateway_specific_code": "E"]]]]
        ])
        XCTAssertEqual(ApiErrorBody.apiError(from: all)?.gatewayCodes, ["A", "B", "C", "D", "E"])
    }

    func testGatewayCodes_AreDistinct_AndBlankOnesAreSkipped() throws {
        let body = NetworkObservations.json([
            "error": [
                "code": " ",
                "details": ["gateway_specific_code": "A",
                            "messages": [["gateway_specific_code": ""], ["gateway_specific_code": "A"],
                                         ["gateway_specific_code": "  "], ["gateway_specific_code": "B"],
                                         ["gateway_specific_code": 42], "not an object"]]
            ],
            "error_summary": ["code": "", "details": ["gateway_specific_code": "B"]]
        ])

        let apiError = try XCTUnwrap(ApiErrorBody.apiError(from: body))

        XCTAssertEqual(apiError.gatewayCodes, ["A", "B"])
        XCTAssertNil(apiError.code)
        XCTAssertNil(apiError.summaryCode)
    }

    func testStatus_IsReadOnlyAsAnInteger() {
        XCTAssertEqual(ApiErrorBody.apiError(from: NetworkObservations.json(["status": 503]))?.status, 503)
        XCTAssertNil(ApiErrorBody.apiError(from: NetworkObservations.json(["status": "503"])))
        XCTAssertNil(ApiErrorBody.apiError(from: NetworkObservations.json(["status": 400.5])))
        XCTAssertNil(ApiErrorBody.apiError(from: NetworkObservations.json(["status": true])))
        XCTAssertEqual(ApiErrorBody.apiError(from: NetworkObservations.json(["status": "400", "error": ["code": "c"]])),
                       TelemetryEvent.APIError(code: "c"))
    }

    /// Messages and descriptions holding card-like and email-like text never reach the result.
    func testMessagesAndDescriptions_NeverAppear() throws {
        let message: [String: Any] = [
            "gateway_specific_code": "G1",
            "gateway_specific_description": Self.planted,
            "description": Self.planted,
            "status_code": Self.planted,
            "status_code_description": Self.planted
        ]
        let body = NetworkObservations.json([
            "status": 422,
            "error": ["message": Self.planted, "code": "c1", "details": ["path": Self.planted, "messages": [message]]],
            "error_summary": ["message": Self.planted, "code": "c2", "status_code": Self.planted,
                              "status_code_description": Self.planted],
            "resource": ["type": Self.planted]
        ])

        let apiError = try XCTUnwrap(ApiErrorBody.apiError(from: body))
        let text = String(describing: apiError)

        XCTAssertEqual(apiError, TelemetryEvent.APIError(status: 422, code: "c1", summaryCode: "c2", gatewayCodes: ["G1"]))
        for forbidden in [SensitiveSamples.message, SensitiveSamples.cardNumber, SensitiveSamples.email] {
            XCTAssertFalse(text.contains(forbidden), "a planted value reached the result")
        }
    }

    func testNil_ForNilEmptyOversizeNonObjectAndCodelessBodies() {
        XCTAssertNil(ApiErrorBody.apiError(from: nil))
        XCTAssertNil(ApiErrorBody.apiError(from: Data()))
        XCTAssertNil(ApiErrorBody.apiError(from: Data("not json".utf8)))
        XCTAssertNil(ApiErrorBody.apiError(from: Data("[{\"status\": 400}]".utf8)))
        XCTAssertNil(ApiErrorBody.apiError(from: Data("\"status\"".utf8)))
        XCTAssertNil(ApiErrorBody.apiError(from: Data("{}".utf8)))
        XCTAssertNil(ApiErrorBody.apiError(from: NetworkObservations.json(["error": ["message": Self.planted]])))

        let padding = String(repeating: " ", count: ApiErrorBody.maxBytes)
        XCTAssertNil(ApiErrorBody.apiError(from: Data("{\"status\": 400}\(padding)".utf8)))
        let atTheLimit = "{\"status\": 400}" + String(repeating: " ", count: ApiErrorBody.maxBytes - 15)
        XCTAssertEqual(Data(atTheLimit.utf8).count, ApiErrorBody.maxBytes)
        XCTAssertEqual(ApiErrorBody.apiError(from: Data(atTheLimit.utf8))?.status, 400)
    }
}
