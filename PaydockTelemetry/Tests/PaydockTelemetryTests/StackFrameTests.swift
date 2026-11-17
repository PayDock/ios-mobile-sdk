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

    // MARK: - describe (R_08)

    private static let appPath = "/private/var/containers/Bundle/Application/0A1B2C3D/ExampleApp.app/ExampleApp"
    private static let uikitPath = "/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore"

    func testAFrameInANonSystemImage_GivesTheOffsetForm() {
        let resolved = ResolvedAddress(imagePath: Self.appPath, imageLoadAddress: 0x1_0400_0000,
                                       symbol: "$s9MobileSDK3fooyyF", symbolAddress: 0x1_041b_5000)

        XCTAssertEqual(StackFrame.describe(0x1_041b_5058, resolved), "ExampleApp 0x1b5058")
    }

    func testASystemImageWithASymbol_GivesTheSymbolAndDistance() {
        let resolved = ResolvedAddress(imagePath: "/usr/lib/libobjc.A.dylib", imageLoadAddress: 0x1_8000_0000,
                                       symbol: "objc_exception_throw", symbolAddress: 0x1_8001_0000)

        XCTAssertEqual(StackFrame.describe(0x1_8001_003c, resolved), "libobjc.A.dylib objc_exception_throw + 60")
    }

    func testASystemImageWithoutASymbol_GivesTheOffsetForm() {
        let resolved = ResolvedAddress(imagePath: Self.uikitPath, imageLoadAddress: 0x1_a000_0000, symbol: nil, symbolAddress: nil)

        XCTAssertEqual(StackFrame.describe(0x1_a058_f740, resolved), "UIKitCore 0x58f740")
        let empty = ResolvedAddress(imagePath: Self.uikitPath, imageLoadAddress: 0x1_a000_0000, symbol: "", symbolAddress: 0x1_a000_0000)
        XCTAssertEqual(StackFrame.describe(0x1_a058_f740, empty), "UIKitCore 0x58f740")
    }

    func testUnresolved_GivesTheAddress() {
        XCTAssertEqual(StackFrame.describe(0x1_041b_5058, nil), "??? 0x1041b5058")
    }

    func testHex_IsLowercaseWithoutPadding() {
        let resolved = ResolvedAddress(imagePath: Self.appPath, imageLoadAddress: 0x1_0000_0000, symbol: nil, symbolAddress: nil)

        XCTAssertEqual(StackFrame.describe(0x1_0000_00ab, resolved), "ExampleApp 0xab")
        XCTAssertEqual(StackFrame.describe(0x1_0000_0000, resolved), "ExampleApp 0x0")
    }

    func testIsSystemImage() {
        let runtimeRoot = "/Library/Developer/CoreSimulator/Volumes/iOS_23E244/Library/Developer/CoreSimulator/Profiles/Runtimes/"
            + "iOS 26.4.simruntime/Contents/Resources/RuntimeRoot"
        XCTAssertTrue(StackFrame.isSystemImage(Self.uikitPath))
        XCTAssertTrue(StackFrame.isSystemImage("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"))
        XCTAssertTrue(StackFrame.isSystemImage("/usr/lib/libobjc.A.dylib"))
        XCTAssertTrue(StackFrame.isSystemImage("/usr/lib/system/libdyld.dylib"))
        XCTAssertTrue(StackFrame.isSystemImage(runtimeRoot + "/System/Library/Frameworks/UIKit.framework/UIKit"))
        XCTAssertTrue(StackFrame.isSystemImage(runtimeRoot + "/usr/lib/libobjc.A.dylib"))
        XCTAssertFalse(StackFrame.isSystemImage(Self.appPath))
        XCTAssertFalse(StackFrame.isSystemImage(
            "/Users/sample/Library/Developer/CoreSimulator/Devices/0A1B/data/Containers/Bundle/Application/2C3D/ExampleApp.app/ExampleApp"
        ))
    }
}
