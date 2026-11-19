//
//  PaymentScanTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest

/// Source scans over `Sources/MobileSDK` for the payment attempts (D24): one `SdkTelemetry.startPayment(` in each of
/// the five payment widgets, one `recordFailedPayment(` in each 3DS widget, the `finishPayment(` calls pinned per file
/// (update them with any new end path), and none of the three calls anywhere else outside `Telemetry/`.
final class PaymentScanTests: XCTestCase {

    private static let sources = "Sources/MobileSDK"
    private static let telemetryDirectory = "Sources/MobileSDK/Telemetry/"

    private static let cardDetails = "Sources/MobileSDK/Views/CardDetails/CardDetailsVM.swift"
    private static let standalone3ds = "Sources/MobileSDK/Views/3DS/Standalone3DSWidget.swift"
    private static let mpgs3ds = "Sources/MobileSDK/Views/3DS/MPGS3DSWidget.swift"
    private static let payPal = "Sources/MobileSDK/Views/PayPal/PayPalVM.swift"
    private static let applePay = "Sources/MobileSDK/Views/ApplePay/ApplePayVM.swift"

    /// `SdkTelemetry.startPayment(` calls per file.
    private static let startCounts: [String: Int] = [
        cardDetails: 1, standalone3ds: 1, mpgs3ds: 1, payPal: 1, applePay: 1
    ]

    /// `SdkTelemetry.recordFailedPayment(` calls per file: the invalid token of each 3DS widget.
    private static let failedCounts: [String: Int] = [standalone3ds: 1, mpgs3ds: 1]

    /// `SdkTelemetry.finishPayment(` calls per file, one per end path of the per-widget map.
    private static let finishCounts: [String: Int] = [
        // Unreadable expiry, token, RequestError.requestError, other.
        cardDetails: 4,
        // Two mappingFailed sites, chargeError, success or reject, didFail, provisional, endSession.
        standalone3ds: 7,
        // Client SDK load, mappingFailed, a final event, didFail, provisional.
        mpgs3ds: 5,
        // The twelve reported ends and the capture's success.
        payPal: 13,
        // Present failure, finishAndComplete's success and its failure.
        applePay: 3
    ]

    private static let startCall = SourceScan.makeRegex(#"\bSdkTelemetry\.startPayment\("#)
    private static let failedCall = SourceScan.makeRegex(#"\bSdkTelemetry\.recordFailedPayment\("#)
    private static let finishCall = SourceScan.makeRegex(#"\bSdkTelemetry\.finishPayment\("#)
    private static let anyCall = SourceScan.makeRegex(#"\b(startPayment|finishPayment|recordFailedPayment)\("#)
    private static let ownStartPayment = SourceScan.makeRegex(#"\bstartPayment\(\)"#)

    func testStartPayment_OncePerPaymentWidget() throws {
        try assertCounts(of: Self.startCall, Self.startCounts, name: "SdkTelemetry.startPayment(")
    }

    func testRecordFailedPayment_OncePer3DSWidget() throws {
        try assertCounts(of: Self.failedCall, Self.failedCounts, name: "SdkTelemetry.recordFailedPayment(")
    }

    func testFinishPayment_PerFileCounts() throws {
        try assertCounts(of: Self.finishCall, Self.finishCounts, name: "SdkTelemetry.finishPayment(")
    }

    /// No file outside `Telemetry/` and the five widgets names any of the three calls (Apple Pay's own
    /// `startPayment()` method aside).
    func testNoOtherFile_RecordsPayments() throws {
        let widgets = Set(Self.startCounts.keys)
        for file in try SourceScan.files(under: Self.sources)
        where !file.path.hasPrefix(Self.telemetryDirectory) && !widgets.contains(file.path) {
            for (index, line) in file.code.enumerated() where SourceScan.matches(Self.anyCall, line) {
                XCTFail("\(file.path):\(index + 1) records a payment outside the five payment widgets")
            }
        }
        for file in try SourceScan.files(under: Self.sources) where widgets.contains(file.path) {
            let calls = file.code.filter { line in
                SourceScan.matches(Self.anyCall, line) && !SourceScan.matches(Self.ownStartPayment, line)
            }
            for line in calls {
                XCTAssertTrue(line.contains("SdkTelemetry."), "\(file.path): \(line) records a payment off the seam")
            }
        }
    }

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
