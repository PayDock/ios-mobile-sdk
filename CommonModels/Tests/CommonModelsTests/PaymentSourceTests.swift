//
//  PaymentSourceTests.swift
//  CommonModelsTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import CommonModels

final class PaymentSourceTests: XCTestCase {

    func testPaymentSourceInitialization() {
        let paymentSource = PaymentSource(
            type: "card",
            gatewayId: "gateway-123",
            cardNumberLast4: "1234"
        )

        XCTAssertEqual(paymentSource.type, "card")
        XCTAssertEqual(paymentSource.gatewayId, "gateway-123")
        XCTAssertEqual(paymentSource.cardNumberLast4, "1234")
    }

    func testPaymentSourceWithAllFields() {
        let paymentSource = PaymentSource(
            type: "card",
            walletType: "apple",
            checkoutHolder: "John Doe",
            checkoutEmail: "john@example.com",
            vaultToken: "vault-token-123",
            vaultType: "permanent",
            paymentMethodId: "pm-123",
            externalPayerId: "ext-payer-123",
            status: "active",
            gatewayId: "gateway-123",
            gatewayName: "Test Gateway",
            gatewayType: "GPayments",
            gatewayMode: "test",
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-02T00:00:00Z",
            refToken: "ref-token-123",
            addressLine1: "123 Main St",
            addressLine2: "Apt 4",
            addressLine3: "Building 5",
            addressCity: "Sydney",
            addressState: "NSW",
            addressPostcode: "2000",
            addressCountry: "AU",
            cardNumberLast4: "1234",
            cardNumberBin: "411111",
            cardName: "John Doe",
            cardFundingMethod: "credit",
            cardScheme: "visa",
            expireMonth: 12,
            expireYear: 2025,
            id: "payment-source-123"
        )

        XCTAssertEqual(paymentSource.type, "card")
        XCTAssertEqual(paymentSource.walletType, "apple")
        XCTAssertEqual(paymentSource.vaultToken, "vault-token-123")
        XCTAssertEqual(paymentSource.cardScheme, "visa")
        XCTAssertEqual(paymentSource.expireMonth, 12)
        XCTAssertEqual(paymentSource.expireYear, 2025)
        XCTAssertEqual(paymentSource.id, "payment-source-123")
    }

    func testPaymentSourceCodableEncoding() throws {
        let paymentSource = PaymentSource(
            type: "card",
            gatewayId: "gateway-456",
            cardNumberLast4: "5678",
            cardScheme: "mastercard"
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(paymentSource)

        XCTAssertNotNil(data)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["type"] as? String, "card")
        XCTAssertEqual(json?["gateway_id"] as? String, "gateway-456")
        XCTAssertEqual(json?["card_number_last4"] as? String, "5678")
        XCTAssertEqual(json?["card_scheme"] as? String, "mastercard")
    }

    func testPaymentSourceCodableDecoding() throws {
        let json = Data("""
        {
            "_id": "payment-source-789",
            "type": "card",
            "gateway_id": "gateway-789",
            "gateway_name": "Test Gateway",
            "gateway_type": "GPayments",
            "card_number_last4": "7890",
            "card_scheme": "visa",
            "expire_month": 6,
            "expire_year": 2026,
            "status": "active",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-02T00:00:00Z"
        }
        """.utf8)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let paymentSource = try decoder.decode(PaymentSource.self, from: json)

        XCTAssertEqual(paymentSource.id, "payment-source-789")
        XCTAssertEqual(paymentSource.type, "card")
        XCTAssertEqual(paymentSource.gatewayId, "gateway-789")
        XCTAssertEqual(paymentSource.gatewayName, "Test Gateway")
        XCTAssertEqual(paymentSource.cardNumberLast4, "7890")
        XCTAssertEqual(paymentSource.cardScheme, "visa")
        XCTAssertEqual(paymentSource.expireMonth, 6)
        XCTAssertEqual(paymentSource.expireYear, 2026)
    }

    func testPaymentSourceWithWalletType() {
        let paymentSource = PaymentSource(
            type: "wallet",
            walletType: "apple",
            refToken: "apple-ref-token-123"
        )

        XCTAssertEqual(paymentSource.type, "wallet")
        XCTAssertEqual(paymentSource.walletType, "apple")
        XCTAssertEqual(paymentSource.refToken, "apple-ref-token-123")
    }

    func testPaymentSourceWithVaultToken() {
        let paymentSource = PaymentSource(
            type: "card",
            vaultToken: "vault-token-456",
            vaultType: "session"
        )

        XCTAssertEqual(paymentSource.vaultToken, "vault-token-456")
        XCTAssertEqual(paymentSource.vaultType, "session")
    }

    func testPaymentSourceWithAddress() {
        let paymentSource = PaymentSource(
            type: "card",
            addressLine1: "456 Oak Ave",
            addressCity: "Melbourne",
            addressState: "VIC",
            addressPostcode: "3000",
            addressCountry: "AU"
        )

        XCTAssertEqual(paymentSource.addressLine1, "456 Oak Ave")
        XCTAssertEqual(paymentSource.addressCity, "Melbourne")
        XCTAssertEqual(paymentSource.addressState, "VIC")
        XCTAssertEqual(paymentSource.addressPostcode, "3000")
        XCTAssertEqual(paymentSource.addressCountry, "AU")
    }

    func testPaymentSourceWithNilFields() {
        let paymentSource = PaymentSource()

        XCTAssertNil(paymentSource.type)
        XCTAssertNil(paymentSource.gatewayId)
        XCTAssertNil(paymentSource.id)
    }
}
