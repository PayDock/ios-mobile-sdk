//
//  ZipStatusTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

class ZipStatusTests: XCTestCase {

    // MARK: - Raw Value Tests

    func testApprovedRawValue() {
        XCTAssertEqual(ZipStatus.approved.rawValue, "approved")
    }

    func testDeclinedRawValue() {
        XCTAssertEqual(ZipStatus.declined.rawValue, "declined")
    }

    func testCancelledRawValue() {
        XCTAssertEqual(ZipStatus.cancelled.rawValue, "cancelled")
    }

    func testReferredRawValue() {
        XCTAssertEqual(ZipStatus.referred.rawValue, "referred")
    }

    func testUnexpectedRawValue() {
        XCTAssertEqual(ZipStatus.unexpected.rawValue, "unexpected")
    }

    func testUnexpectedErrorRawValue() {
        XCTAssertEqual(ZipStatus.unexpectedError.rawValue, "unexpected_error")
    }

    // MARK: - Initialization from Raw Value Tests

    func testInitFromApprovedRawValue() {
        let status = ZipStatus(rawValue: "approved")
        XCTAssertEqual(status, .approved)
    }

    func testInitFromDeclinedRawValue() {
        let status = ZipStatus(rawValue: "declined")
        XCTAssertEqual(status, .declined)
    }

    func testInitFromCancelledRawValue() {
        let status = ZipStatus(rawValue: "cancelled")
        XCTAssertEqual(status, .cancelled)
    }

    func testInitFromReferredRawValue() {
        let status = ZipStatus(rawValue: "referred")
        XCTAssertEqual(status, .referred)
    }

    func testInitFromUnexpectedRawValue() {
        let status = ZipStatus(rawValue: "unexpected")
        XCTAssertEqual(status, .unexpected)
    }

    func testInitFromUnexpectedErrorRawValue() {
        let status = ZipStatus(rawValue: "unexpected_error")
        XCTAssertEqual(status, .unexpectedError)
    }

    func testInitFromInvalidRawValue() {
        let status = ZipStatus(rawValue: "invalid_status")
        XCTAssertNil(status)
    }

    // MARK: - isSuccess Property Tests

    func testApprovedIsSuccess() {
        XCTAssertTrue(ZipStatus.approved.isSuccess)
    }

    func testDeclinedIsNotSuccess() {
        XCTAssertFalse(ZipStatus.declined.isSuccess)
    }

    func testCancelledIsNotSuccess() {
        XCTAssertFalse(ZipStatus.cancelled.isSuccess)
    }

    func testReferredIsNotSuccess() {
        XCTAssertFalse(ZipStatus.referred.isSuccess)
    }

    func testUnexpectedIsNotSuccess() {
        XCTAssertFalse(ZipStatus.unexpected.isSuccess)
    }

    func testUnexpectedErrorIsNotSuccess() {
        XCTAssertFalse(ZipStatus.unexpectedError.isSuccess)
    }

    // MARK: - isError Property Tests

    func testDeclinedIsError() {
        XCTAssertTrue(ZipStatus.declined.isError)
    }

    func testReferredIsError() {
        XCTAssertTrue(ZipStatus.referred.isError)
    }

    func testUnexpectedErrorIsError() {
        XCTAssertTrue(ZipStatus.unexpectedError.isError)
    }

    func testUnexpectedIsError() {
        XCTAssertTrue(ZipStatus.unexpected.isError)
    }

    func testApprovedIsNotError() {
        XCTAssertFalse(ZipStatus.approved.isError)
    }

    func testCancelledIsNotError() {
        XCTAssertFalse(ZipStatus.cancelled.isError)
    }

    // MARK: - isCancellation Property Tests

    func testCancelledIsCancellation() {
        XCTAssertTrue(ZipStatus.cancelled.isCancellation)
    }

    func testApprovedIsNotCancellation() {
        XCTAssertFalse(ZipStatus.approved.isCancellation)
    }

    func testDeclinedIsNotCancellation() {
        XCTAssertFalse(ZipStatus.declined.isCancellation)
    }

    func testReferredIsNotCancellation() {
        XCTAssertFalse(ZipStatus.referred.isCancellation)
    }

    func testUnexpectedIsNotCancellation() {
        XCTAssertFalse(ZipStatus.unexpected.isCancellation)
    }

    func testUnexpectedErrorIsNotCancellation() {
        XCTAssertFalse(ZipStatus.unexpectedError.isCancellation)
    }

    // MARK: - Codable Tests

    func testEncodingApproved() throws {
        let status = ZipStatus.approved
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "\"approved\"")
    }

    func testDecodingApproved() throws {
        let json = Data("\"approved\"".utf8)
        let decoder = JSONDecoder()
        let status = try decoder.decode(ZipStatus.self, from: json)
        XCTAssertEqual(status, .approved)
    }

    func testEncodingDeclined() throws {
        let status = ZipStatus.declined
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "\"declined\"")
    }

    func testDecodingDeclined() throws {
        let json = Data("\"declined\"".utf8)
        let decoder = JSONDecoder()
        let status = try decoder.decode(ZipStatus.self, from: json)
        XCTAssertEqual(status, .declined)
    }

    // MARK: - ZipCallbackData Tests

    func testZipCallbackDataInitialization() {
        let callbackData = ZipCallbackData(
            status: .approved,
            checkoutId: "checkout_123",
            orderId: "order_456"
        )

        XCTAssertEqual(callbackData.status, .approved)
        XCTAssertEqual(callbackData.checkoutId, "checkout_123")
        XCTAssertEqual(callbackData.orderId, "order_456")
    }

    func testZipCallbackDataIdentifierPrefersCheckoutId() {
        let callbackData = ZipCallbackData(
            status: .approved,
            checkoutId: "checkout_123",
            orderId: "order_456"
        )

        XCTAssertEqual(callbackData.identifier, "checkout_123")
    }

    func testZipCallbackDataIdentifierFallsBackToOrderId() {
        let callbackData = ZipCallbackData(
            status: .approved,
            checkoutId: nil,
            orderId: "order_456"
        )

        XCTAssertEqual(callbackData.identifier, "order_456")
    }

    func testZipCallbackDataIdentifierNilWhenBothNil() {
        let callbackData = ZipCallbackData(
            status: .declined,
            checkoutId: nil,
            orderId: nil
        )

        XCTAssertNil(callbackData.identifier)
    }

    func testZipCallbackDataWithOptionalValues() {
        let callbackData = ZipCallbackData(
            status: .cancelled,
            checkoutId: nil,
            orderId: nil
        )

        XCTAssertEqual(callbackData.status, .cancelled)
        XCTAssertNil(callbackData.checkoutId)
        XCTAssertNil(callbackData.orderId)
    }
}
