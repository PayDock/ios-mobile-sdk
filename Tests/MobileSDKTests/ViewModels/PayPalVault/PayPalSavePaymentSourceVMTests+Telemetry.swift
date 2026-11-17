//
//  PayPalSavePaymentSourceVMTests+Telemetry.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
@testable import NetworkingLib
@testable import DataPaymentSources

/// R_05, R_06: a non-request failure reports one SDK error and is delivered as before; the request path reports
/// nothing. `tearDown` rebinds the no-op.
extension PayPalSavePaymentSourceVMTests {

    private func makeTelemetryVM() -> PayPalSavePaymentSourceVM {
        PayPalSavePaymentSourceVM(
            viewState: viewState,
            config: config,
            paymentSourcesService: mockPaymentSourcesService,
            gatewayService: mockGatewayService,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: { result in
                self.completionResult = result
            }
        )
    }

    func testTelemetry_SetupTokenNonRequestFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        telemetry.bindAsCurrent()
        mockPaymentSourcesService.shouldThrowUnknownError = true
        viewModel = makeTelemetryVM()

        let setupTokenData = await viewModel.getSetupTokenData()

        XCTAssertNil(setupTokenData)
        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("PAYPAL_VAULT_UNKNOWN", .payPalSavePaymentSource)])
    }

    func testTelemetry_PaymentTokenNonRequestFailure_ReportsOneSdkError_AndDeliversAsBefore() async {
        telemetry.bindAsCurrent()
        mockPaymentSourcesService.shouldThrowUnknownError = true
        viewModel = makeTelemetryVM()

        await viewModel.createPaymentToken(setupToken: "setup-token")

        guard case .failure(.unknownError(nil)) = completionResult else {
            return XCTFail("Expected unknownError(nil), got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.sdkErrors, [.reported("PAYPAL_VAULT_UNKNOWN", .payPalSavePaymentSource)])
    }

    func testTelemetry_SetupTokenRequestFailure_DeliversAsBefore_AndReportsNothing() async {
        telemetry.bindAsCurrent()
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = ErrorRes(status: 400, error: .init(message: "Bad", code: "BAD", details: nil),
                                                           resource: nil, errorSummary: nil)
        viewModel = makeTelemetryVM()

        let setupTokenData = await viewModel.getSetupTokenData()

        XCTAssertNil(setupTokenData)
        guard case .failure(.createSetupToken) = completionResult else {
            return XCTFail("Expected createSetupToken, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }

    func testTelemetry_ClientIdRequestFailure_DeliversAsBefore_AndReportsNothing() async {
        telemetry.bindAsCurrent()
        mockGatewayService.shouldReturnError = true
        mockGatewayService.errorToReturn = ErrorRes(status: 500, error: .init(message: "Test Error", code: "TEST", details: nil),
                                                    resource: nil, errorSummary: nil)
        viewModel = makeTelemetryVM()

        let clientId = await viewModel.getClientId()

        XCTAssertNil(clientId)
        guard case .failure(.getPayPalClientId) = completionResult else {
            return XCTFail("Expected getPayPalClientId, got: \(String(describing: completionResult))")
        }
        XCTAssertEqual(telemetry.reports, [])
    }
}
