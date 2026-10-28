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

        static let all = [name, reason, userInfoValue, underlyingDescription, localizedDescription]
    }

    private struct SentinelLocalizedError: LocalizedError {
        var errorDescription: String? { Sentinel.localizedDescription }
    }

    /// Names a fresh instance of itself as its underlying error, so its cause chain never ends on its own.
    private struct SelfReferencingError: CustomNSError {
        var errorUserInfo: [String: Any] { [NSUnderlyingErrorKey: SelfReferencingError()] }
    }

    private struct PlainError: Error {}

    func testFromException_CarriesTypeAndCause_AndNoMessageText() {
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

        let info = TelemetryEvent.ErrorInfo.from(exception)

        XCTAssertEqual(info.type, "NSException")
        XCTAssertEqual(info.causeTypes, ["NSError"])
        assertNoSentinel(in: info)
    }

    func testFromLocalizedError_GivesModuleQualifiedType_AndNoMessageText() {
        let info = TelemetryEvent.ErrorInfo.from(SentinelLocalizedError())

        XCTAssertEqual(info.type, String(reflecting: SentinelLocalizedError.self))
        XCTAssertTrue(info.type.hasPrefix("PaydockTelemetryTests."), info.type)
        XCTAssertTrue(info.causeTypes.isEmpty)
        assertNoSentinel(in: info)
    }

    func testFrames_AreCappedAtMaxFrames() {
        let frames = (0..<100).map { "\($0) Sample 0x0000000100000000" }

        let info = TelemetryEvent.ErrorInfo.from(PlainError(), frames: frames)

        XCTAssertEqual(info.frames.count, TelemetryEvent.ErrorInfo.maxFrames)
        XCTAssertEqual(info.frames, Array(frames.prefix(TelemetryEvent.ErrorInfo.maxFrames)))
    }

    func testFrames_AreKeptAsGivenBelowTheCap() {
        let frames = ["0 Sample 0x0000000100000000", "1 Sample 0x0000000100000010"]

        XCTAssertEqual(TelemetryEvent.ErrorInfo.from(PlainError(), frames: frames).frames, frames)
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

    private func assertNoSentinel(in info: TelemetryEvent.ErrorInfo, file: StaticString = #filePath, line: UInt = #line) {
        let rendered = String(describing: info)
        for sentinel in Sentinel.all {
            XCTAssertFalse(rendered.contains(sentinel), "ErrorInfo carries \(sentinel)", file: file, line: line)
        }
    }
}
