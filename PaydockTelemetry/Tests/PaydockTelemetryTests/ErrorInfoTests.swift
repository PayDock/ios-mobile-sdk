//
//  ErrorInfoTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class ErrorInfoTests: XCTestCase {

    private enum Sentinel {
        static let name = "SENTINEL_EXCEPTION_NAME"
        static let reason = "SENTINEL_EXCEPTION_REASON"
        static let userInfoValue = "SENTINEL_USER_INFO_VALUE"
        static let underlyingDescription = "SENTINEL_UNDERLYING_DESCRIPTION"
        static let localizedDescription = "SENTINEL_LOCALIZED_DESCRIPTION"

        /// The name is the exception's type (spec § 5.3), so it is the one sentinel an `ErrorInfo` may carry.
        static let all = [reason, userInfoValue, underlyingDescription, localizedDescription]
    }

    private struct SentinelLocalizedError: LocalizedError {
        var errorDescription: String? { Sentinel.localizedDescription }
    }

    /// Names a fresh instance of itself as its underlying error, so its cause chain never ends on its own.
    private struct SelfReferencingError: CustomNSError {
        var errorUserInfo: [String: Any] { [NSUnderlyingErrorKey: SelfReferencingError()] }
    }

    private struct PlainError: Error {}

    func testFromException_TypeIsItsName_CarriesCause_AndNoMessageText() {
        let underlying = NSError(
            domain: "SampleDomain",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: Sentinel.underlyingDescription]
        )
        let exception = NSException(
            name: NSExceptionName(Sentinel.name),
            reason: Sentinel.reason,
            userInfo: ["sample": Sentinel.userInfoValue, NSUnderlyingErrorKey: underlying]
        )

        let info = TelemetryEvent.ErrorInfo.from(exception, frames: ["ExampleApp 0x1b5058"])

        XCTAssertEqual(info.type, Sentinel.name)
        XCTAssertEqual(info.causeTypes, ["NSError"])
        assertNoSentinel(in: info)
    }

    func testFromLocalizedError_GivesModuleQualifiedType_AndNoMessageText() {
        let info = TelemetryEvent.ErrorInfo.from(SentinelLocalizedError())

        XCTAssertEqual(info.type, String(reflecting: SentinelLocalizedError.self))
        XCTAssertTrue(info.type?.hasPrefix("PaydockTelemetryTests.") == true, info.type ?? "nil")
        XCTAssertTrue(info.causeTypes.isEmpty)
        assertNoSentinel(in: info)
    }

    func testFrames_AreCappedAtMaxFrames() {
        let frames = (0..<100).map { "\($0) Sample 0x0000000100000000" }

        let info = TelemetryEvent.ErrorInfo.from(PlainError(), frames: frames)

        XCTAssertEqual(info.frames.count, TelemetryEvent.ErrorInfo.maxFrames)
        XCTAssertEqual(Set(info.frames), ["Sample 0x0000000100000000"])
    }

    func testFrames_ComeBackSanitised() {
        let frames = [
            "3   MobileSDK      0x0000000104a3c1f0 $s9MobileSDK3fooyyF + 340",
            "4   MobileSDK      0x0000000104a3c1f0 MobileSDK + 1234",
            "MobileSDK 0x0000000104a3c1f0"
        ]

        XCTAssertEqual(
            TelemetryEvent.ErrorInfo.from(PlainError(), frames: frames).frames,
            ["MobileSDK $s9MobileSDK3fooyyF + 340", "MobileSDK 0x0000000104a3c1f0", "MobileSDK 0x0000000104a3c1f0"]
        )
    }

    func testFromException_TakesItsFramesAsGiven() {
        let exception = NSException(name: .invalidArgumentException, reason: Sentinel.reason)
        let frames = ["CoreFoundation __exceptionPreprocess + 164", "ExampleApp 0x1b5058", "??? 0x10"]

        XCTAssertEqual(TelemetryEvent.ErrorInfo.from(exception, frames: frames).frames, frames)
    }

    func testFromException_FramesAreCappedAtMaxFrames() {
        let exception = NSException(name: .invalidArgumentException, reason: Sentinel.reason)
        let frames = (0..<100).map { "ExampleApp 0x\(String($0, radix: 16))" }

        XCTAssertEqual(TelemetryEvent.ErrorInfo.from(exception, frames: frames).frames,
                       Array(frames.prefix(TelemetryEvent.ErrorInfo.maxFrames)))
    }

    func testSelfReferencingCauseChain_TerminatesAtMaxCauses() {
        let info = TelemetryEvent.ErrorInfo.from(SelfReferencingError())

        XCTAssertEqual(info.causeTypes.count, TelemetryEvent.ErrorInfo.maxCauses)
        XCTAssertEqual(Set(info.causeTypes), [String(reflecting: SelfReferencingError.self)])
    }

    func testCause_HasNoFrames() throws {
        let underlying = NSError(domain: "SampleDomain", code: 2)
        let error = NSError(domain: "SampleDomain", code: 1, userInfo: [NSUnderlyingErrorKey: underlying])

        let info = TelemetryEvent.ErrorInfo.from(error, frames: ["0 Sample 0x0000000100000000"])

        let cause = try XCTUnwrap(info.cause)
        XCTAssertTrue(cause.frames.isEmpty)
        XCTAssertEqual(info.frames.count, 1)
    }

    func testFromException_WithAStandardName_GivesTheName() {
        let exception = NSException(name: .invalidArgumentException, reason: Sentinel.reason)

        XCTAssertEqual(TelemetryEvent.ErrorInfo.from(exception, frames: []).type, "NSInvalidArgumentException")
    }

    func testCauseTypes_SkipANilType() {
        let innermost = TelemetryEvent.ErrorInfo(type: "Sample.Inner", frames: [])
        let middle = TelemetryEvent.ErrorInfo(type: nil, frames: [], cause: innermost)
        let info = TelemetryEvent.ErrorInfo(type: "Sample.Outer", frames: [], cause: middle)

        XCTAssertEqual(info.causeTypes, ["Sample.Inner"])
    }

    func testType_MayBeNil_ForFramesWithoutAnException() {
        let info = TelemetryEvent.ErrorInfo(type: nil, frames: ["MobileSDK 0x0000000104a3c1f0"])

        XCTAssertNil(info.type)
        XCTAssertEqual(info.frames, ["MobileSDK 0x0000000104a3c1f0"])
    }

    private func assertNoSentinel(in info: TelemetryEvent.ErrorInfo, file: StaticString = #filePath, line: UInt = #line) {
        let rendered = String(describing: info)
        for sentinel in Sentinel.all {
            XCTAssertFalse(rendered.contains(sentinel), "ErrorInfo carries \(sentinel)", file: file, line: line)
        }
    }
}
