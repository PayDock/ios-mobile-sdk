//
//  ZipVMTests+Telemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataPaymentSources

/// R_05, R_06: a non-request failure reports one SDK error and is delivered as before; the request path and the
/// provider's outcomes report nothing; a web-view failure is reported by the view model it is handed to.
/// `tearDown` rebinds the no-op.
extension ZipVMTests {

    private func makeTelemetryVM(service: PaymentSourcesMockService,
                                 expectation: XCTestExpectation? = nil) -> ZipVM {
        ZipVM(viewState: ViewState(),
              config: config,
              paymentSourcesService: service,
              loadingDelegate: nil,
              eventDelegate: nil) { result in
            self.completionResult = result
            expectation?.fulfill()
        }
    }

    func testTelemetry_CheckoutNonRequestFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let service = PaymentSourcesMockService()
        service.shouldThrowUnknownError = true
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: service, expectation: expectation)

        viewModel.createZipCheckout()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("ZIP_UNKNOWN", .zip)])
    }

    func testTelemetry_InvalidCheckoutUrl_ReportsOneSdkError_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let service = PaymentSourcesMockService()
        service.externalCheckoutResult = (link: "httpsandbox.zip.co/checkout", checkoutToken: "token")
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: service, expectation: expectation)

        viewModel.createZipCheckout()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.invalidCheckoutUrl) = completionResult else {
            return XCTFail("Expected invalidCheckoutUrl, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("ZIP_INVALID_CHECKOUT_URL", .zip)])
    }

    func testTelemetry_CheckoutRequestFailure_DeliversAsBefore_AndReportsNothing() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let service = PaymentSourcesMockService()
        service.shouldReturnError = true
        service.errorToReturn = ErrorRes(status: 400, error: .init(message: "Declined", code: "E1", details: nil),
                                         resource: nil, errorSummary: nil)
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: service, expectation: expectation)

        viewModel.createZipCheckout()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.errorFetchingZipUrl) = completionResult else {
            return XCTFail("Expected errorFetchingZipUrl, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }

    func testTelemetry_ConfirmationWithoutCheckoutToken_ReportsOneSdkError_AndDeliversAsBefore() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(service: PaymentSourcesMockService())

        viewModel.handleZipConfirmation(callbackData: ZipCallbackData(status: .approved, checkoutId: "co_1", orderId: nil))

        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("ZIP_UNKNOWN", .zip)])
    }

    func testTelemetry_WebViewFailure_ReportsOneSdkError_AndDeliversAsBefore() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(service: PaymentSourcesMockService())

        viewModel.handleWebViewFailure(.webViewFailed(error: NSError(domain: "test", code: -1)))

        guard case .failure(.webViewFailed(let nsError)) = completionResult else {
            return XCTFail("Expected webViewFailed, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(nsError.domain, "test")
        XCTAssertEqual(telemetry.sdkErrors, [.reported("ZIP_WEBVIEW_FAILED", .zip)])
    }

    func testTelemetry_Outcomes_DeliverAsBefore_AndReportNothing() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(service: PaymentSourcesMockService())

        viewModel.handleWebViewFailure(.transactionDeclined(checkoutId: "co_1"))
        guard case .failure(.transactionDeclined) = completionResult else {
            return XCTFail("Expected transactionDeclined, got: \(String(describing: completionResult))")
        }
        viewModel.handleSheetCancellation()
        guard case .failure(.transactionCanceled(nil)) = completionResult else {
            return XCTFail("Expected transactionCanceled(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }
}
