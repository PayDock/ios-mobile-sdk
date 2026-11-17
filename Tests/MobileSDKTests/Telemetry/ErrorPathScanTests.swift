//
//  ErrorPathScanTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest

/// Source scans over `Sources/MobileSDK` for the SDK's failure paths and `Task`s (R_04, R_06, R_07): one
/// `SdkTelemetry.reportSdkError(` per delivered failure, each before its delivery and never right before a crash, every
/// `Task` through `SdkTask.run`, and no message text read by the telemetry files.
final class ErrorPathScanTests: XCTestCase {

    private static let sources = "Sources/MobileSDK"
    private static let telemetryDirectory = "Sources/MobileSDK/Telemetry/"
    private static let sdkTaskFile = "Sources/MobileSDK/Telemetry/SdkTask.swift"

    /// `SdkTelemetry.reportSdkError(` calls per file; every other file outside `Telemetry/` has none.
    private static let reportCounts: [String: Int] = [
        "Sources/MobileSDK/Views/CardDetails/CardDetailsVM.swift": 3,
        "Sources/MobileSDK/Views/GiftCard/GiftCardVM.swift": 2,
        "Sources/MobileSDK/Views/Address/AddressVM.swift": 3,
        "Sources/MobileSDK/Views/ApplePay/ApplePayVM.swift": 2,
        "Sources/MobileSDK/Views/PayPal/PayPalVM.swift": 12,
        "Sources/MobileSDK/Views/PayPalVault/PayPalSavePaymentSourceVM.swift": 10,
        "Sources/MobileSDK/Utils/PayPalDataCollector/PayPalDataCollectorUtil.swift": 3,
        "Sources/MobileSDK/Views/AfterPay/AfterpayVM.swift": 11,
        "Sources/MobileSDK/Views/Zip/ZipVM.swift": 8,
        "Sources/MobileSDK/Views/ColesPay/ColesPayVM.swift": 5,
        "Sources/MobileSDK/Views/ColesPay/ColesPayWebView.swift": 1,
        "Sources/MobileSDK/Views/Mastercard/ClickToPayWidget.swift": 7,
        "Sources/MobileSDK/Views/3DS/MPGS3DSWidget.swift": 5,
        // The Client SDK load failure and the process-terminated path both deliver through `endSession`.
        "Sources/MobileSDK/Views/3DS/Standalone3DSWidget.swift": 6
    ]

    /// `SdkTask.run(` sites per file; every other file has none.
    private static let taskCounts: [String: Int] = [
        "Sources/MobileSDK/Views/ApplePay/ApplePayVM.swift": 6,
        "Sources/MobileSDK/Views/Zip/ZipWebView.swift": 5,
        "Sources/MobileSDK/Views/ColesPay/ColesPayWebView.swift": 5,
        "Sources/MobileSDK/Views/AfterPay/AfterpayVM.swift": 4,
        "Sources/MobileSDK/Views/PayPal/PayPalVM.swift": 3,
        "Sources/MobileSDK/Views/Address/AddressVM.swift": 3,
        "Sources/MobileSDK/Views/ColesPay/ColesPayVM.swift": 3,
        "Sources/MobileSDK/Views/Zip/ZipVM.swift": 2,
        "Sources/MobileSDK/Views/GiftCard/GiftCardVM.swift": 2,
        "Sources/MobileSDK/Views/CardDetails/CardDetailsVM.swift": 2,
        "Sources/MobileSDK/Views/PayPalVault/PayPalSavePaymentSourceVM.swift": 1,
        "Sources/MobileSDK/Views/Address/AddressWidget.swift": 1,
        "Sources/MobileSDK/Views/GiftCard/GiftCardWidget.swift": 1,
        "Sources/MobileSDK/Views/CardDetails/CardDetailsWidget.swift": 1
    ]

