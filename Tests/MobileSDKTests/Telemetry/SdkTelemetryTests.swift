//
//  SdkTelemetryTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
@testable import NetworkingLib
import PaydockTelemetry

final class SdkTelemetryTests: XCTestCase {

    private static let errorRes = ErrorRes(status: 400, error: .init(message: "Declined", code: "declined", details: nil),
                                           resource: nil, errorSummary: nil)

    private let telemetry = RecordingTelemetry()

    override func setUp() {
        super.setUp()
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
    }

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        super.tearDown()
    }

    // MARK: - reportSdkError

    func testReportSdkError_ReportsOnce_WithItsCodeWidgetKindAndASite() throws {
        SdkTelemetry.reportSdkError(SilentFailure.afterpayNoPresenter, widget: .afterpay, telemetry: telemetry)

        let report = try XCTUnwrap(telemetry.reports.first)
        XCTAssertEqual(telemetry.reports.count, 1)
        XCTAssertEqual(report.event, .sdkError(
            error: TelemetryEvent.ErrorInfo(type: "MobileSDK.SilentFailure", frames: []),
            errorCode: "AFTERPAY_NO_PRESENTER",
            widget: "AfterpayWidget"
        ))
        let site = try XCTUnwrap(report.site)
        XCTAssertFalse(site.returnAddresses.isEmpty)
        XCTAssertLessThanOrEqual(site.returnAddresses.count, TelemetryEvent.ErrorInfo.maxFrames)
        XCTAssertEqual(site.threadName, "main")
    }

    func testReportSdkError_AWidgetErrorWithACause_ReportsItsCauseChain() throws {
        let failure = ZipError.webViewFailed(error: NSError(domain: "WebKitErrorDomain", code: 102))

        SdkTelemetry.reportSdkError(failure, widget: .zip, telemetry: telemetry)

        guard case let .sdkError(error, errorCode, widget, apiError, _) = try XCTUnwrap(telemetry.events.first) else {
            return XCTFail("Expected an SDK error")
        }
        XCTAssertEqual(error.type, "MobileSDK.ZipError")
        XCTAssertEqual(error.causeTypes, ["NSError WebKitErrorDomain 102"])
        XCTAssertEqual(errorCode, "ZIP_WEBVIEW_FAILED")
        XCTAssertEqual(widget, "ZipWidget")
        XCTAssertNil(apiError)
    }

    func testReportSdkError_NoWidget_ReportsWithoutOne() {
        SdkTelemetry.reportSdkError(PayPalDataCollectorError.parsingError, widget: nil, telemetry: telemetry)

        XCTAssertEqual(telemetry.events, [.sdkError(
            error: TelemetryEvent.ErrorInfo(type: "MobileSDK.PayPalDataCollectorError", frames: []),
            errorCode: "PAYPAL_DATA_COLLECTOR_PARSING_ERROR"
        )])
    }

    /// The request rule (MD-39): a request error, a widget error wrapping one and a widget error holding an error body
    /// send nothing.
    func testReportSdkError_RequestCaused_SendsNothing() {
        let errors: [any Error] = [
            RequestError.noResponse,
            RequestError.connectionError(URLError(.timedOut)),
            RequestError.requestError(Self.errorRes),
            CardDetailsError.unknownError(.connectionError(URLError(.notConnectedToInternet))),
            AfterpayError.unknownError(.decode(nil)),
            CardDetailsError.errorTokenisingCard(error: Self.errorRes),
            PayPalVaultError.createSetupToken(error: Self.errorRes),
            PayPalDataCollectorError.initialisationClientId(error: Self.errorRes)
        ]

        for error in errors {
            SdkTelemetry.reportSdkError(error, widget: .cardDetails, telemetry: telemetry)
        }

        XCTAssertEqual(telemetry.reports, [])
    }

    func testReportSdkError_OutcomesAndACancellation_SendNothing() {
        let errors: [any Error] = [
            AfterpayError.transactionCanceled,
            ApplePayError.userCanceledPayment,
            ColesPayError.transactionCanceled,
            PayPalError.userCancelled,
            PayPalVaultError.userCancelled,
            ZipError.transactionCanceled(checkoutId: nil),
            ZipError.transactionDeclined(checkoutId: nil),
            ZipError.transactionReferred(checkoutId: nil),
            CancellationError()
        ]

        for error in errors {
            SdkTelemetry.reportSdkError(error, widget: .zip, telemetry: telemetry)
        }

        XCTAssertEqual(telemetry.reports, [])
    }

    func testReportSdkError_AnUnknownErrorWithoutARequestError_IsReported() {
        SdkTelemetry.reportSdkError(CardDetailsError.unknownError(nil), widget: .cardDetails, telemetry: telemetry)

        XCTAssertEqual(telemetry.events.count, 1)
    }

    // MARK: - Inactive

    func testInactive_ReceivesNothing() {
        let inactive = RecordingTelemetry(isActive: false)

        SdkTelemetry.reportSdkError(SilentFailure.cardExpiryUnreadable, widget: .cardDetails, telemetry: inactive)
        SdkTelemetry.reportUncaught(SampleSwiftError(), widget: .cardDetails, telemetry: inactive)
        SdkTelemetry.reportWidgetOpened(.cardDetails, telemetry: inactive)

        XCTAssertEqual(inactive.reports, [])
    }

    // MARK: - reportUncaught

    func testReportUncaught_ReportsAnUncaughtException_WithItsWidgetAndASite() throws {
        SdkTelemetry.reportUncaught(SampleSwiftError(), widget: .giftCard, telemetry: telemetry)

        let report = try XCTUnwrap(telemetry.reports.first)
        XCTAssertEqual(telemetry.reports.count, 1)
        XCTAssertEqual(report.event, .uncaughtException(
            error: TelemetryEvent.ErrorInfo(type: "MobileSDKTests.SampleSwiftError", frames: []),
            widget: "GiftCardWidget"
        ))
        XCTAssertFalse(try XCTUnwrap(report.site).returnAddresses.isEmpty)
    }

    func testReportUncaught_ARequestError_IsReported() {
        SdkTelemetry.reportUncaught(RequestError.noResponse, widget: nil, telemetry: telemetry)

        XCTAssertEqual(telemetry.events, [.uncaughtException(
            error: TelemetryEvent.ErrorInfo(type: "NetworkingLib.RequestError.noResponse", frames: [])
        )])
    }

    func testReportUncaught_ACancellation_SendsNothing() {
        SdkTelemetry.reportUncaught(CancellationError(), widget: .giftCard, telemetry: telemetry)

        XCTAssertEqual(telemetry.reports, [])
    }

    // MARK: - reportWidgetOpened

    func testReportWidgetOpened_ReportsTheName_WithoutASite() {
        SdkTelemetry.reportWidgetOpened(.mpgs3ds, telemetry: telemetry)

        XCTAssertEqual(telemetry.reports, [RecordingTelemetry.Report(event: .widgetOpened(widget: "MPGS3dsWidget"), site: nil)])
    }

    // MARK: - The bound facade

    func testTheCalls_DefaultToTheBoundFacade() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: telemetry, runtime: NoOpTelemetry()))

        SdkTelemetry.reportSdkError(SilentFailure.clickToPayTokenMissing, widget: .clickToPay)
        SdkTelemetry.reportUncaught(SampleSwiftError(), widget: .clickToPay)
        SdkTelemetry.reportWidgetOpened(.clickToPay)

        XCTAssertEqual(telemetry.reports.count, 3)
    }
}
