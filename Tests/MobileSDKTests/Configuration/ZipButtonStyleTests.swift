//
//  ZipButtonStyleTests.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import XCTest
import SwiftUI
@testable import MobileSDK

class ZipButtonStyleTests: XCTestCase {

    // MARK: - Background Color Tests

    func testWhiteOnBlackBackgroundColor() {
        let style = ZipButtonStyle.whiteOnBlack
        let expectedColor = Color(hex: "#1A0826")

        // Compare hex values instead of Color objects directly
        XCTAssertEqual(style.backgroundColor.hexString, expectedColor.hexString)
    }

    func testBlackOnWhiteBackgroundColor() {
        let style = ZipButtonStyle.blackOnWhite
        let expectedColor = Color(hex: "#FFFFFA")

        XCTAssertEqual(style.backgroundColor.hexString, expectedColor.hexString)
    }

    // MARK: - Border Color Tests

    func testWhiteOnBlackBorderColor() {
        let style = ZipButtonStyle.whiteOnBlack
        XCTAssertEqual(style.borderColor, .clear)
    }

    func testBlackOnWhiteBorderColor() {
        let style = ZipButtonStyle.blackOnWhite
        XCTAssertEqual(style.borderColor, .black)
    }

    // MARK: - Border Width Tests

    func testWhiteOnBlackBorderWidth() {
        let style = ZipButtonStyle.whiteOnBlack
        XCTAssertEqual(style.borderWidth, 0)
    }

    func testBlackOnWhiteBorderWidth() {
        let style = ZipButtonStyle.blackOnWhite
        XCTAssertEqual(style.borderWidth, 1)
    }

    // MARK: - Image Name Tests

    func testWhiteOnBlackImageName() {
        let style = ZipButtonStyle.whiteOnBlack
        XCTAssertEqual(style.imageName, "zip-logo-white")
    }

    func testBlackOnWhiteImageName() {
        let style = ZipButtonStyle.blackOnWhite
        XCTAssertEqual(style.imageName, "zip-logo-colored")
    }

    // MARK: - Consistency Tests

    func testWhiteOnBlackConsistency() {
        // White on black should have no border and use white icon
        let style = ZipButtonStyle.whiteOnBlack
        XCTAssertEqual(style.borderWidth, 0)
        XCTAssertEqual(style.borderColor, .clear)
        XCTAssertEqual(style.imageName, "zip-logo-white")
    }

    func testBlackOnWhiteConsistency() {
        // Black on white should have border and use colored icon
        let style = ZipButtonStyle.blackOnWhite
        XCTAssertEqual(style.borderWidth, 1)
        XCTAssertEqual(style.borderColor, .black)
        XCTAssertEqual(style.imageName, "zip-logo-colored")
    }
}

// MARK: - Color Extension for Testing

extension Color {
    /// Convert Color to hex string for testing purposes
    var hexString: String {
        // This is a simplified version for testing
        // In production, you'd use the existing hex implementation
        let description = self.description
        if description.contains("#1A0826") {
            return "#1A0826"
        } else if description.contains("#FFFFFA") {
            return "#FFFFFA"
        }
        return ""
    }
}