    private static let reportCall = SourceScan.makeRegex(#"\bSdkTelemetry\.reportSdkError\("#)
    private static let taskRun = SourceScan.makeRegex(#"\bSdkTask\.run\("#)
    private static let taskCreation = SourceScan.makeRegex(#"\bTask\s*(\{|\()"#)
    private static let crash = SourceScan.makeRegex(#"\b(fatalError|precondition|preconditionFailure)\s*\(|\.raise\s*\("#)
    private static let delivery = SourceScan.makeRegex(#"\b(completion|callCompletion)\s*\(|\bthrow\b"#)
    private static let messageText = SourceScan.makeRegex(
        #"\b(customMessage|debugDescription|localizedDescription)\b|\.reason\b"#)

    func testReportCalls_PerFileCounts() throws {
        let files = try SourceScan.files(under: Self.sources)
        XCTAssertFalse(files.isEmpty, "No .swift file under \(Self.sources): wrong repo root")

        for file in files where !file.path.hasPrefix(Self.telemetryDirectory) {
            let count = SourceScan.count(Self.reportCall, in: file.code)
            XCTAssertEqual(count, Self.reportCounts[file.path] ?? 0, "SdkTelemetry.reportSdkError( calls in \(file.path)")
        }
        for path in Self.reportCounts.keys {
            XCTAssertTrue(files.contains { $0.path == path }, "\(path) is missing")
        }
    }

    func testReportCalls_PrecedeTheirDeliveryWithinTheirBlock() throws {
        let calls = try reportCalls()
        XCTAssertEqual(calls.count, Self.reportCounts.values.reduce(0, +))

        for call in calls where !call.argument.hasPrefix("SilentFailure.") {
            let lines = call.file.code
            let token = Self.deliveredToken(of: call.argument)
            let delivers: (String) -> Bool = { line in
                SourceScan.matches(Self.delivery, line) && SourceScan.matches(token, line)
            }
            let start = SourceScan.blockStart(before: call.line, in: lines)
            let end = SourceScan.blockEnd(after: call.end, in: lines)
            let before = lines[(start + 1)..<call.line]
            let after = lines[(call.end + 1)..<end]

            XCTAssertFalse(before.contains(where: delivers),
                           "\(call.file.path):\(call.line + 1) delivers \(call.argument) before reporting it")
            XCTAssertTrue(after.contains(where: delivers),
                          "\(call.file.path):\(call.line + 1) reports \(call.argument) with no delivery after it in its block")
        }
    }

    func testReportCalls_AreNotFollowedByACrash() throws {
        for call in try reportCalls() {
            let lines = call.file.code
            let window = lines[(call.end + 1)..<min(call.end + 4, lines.count)]
            XCTAssertFalse(window.contains { SourceScan.matches(Self.crash, $0) },
                           "\(call.file.path):\(call.line + 1) is followed by a crash within three lines")
        }
    }

    func testTasks_AreCreatedOnlyBySdkTask() throws {
        for file in try SourceScan.files(under: Self.sources) where file.path != Self.sdkTaskFile {
            for (index, line) in file.code.enumerated() where SourceScan.matches(Self.taskCreation, line) {
                XCTFail("\(file.path):\(index + 1) creates a Task; use SdkTask.run")
            }
        }
    }

    func testSdkTaskRun_PerFileCounts() throws {
        let files = try SourceScan.files(under: Self.sources)
        for file in files {
            let count = SourceScan.count(Self.taskRun, in: file.code)
            XCTAssertEqual(count, Self.taskCounts[file.path] ?? 0, "SdkTask.run( sites in \(file.path)")
        }
        XCTAssertEqual(Self.taskCounts.values.reduce(0, +), 39)
    }

    func testTelemetryFiles_ReadNoMessageText() throws {
        let files = try SourceScan.files(under: Self.telemetryDirectory)
        XCTAssertFalse(files.isEmpty)
        for file in files {
            for (index, line) in file.code.enumerated() where SourceScan.matches(Self.messageText, line) {
                XCTFail("\(file.path):\(index + 1) reads message text")
            }
        }
    }

    // MARK: - Helpers

    private struct Call {
        let file: SourceScan.File
        /// The index of the line holding `reportSdkError(`.
        let line: Int
        /// The index of the line that closes the call.
        let end: Int
        /// The reported error expression.
        let argument: String
    }

    /// Every `reportSdkError(` call outside `Telemetry/`, with its first argument.
    private func reportCalls() throws -> [Call] {
        var calls: [Call] = []
        for file in try SourceScan.files(under: Self.sources) where !file.path.hasPrefix(Self.telemetryDirectory) {
            for (index, line) in file.code.enumerated() {
                guard let range = line.range(of: "SdkTelemetry.reportSdkError(") else { continue }
                var statement = String(line[range.upperBound...])
                var end = index
                while !statement.contains("widget:"), end + 1 < file.code.count {
                    end += 1
                    statement += " " + file.code[end].trimmingCharacters(in: .whitespaces)
                }
                let argument = Self.firstArgument(of: statement)
                calls.append(Call(file: file, line: index, end: end, argument: argument))
            }
        }
        return calls
    }

    /// The text before the first top-level comma.
    private static func firstArgument(of text: String) -> String {
        var depth = 0
        var argument = ""
        for character in text {
            if character == "(" { depth += 1 }
            if character == ")" { depth -= 1 }
            if character == ",", depth == 0 { break }
            argument.append(character)
        }
        return argument.trimmingCharacters(in: .whitespaces)
    }

    /// What the delivery names: the identifier itself (`failure`), or the case of an inline value
    /// (`PayPalError.userCancelled` → `.userCancelled`).
    private static func deliveredToken(of argument: String) -> NSRegularExpression {
        if let dot = argument.firstIndex(of: "."), argument.first?.isUppercase == true {
            return SourceScan.makeRegex(NSRegularExpression.escapedPattern(for: String(argument[dot...])))
        }
        return SourceScan.makeRegex(#"\b"# + NSRegularExpression.escapedPattern(for: argument) + #"\b"#)
    }
}
