//
//  AfterPayVMTests+Telemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataCharges

/// R_05, R_06: a non-request failure reports one SDK error and is delivered as before; the request path and the
/// cancellation outcome report nothing; a cancel without a charge ID is reported and still delivers nothing.
/// `tearDown` rebinds the no-op.
extension AfterPayVMTests {

    private func makeTelemetryVM(service: ChargesMockService,
                                 tokenResult: Result<WalletTokenResult, WalletTokenError>,
                                 onCompletion: @escaping (Result<ChargeResponse, AfterpayError>) -> Void) -> AfterpayVM {
        AfterpayVM(viewState: ViewState(),
                   configuration: configuration,
                   tokenRequest: { completion in completion(tokenResult) },
                   selectAddress: nil,
                   selectShippingOption: nil,
                   chargesService: service,
                   loadingDelegate: nil,
                   eventDelegate: nil,
                   completion: onCompletion)
    }

    /// A JWT whose payload carries `meta` → `meta.charge.id`, as `decodeChargeId` reads it.
    private static func tokenWithChargeId(_ chargeId: String) -> String {
        func base64Url(_ object: Any) -> String {
            let data = (try? JSONSerialization.data(withJSONObject: object)) ?? Data()
            return data.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
        }
        let innerMeta = base64Url(["meta": ["charge": ["id": chargeId]]])
        return "e30." + base64Url(["meta": innerMeta]) + ".sig"
    }

    /// Runs the button flow with `token` and a URL fetch that fails without a request error, so the view model
    /// keeps `token` for a later decline, then rebinds the no-op. Each later delivery fulfils `next.expectation`,
    /// once.
    private func storeToken(_ token: String, service: ChargesMockService, next: DeliveryBox) async -> AfterpayVM {
        RecordingTelemetry().bindAsCurrent()
        service.shouldThrowUnknownError = true
        next.expectation = XCTestExpectation(description: "url fetch failure")
        let fetched = next.expectation
        let viewModel = makeTelemetryVM(service: service, tokenResult: .success(WalletTokenResult(token: token))) { result in
            self.completionResult = result
            next.expectation?.fulfill()
            next.expectation = nil
        }
        viewModel.handleButtonTap()
        if let fetched {
            await fulfillment(of: [fetched], timeout: 2.0)
        }
        service.shouldThrowUnknownError = false
        completionResult = nil
        RecordingTelemetry.unbind()   // an active facade stays bound until the no-op replaces it
        return viewModel
    }

    func testTelemetry_UrlFetchNonRequestFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let service = ChargesMockService()
        service.shouldThrowUnknownError = true
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: service, tokenResult: .success(WalletTokenResult(token: "e30.e30"))) { result in
            self.completionResult = result
            expectation.fulfill()
        }

        viewModel.handleButtonTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("AFTERPAY_UNKNOWN", .afterpay)])
    }

    func testTelemetry_UrlFetchRequestFailure_DeliversAsBefore_AndReportsNothing() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let service = ChargesMockService()
        service.shouldReturnError = true
        service.errorToReturn = ErrorRes(status: 400, error: .init(message: "Declined", code: "E1", details: nil),
                                         resource: nil, errorSummary: nil)
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: service, tokenResult: .success(WalletTokenResult(token: "e30.e30"))) { result in
            self.completionResult = result
            expectation.fulfill()
        }

        viewModel.handleButtonTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.errorFetchingAfterpayUrl) = completionResult else {
            return XCTFail("Expected errorFetchingAfterpayUrl, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }

    func testTelemetry_WalletTokenFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let expectation = XCTestExpectation(description: "failure")
        viewModel = makeTelemetryVM(service: ChargesMockService(),
                                    tokenResult: .failure(.initialisingWalletToken(reason: "Token error"))) { result in
            self.completionResult = result
            expectation.fulfill()
        }

        viewModel.handleButtonTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        guard case .failure(.initialisingWalletToken(let reason)) = completionResult else {
            return XCTFail("Expected initialisingWalletToken, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(reason, "Token error")
        XCTAssertEqual(telemetry.sdkErrors, [.reported("AFTERPAY_WALLET_TOKEN_ERROR", .afterpay)])
    }

    func testTelemetry_CancelWithoutChargeId_ReportsOneSdkError_AndDeliversNothing() async {
        let service = ChargesMockService()
        let viewModel = await storeToken("e30.e30.sig", service: service, next: DeliveryBox())
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()

        viewModel.declineWalletTransaction()
        await telemetry.waitForReports(count: 1)

        XCTAssertEqual(telemetry.sdkErrors, [.reported("AFTERPAY_CANCEL_WITHOUT_CHARGE_ID", .afterpay)])
        XCTAssertNil(completionResult, "a cancel without a charge ID delivers nothing, as before")
        XCTAssertTrue(viewModel.isLoading, "loading stays on, as before")
    }

    func testTelemetry_CancelOutcome_DeliversAsBefore_AndReportsNothing() async {
        let service = ChargesMockService()
        let next = DeliveryBox()
        let viewModel = await storeToken(Self.tokenWithChargeId("charge_1"), service: service, next: next)
        let telemetry = RecordingTelemetry()
        telemetry.bindAsCurrent()
        let canceled = XCTestExpectation(description: "cancel")
        next.expectation = canceled

        viewModel.declineWalletTransaction()

        await fulfillment(of: [canceled], timeout: 2.0)
        guard case .failure(.transactionCanceled) = completionResult else {
            return XCTFail("Expected transactionCanceled, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }
}

/// The expectation the next delivery of a stored view model fulfils.
private final class DeliveryBox {
    var expectation: XCTestExpectation?
}
