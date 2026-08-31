//
//  AccessibilityAnnouncerTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

final class AccessibilityAnnouncerTests: XCTestCase {

    func testErrorCountMessage_Zero_ReturnsNil() {
        XCTAssertNil(AccessibilityAnnouncer.errorCountMessage(0))
    }

    func testErrorCountMessage_Negative_ReturnsNil() {
        XCTAssertNil(AccessibilityAnnouncer.errorCountMessage(-3))
    }

    func testErrorCountMessage_One_IsSingular() {
        XCTAssertEqual(AccessibilityAnnouncer.errorCountMessage(1), "There is 1 error in form")
    }

    func testErrorCountMessage_Many_IsPlural() {
        XCTAssertEqual(AccessibilityAnnouncer.errorCountMessage(2), "There are 2 errors in form")
        XCTAssertEqual(AccessibilityAnnouncer.errorCountMessage(7), "There are 7 errors in form")
    }
}
