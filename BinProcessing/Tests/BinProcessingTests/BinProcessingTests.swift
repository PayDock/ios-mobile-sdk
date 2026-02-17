//
//  BinProcessingTests.swift
//  BinProcessingTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import BinProcessing

final class BinProcessingTests: XCTestCase {

    func testVersionIsSet() {
        XCTAssertFalse(BinProcessing.version.isEmpty)
        XCTAssertEqual(BinProcessing.version, "1.0.0")
    }

    func testMakeCardSchemeDetectorReturnsDetectorWhenBundleHasJSON() {
        let detector = BinProcessing.makeCardSchemeDetector()
        XCTAssertNotNil(detector)
    }

    func testDetectSchemeVisaWith2Digits() {
        guard let detector = BinProcessing.makeCardSchemeDetector() else {
            XCTFail("Detector should load from bundle")
            return
        }
        let result = detector.detectScheme(pan: "41")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.scheme, "visa")
        XCTAssertEqual(result?.detectedAt, 2)
        XCTAssertEqual(result?.length, 2)
    }

    func testDetectSchemeVisaWith4Digits() {
        guard let detector = BinProcessing.makeCardSchemeDetector() else {
            XCTFail("Detector should load from bundle")
            return
        }
        let result = detector.detectScheme(pan: "4111")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.scheme, "visa")
    }

    func testDetectSchemeReturnsNilForSingleDigit() {
        guard let detector = BinProcessing.makeCardSchemeDetector() else {
            XCTFail("Detector should load from bundle")
            return
        }
        XCTAssertNil(detector.detectScheme(pan: "4"))
    }

    func testDetectSchemeStripsNonDigits() {
        guard let detector = BinProcessing.makeCardSchemeDetector() else {
            XCTFail("Detector should load from bundle")
            return
        }
        let result = detector.detectScheme(pan: "41 11 1111")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.scheme, "visa")
        XCTAssertEqual(result?.length, 8)
    }
}
