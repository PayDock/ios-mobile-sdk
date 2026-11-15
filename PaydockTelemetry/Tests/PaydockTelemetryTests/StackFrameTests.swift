//
//  StackFrameTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class StackFrameTests: XCTestCase {

    func testSymbolicatedFrame_KeepsImageSymbolAndOffset() {
        XCTAssertEqual(
            StackFrame.sanitise("3   MobileSDK      0x0000000104a3c1f0 $s9MobileSDK3fooyyF + 340"),
            "MobileSDK $s9MobileSDK3fooyyF + 340"
        )
    }

    func testSymbolEqualToTheImage_GivesTheAddressForm() {
        XCTAssertEqual(StackFrame.sanitise("4   MobileSDK      0x0000000104a3c1f0 MobileSDK + 1234"), "MobileSDK 0x0000000104a3c1f0")
    }

    func testSanitisedFrame_IsUnchanged() {
        XCTAssertEqual(StackFrame.sanitise("MobileSDK 0x0000000104a3c1f0"), "MobileSDK 0x0000000104a3c1f0")
        XCTAssertEqual(StackFrame.sanitise("MobileSDK $s9MobileSDK3fooyyF + 340"), "MobileSDK $s9MobileSDK3fooyyF + 340")
    }

    func testUnknownSymbol_GivesTheAddressForm() {
        XCTAssertEqual(StackFrame.sanitise("5   MobileSDK   0x0000000104a3c1f0 ??? + 0"), "MobileSDK 0x0000000104a3c1f0")
        XCTAssertEqual(StackFrame.sanitise("5   MobileSDK   0x0000000104a3c1f0 ???"), "MobileSDK 0x0000000104a3c1f0")
    }

    func testMissingSymbol_GivesTheAddressForm() {
        XCTAssertEqual(StackFrame.sanitise("6   MobileSDK   0x0000000104a3c1f0"), "MobileSDK 0x0000000104a3c1f0")
    }

    func testExtraPadding_IsRemoved() {
        XCTAssertEqual(
            StackFrame.sanitise("  12    CoreFoundation   0x00000001804b6c3c  -[NSObject(NSObject) doesNotRecognizeSelector:]  +  132 \n"),
            "CoreFoundation -[NSObject(NSObject) doesNotRecognizeSelector:] + 132"
        )
        XCTAssertEqual(StackFrame.sanitise("   MobileSDK 0x0000000104a3c1f0   "), "MobileSDK 0x0000000104a3c1f0")
    }
}
