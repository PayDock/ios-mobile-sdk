//
//  ThreeDSChargeIdScanTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
import PaydockTelemetry

/// D25 (R_04): only the two 3DS widgets pass a charge ID to `startPayment` or note one, only the standalone widget
/// passes a flow to `finishPayment`, and the seam sends neither key for any other widget.
final class ThreeDSChargeIdScanTests: XCTestCase {

    private static let sources = "Sources/MobileSDK"
    private static let telemetryDirectory = "Sources/MobileSDK/Telemetry/"
    private static let standalone3ds = "Sources/MobileSDK/Views/3DS/Standalone3DSWidget.swift"
    private static let mpgs3ds = "Sources/MobileSDK/Views/3DS/MPGS3DSWidget.swift"

    private static let startWithChargeId = SourceScan.makeRegex(#"\bSdkTelemetry\.startPayment\(.*\bcharge3dsId:"#)
    private static let noteCall = SourceScan.makeRegex(#"\bnotePaymentCharge3dsId\("#)
    private static let finishWithFlow = SourceScan.makeRegex(#"\bSdkTelemetry\.finishPayment\(.*\bflow:"#)

    private let telemetry = RecordingTelemetry()

    // MARK: - Source scans

    func testAChargeIdIsPassedToStartPayment_OnlyInThe3DSWidgets() throws {
        try assertCounts(of: Self.startWithChargeId, [Self.standalone3ds: 1, Self.mpgs3ds: 1], name: "startPayment(… charge3dsId:")
    }

    func testNotePaymentCharge3dsId_IsCalledOnlyInThe3DSWidgets() throws {
        try assertCounts(of: Self.noteCall, [Self.standalone3ds: 1, Self.mpgs3ds: 1], name: "notePaymentCharge3dsId(")
    }

    func testAFlowIsPassedToFinishPayment_OnlyInTheStandaloneWidget() throws {
        try assertCounts(of: Self.finishWithFlow, [Self.standalone3ds: 1], name: "finishPayment(… flow:")
    }

    // MARK: - Seam

    func testOtherWidgets_SendNeitherKey() throws {
        var payPal = SdkTelemetry.startPayment(.payPal, charge3dsId: "x", telemetry: telemetry)
        SdkTelemetry.notePaymentCharge3dsId(nil, on: &payPal)
        SdkTelemetry.finishPayment(&payPal, .success, flow: .challenge, telemetry: telemetry)
        var cardDetails = SdkTelemetry.startPayment(.cardDetails, telemetry: telemetry)
        SdkTelemetry.finishPayment(&cardDetails, .declined, flow: .decoupled, telemetry: telemetry)

        XCTAssertEqual(telemetry.events.count, 4)
        for event in telemetry.events {
            switch event {
            case let .paymentStarted(_, _, charge3dsId):
                XCTAssertNil(charge3dsId)
            case let .paymentFinished(_, _, _, _, _, charge3dsId, flow):
                XCTAssertNil(charge3dsId)
                XCTAssertNil(flow)
            default:
                XCTFail("unexpected event")
            }
        }
    }

    func testMPGS_NeverSendsAFlow() throws {
        var withoutId = SdkTelemetry.startPayment(.mpgs3ds, telemetry: telemetry)
        SdkTelemetry.finishPayment(&withoutId, .success, flow: .frictionless, telemetry: telemetry)
        var withId = SdkTelemetry.startPayment(.mpgs3ds, charge3dsId: "id_1", telemetry: telemetry)
        SdkTelemetry.finishPayment(&withId, .declined, flow: .challenge, telemetry: telemetry)

        let finishes = telemetry.events.compactMap { event -> (String?, TelemetryEvent.ThreeDSFlow?)? in
            guard case let .paymentFinished(_, _, _, _, _, charge3dsId, flow) = event else {
                return nil
            }
            return (charge3dsId, flow)
        }
        XCTAssertEqual(finishes.map { $0.0 }, [nil, "id_1"])
        XCTAssertEqual(finishes.map { $0.1 }, [nil, nil])
    }

    func testStandalone_SendsAFlow_OnlyOnSuccessAndDeclined() throws {
        let ends: [PaymentEnd] = [.success, .declined, .cancelled, .failedWithCode("CHARGE_ERROR"),
                                  .failed(Standalone3DSError.mappingFailed)]
        for end in ends {
            var attempt = SdkTelemetry.startPayment(.standalone3ds, charge3dsId: "id_1", telemetry: telemetry)
            SdkTelemetry.finishPayment(&attempt, end, flow: .challenge, telemetry: telemetry)
        }

        let flows = telemetry.events.compactMap { event -> TelemetryEvent.ThreeDSFlow?? in
            guard case let .paymentFinished(_, _, _, _, _, _, flow) = event else {
                return nil
            }
            return .some(flow)
        }
        XCTAssertEqual(flows, [.challenge, .challenge, nil, nil, nil])
    }

    func testNote_SetsOnlyAnOpenAttemptWithoutAnId_FromANonEmptyValue() throws {
        var none: PaymentAttempt?
        SdkTelemetry.notePaymentCharge3dsId("id_a", on: &none)
        XCTAssertNil(none)

        var attempt = SdkTelemetry.startPayment(.standalone3ds, telemetry: telemetry)
        SdkTelemetry.notePaymentCharge3dsId(nil, on: &attempt)
        SdkTelemetry.notePaymentCharge3dsId("", on: &attempt)
        XCTAssertNil(attempt?.charge3dsId)
        SdkTelemetry.notePaymentCharge3dsId("id_a", on: &attempt)
        SdkTelemetry.notePaymentCharge3dsId("id_b", on: &attempt)
        XCTAssertEqual(attempt?.charge3dsId, "id_a")
        XCTAssertEqual(telemetry.events.count, 1, "noting reports nothing")
    }

    // MARK: - Helpers

    private func assertCounts(of regex: NSRegularExpression, _ counts: [String: Int], name: String) throws {
        let files = try SourceScan.files(under: Self.sources)
        XCTAssertFalse(files.isEmpty, "No .swift file under \(Self.sources): wrong repo root")

        for file in files where !file.path.hasPrefix(Self.telemetryDirectory) {
            XCTAssertEqual(SourceScan.count(regex, in: file.code), counts[file.path] ?? 0, "\(name) calls in \(file.path)")
        }
        for path in counts.keys {
            XCTAssertTrue(files.contains { $0.path == path }, "\(path) is missing")
        }
    }
}
