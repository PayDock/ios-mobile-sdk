//
//  WidgetUsageScanTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK

/// Source scans for widget usage (R_08, R_10): the 13 widget names, and one `reportWidgetOpened(` per public widget,
/// in an `.onAppear` of the outermost view of `body` or as the first statement of `makeUIView`.
final class WidgetUsageScanTests: XCTestCase {

    private static let views = "Sources/MobileSDK/Views/"
    private static let telemetryDirectory = "Sources/MobileSDK/Telemetry/"

    /// Each public widget's file.
    private static let widgetFiles: [SdkWidget: String] = [
        .cardDetails: "CardDetails/CardDetailsWidget.swift",
        .giftCard: "GiftCard/GiftCardWidget.swift",
        .address: "Address/AddressWidget.swift",
        .applePay: "ApplePay/ApplePayWidget.swift",
        .applePaySetup: "ApplePay/ApplePaySetupWidget.swift",
        .afterpay: "AfterPay/AfterpayWidget.swift",
        .payPal: "PayPal/PayPalWidget.swift",
        .payPalSavePaymentSource: "PayPalVault/PayPalSavePaymentSourceWidget.swift",
        .zip: "Zip/ZipWidget.swift",
        .colesPay: "ColesPay/ColesPayWidget.swift",
        .clickToPay: "Mastercard/ClickToPayWidget.swift",
        .mpgs3ds: "3DS/MPGS3DSWidget.swift",
        .standalone3ds: "3DS/Standalone3DSWidget.swift"
    ]

    /// `AddressWidget` reports from its existing `.onAppear`, which sits inside the outermost `ZStack`.
    private static let nestedOnAppear: Set<SdkWidget> = [.address]

    private static let usageCall = SourceScan.makeRegex(#"\bSdkTelemetry\.reportWidgetOpened\("#)
    private static let body = SourceScan.makeRegex(#"^    public var body: some View \{"#)
    private static let makeUIView = SourceScan.makeRegex(#"^    public func makeUIView\("#)

    func testSdkWidget_HasExactlyTheThirteenNames() {
        XCTAssertEqual(SdkWidget.allCases.map(\.rawValue), [
            "CardDetailsWidget", "GiftCardWidget", "AddressDetailsWidget", "ApplePayWidget", "ApplePaySetupWidget",
            "AfterpayWidget", "PayPalWidget", "PayPalSavePaymentSourceWidget", "ZipWidget", "ColesPayWidget",
            "ClickToPayWidget", "MPGS3dsWidget", "Standalone3DSWidget"
        ])
        XCTAssertEqual(Set(Self.widgetFiles.keys), Set(SdkWidget.allCases))
    }

    func testEachWidgetFile_ReportsItsOwnUsageOnce() throws {
        for (widget, name) in Self.widgetFiles {
            let file = try SourceScan.file(at: Self.views + name)
            let calls = file.code.indices.filter { SourceScan.matches(Self.usageCall, file.code[$0]) }
            guard calls.count == 1, let call = calls.first else {
                XCTFail("\(file.path) has \(calls.count) reportWidgetOpened( calls, expected 1")
                continue
            }
            let line = file.code[call]
            XCTAssertTrue(line.contains("reportWidgetOpened(.\(Self.caseName(widget)))"),
                          "\(file.path):\(call + 1) does not report .\(Self.caseName(widget))")

            if let start = file.code.firstIndex(where: { SourceScan.matches(Self.makeUIView, $0) }) {
                let first = file.code[(start + 1)...].first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                XCTAssertEqual(first?.trimmingCharacters(in: .whitespaces),
                               line.trimmingCharacters(in: .whitespaces),
                               "\(file.path): reportWidgetOpened( is not the first statement of makeUIView")
            } else if let start = file.code.firstIndex(where: { SourceScan.matches(Self.body, $0) }) {
                assertInOnAppearOfBody(file, call: call, bodyStart: start, nested: Self.nestedOnAppear.contains(widget))
            } else {
                XCTFail("\(file.path) has neither a public body nor a public makeUIView")
            }
        }
    }

    func testNoOtherFile_ReportsUsage() throws {
        let widgetPaths = Set(Self.widgetFiles.values.map { Self.views + $0 })
        for file in try SourceScan.files(under: "Sources/MobileSDK")
        where !widgetPaths.contains(file.path) && !file.path.hasPrefix(Self.telemetryDirectory) {
            XCTAssertEqual(SourceScan.count(Self.usageCall, in: file.code), 0, "\(file.path) reports widget usage")
        }
    }

    func testApplePayWidget_EmbedsTheSetupWidgetWithoutUsage() throws {
        let file = try SourceScan.file(at: Self.views + "ApplePay/ApplePayWidget.swift")
        let embeds = file.code.filter { $0.contains("ApplePaySetupWidget(") }
        XCTAssertFalse(embeds.isEmpty)
        for line in embeds {
            XCTAssertTrue(line.contains("reportsUsage: false"), "ApplePayWidget embeds ApplePaySetupWidget: \(line)")
        }

        let setup = try SourceScan.file(at: Self.views + "ApplePay/ApplePaySetupWidget.swift")
        XCTAssertTrue(setup.code.contains { $0.contains("self.init(appearance: appearance, reportsUsage: true)") },
                      "The public ApplePaySetupWidget init reports usage")
        XCTAssertTrue(setup.code.contains { $0.trimmingCharacters(in: .whitespaces) == "if reportsUsage {" },
                      "ApplePaySetupWidget reports only when reportsUsage is true")
    }

    // MARK: - Helpers

    /// The call sits in `body`, in an `.onAppear` block; that `.onAppear` modifies the outermost view (depth 0 inside
    /// `body`) unless `nested` allows an `.onAppear` further in, where the call must be its first statement.
    private func assertInOnAppearOfBody(_ file: SourceScan.File, call: Int, bodyStart: Int, nested: Bool) {
        let bodyEnd = SourceScan.blockEnd(after: bodyStart, in: file.code)
        guard call > bodyStart, call < bodyEnd else {
            XCTFail("\(file.path):\(call + 1) reports usage outside body")
            return
        }
        if file.code[call].contains(".onAppear") {
            assertOutermost(file, onAppear: call, bodyStart: bodyStart, nested: nested)
            return
        }
        var index = call
        while true {
            let opener = SourceScan.blockStart(before: index, in: file.code)
            guard opener > bodyStart else {
                XCTFail("\(file.path):\(call + 1) reports usage outside an .onAppear")
                return
            }
            if file.code[opener].contains(".onAppear") {
                if nested {
                    let first = file.code[(opener + 1)...].first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    XCTAssertEqual(first, file.code[call], "\(file.path): usage is not the first statement of .onAppear")
                }
                assertOutermost(file, onAppear: opener, bodyStart: bodyStart, nested: nested)
                return
            }
            index = opener
        }
    }

    private func assertOutermost(_ file: SourceScan.File, onAppear: Int, bodyStart: Int, nested: Bool) {
        guard !nested else { return }
        let depth = file.code[(bodyStart + 1)..<onAppear].reduce(0) { $0 + SourceScan.braceBalance($1) }
        XCTAssertEqual(depth, 0, "\(file.path):\(onAppear + 1) .onAppear is not on the outermost view of body")
    }

    private static func caseName(_ widget: SdkWidget) -> String {
        String(describing: widget)
    }
}
