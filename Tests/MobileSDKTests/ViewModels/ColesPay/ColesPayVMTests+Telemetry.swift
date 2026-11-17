//
//  ColesPayVMTests+Telemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataCharges

/// R_05, R_06: a non-request failure reports one SDK error and is delivered as before; the request path and the
/// cancellation outcome report nothing; a web-view failure is reported by the view model it is handed to.
/// `tearDown` rebinds the no-op.
extension ColesPayVMTests {

    private func makeTelemetryVM(service: ChargesMockService,
                                 tokenResult: Result<WalletTokenResult, WalletTokenError> = .success(
                                    WalletTokenResult(token: "wallet_token")),
                                 expectation: XCTestExpectation? = nil) -> ColesPayVM {
        ColesPayVM(config: config,
                   tokenRequest: { completion in completion(tokenResult) },
                   chargesService: service,
                   viewState: ViewState(),
                   loadingDelegate: nil,
                   eventDelegate: nil,
                   completion: { result in
                       self.completionResult = result
                       expectation?.fulfill()
                   })
    }

    func testTelemetry_OrderNonRequestFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let service = ChargesMockService()
        service.shouldThrowUnknownError = true
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: service, expectation: expectation)

        viewModel.handleButtonTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("COLES_PAY_UNKNOWN", .colesPay)])
    }

    func testTelemetry_OrderRequestFailure_DeliversAsBefore_AndReportsNothing() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let service = ChargesMockService()
        service.shouldReturnError = true
        service.errorToReturn = ErrorRes(status: 400, error: .init(message: "Declined", code: "E1", details: nil),
                                         resource: nil, errorSummary: nil)
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: service, expectation: expectation)

        viewModel.handleButtonTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.errorFetchingColesPayOrder) = completionResult else {
            return XCTFail("Expected errorFetchingColesPayOrder, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }

    func testTelemetry_WalletTokenFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: ChargesMockService(),
                                    tokenResult: .failure(.initialisingWalletToken(reason: "Token error")),
                                    expectation: expectation)

        viewModel.handleButtonTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.initialisingWalletToken(let reason)) = completionResult else {
            return XCTFail("Expected initialisingWalletToken, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(reason, "Token error")
        XCTAssertEqual(telemetry.sdkErrors, [.reported("COLES_PAY_WALLET_TOKEN_ERROR", .colesPay)])
    }

    func testTelemetry_WebViewFailure_ReportsOneSdkError_AndDeliversAsBefore() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(service: ChargesMockService())

        viewModel.handleFailure(error: .webViewFailed(error: NSError(domain: "test", code: -1)))

        guard case .failure(.webViewFailed(let nsError)) = completionResult else {
            return XCTFail("Expected webViewFailed, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(nsError.domain, "test")
        XCTAssertEqual(telemetry.sdkErrors, [.reported("COLES_PAY_WEBVIEW_FAILED", .colesPay)])
    }

    func testTelemetry_Cancellation_DeliversAsBefore_AndReportsNothing() {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        viewModel = makeTelemetryVM(service: ChargesMockService())

        viewModel.handleSheetCancellation()

        guard case .failure(.transactionCanceled) = completionResult else {
            return XCTFail("Expected transactionCanceled, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }
}
