//
//  ChargesMockService.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import CommonModels
import NetworkingLib

/// Mock service for ChargesService that returns fake data for testing
public class ChargesMockService: ChargesService {

    // MARK: - Test Configuration

    public var shouldReturnError = false
    public var errorToReturn: ErrorRes?
    public var shouldThrowUnknownError = false

    // MARK: - Configurable Results

    public var walletCaptureResult: WalletCaptureChargeData?
    public var payPalCallbackResult: String?
    public var afterpayCallbackResult: String?
    public var colesPayCallbackResult: String?
    public var declineResult: String?

    public init() {}

    public func initialiseWalletCharge(
        initializeWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String
    ) async throws -> String {
        return "mock-wallet-token-123"
    }

    public func initialiseColesPayWalletCharge(
        initializeWalletChargeReq: InitialiseWalletChargeReq, apiAccessToken: String
    ) async throws -> InitialiseWalletData {
        return InitialiseWalletData(
            token: "mock-coles-pay-token-456",
            charge: InitialiseWalletChargeData(
                id: "mock-charge-123",
                amount: initializeWalletChargeReq.amount,
                currency: initializeWalletChargeReq.currency,
                reference: initializeWalletChargeReq.reference,
                status: "pending",
                capture: true,
                transactions: []
            )
        )
    }

    public func captureCharge(request: CaptureChargeReq, apiAccessToken: String) async throws -> CaptureChargeResource {
        return CaptureChargeResource(
            type: "charge",
            data: CaptureChargeData(
                transfer: CaptureChargeTransfer(items: []),
                schedule: CaptureChargeSchedule(stopped: false),
                statistics: CaptureChargeStatistics(totalRefundedAmount: 0, fullRefund: false, needSync: false),
                customer: Customer(id: "mock-customer-123"),
                id: "mock-charge-789",
                type: "financial",
                amount: Decimal(string: request.amount) ?? 0,
                currency: request.currency,
                status: "complete",
                companyId: "mock-company-123",
                brandId: nil,
                capture: true,
                authorization: false,
                archived: false,
                description: request.description,
                oneOff: true,
                reference: request.reference ?? "mock-reference",
                items: nil,
                transactions: [],
                updatedAt: "2024-01-01T00:00:00Z",
                createdAt: "2024-01-01T00:00:00Z",
                value: 1,
                externalId: "mock-external-123",
                meta: nil,
                logsMigrated: nil,
                tokenId: nil
            )
        )
    }

    public func captureChargeForStandaloneFlow(
        request: CaptureChargeStandaloneReq, apiAccessToken: String
    ) async throws -> CaptureChargeResource {
        return CaptureChargeResource(
            type: "charge",
            data: CaptureChargeData(
                transfer: CaptureChargeTransfer(items: []),
                schedule: CaptureChargeSchedule(stopped: false),
                statistics: CaptureChargeStatistics(totalRefundedAmount: 0, fullRefund: false, needSync: false),
                customer: Customer(id: "mock-customer-456"),
                id: "mock-standalone-charge-456",
                type: "financial",
                amount: Decimal(string: request.amount) ?? 0,
                currency: request.currency,
                status: "complete",
                companyId: "mock-company-123",
                brandId: nil,
                capture: true,
                authorization: false,
                archived: false,
                description: request.description,
                oneOff: true,
                reference: request.reference,
                items: nil,
                transactions: [],
                updatedAt: "2024-01-01T00:00:00Z",
                createdAt: "2024-01-01T00:00:00Z",
                value: 1,
                externalId: "mock-external-456",
                meta: nil,
                logsMigrated: nil,
                tokenId: nil
            )
        )
    }

    public func captureChargeColesPay(chargeId: String, apiAccessToken: String) async throws -> CaptureChargeResource {
        return CaptureChargeResource(
            type: "charge",
            data: CaptureChargeData(
                transfer: CaptureChargeTransfer(items: []),
                schedule: CaptureChargeSchedule(stopped: false),
                statistics: CaptureChargeStatistics(totalRefundedAmount: 0, fullRefund: false, needSync: false),
                customer: Customer(id: "mock-customer-789"),
                id: chargeId,
                type: "financial",
                amount: 100.0,
                currency: "AUD",
                status: "complete",
                companyId: "mock-company-123",
                brandId: nil,
                capture: true,
                authorization: false,
                archived: false,
                description: nil,
                oneOff: true,
                reference: "mock-coles-pay-reference",
                items: nil,
                transactions: [],
                updatedAt: "2024-01-01T00:00:00Z",
                createdAt: "2024-01-01T00:00:00Z",
                value: 1,
                externalId: "mock-external-789",
                meta: nil,
                logsMigrated: nil,
                tokenId: nil
            )
        )
    }

    public func captureWalletCharge(
        widgetAccessToken: String, paymentMethodId: String?, refToken: String?
    ) async throws -> WalletCaptureChargeData {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return walletCaptureResult ?? WalletCaptureChargeData(
            status: "complete",
            amount: 50.0,
            currency: "AUD"
        )
    }

    public func getColesPayCallback(widgetAccessToken: String) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return colesPayCallbackResult ?? "mock-coles-pay-id-456"
    }

    public func getPayPalCallback(widgetAccessToken: String, requestShipping: Bool) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return payPalCallbackResult ?? "mock-paypal-id-789"
    }

    public func getAfterpayCallback(widgetAccessToken: String) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return afterpayCallbackResult ?? "mock-afterpay-ref-token-321"
    }

    public func declineWalletTransaction(widgetAccessToken: String, chargeId: String) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return declineResult ?? "declined"
    }
}
