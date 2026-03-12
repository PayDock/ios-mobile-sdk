//
//  CustomerTests.swift
//  CommonModelsTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import CommonModels

final class CustomerTests: XCTestCase {

    func testCustomerInitialization() {
        let customer = Customer(
            companyId: "company-123",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+1234567890"
        )

        XCTAssertEqual(customer.companyId, "company-123")
        XCTAssertEqual(customer.firstName, "John")
        XCTAssertEqual(customer.lastName, "Doe")
        XCTAssertEqual(customer.email, "john.doe@example.com")
        XCTAssertEqual(customer.phone, "+1234567890")
    }

    func testCustomerWithAllFields() {
        let service = CustomerService(defaultGatewayId: "gateway-123")
        let statistics = CustomerStatistics(
            successfulTransactions: 10,
            totalCollectedAmount: 1000
        )
        let paymentSource = PaymentSource(
            type: "card",
            gatewayId: "gateway-123",
            cardNumberLast4: "1234"
        )

        let customer = Customer(
            companyId: "company-123",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+1234567890",
            checkExpireDate: true,
            service: service,
            statistics: statistics,
            archived: false,
            status: "active",
            paymentSource: paymentSource,
            paymentSources: [paymentSource],
            defaultSource: "source-123",
            id: "customer-123",
            externalId: "ext-123",
            paymentDestinations: ["dest-1", "dest-2"],
            suspicious: false,
            updatedAt: "2024-01-01T00:00:00Z",
            createdAt: "2024-01-01T00:00:00Z",
            value: 1
        )

        XCTAssertEqual(customer.id, "customer-123")
        XCTAssertEqual(customer.service?.defaultGatewayId, "gateway-123")
        XCTAssertEqual(customer.statistics?.successfulTransactions, 10)
        XCTAssertEqual(customer.paymentSource?.type, "card")
    }

    func testCustomerCodableEncoding() throws {
        let customer = Customer(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane.smith@example.com",
            id: "customer-456"
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(customer)

        XCTAssertNotNil(data)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["first_name"] as? String, "Jane")
        XCTAssertEqual(json?["last_name"] as? String, "Smith")
    }

    func testCustomerCodableDecoding() throws {
        let json = Data("""
        {
            "_id": "customer-789",
            "first_name": "Bob",
            "last_name": "Johnson",
            "email": "bob.johnson@example.com",
            "phone": "+9876543210",
            "company_id": "company-456",
            "status": "active",
            "archived": false,
            "__v": 2
        }
        """.utf8)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let customer = try decoder.decode(Customer.self, from: json)

        XCTAssertEqual(customer.id, "customer-789")
        XCTAssertEqual(customer.firstName, "Bob")
        XCTAssertEqual(customer.lastName, "Johnson")
        XCTAssertEqual(customer.email, "bob.johnson@example.com")
        XCTAssertEqual(customer.phone, "+9876543210")
        XCTAssertEqual(customer.companyId, "company-456")
        XCTAssertEqual(customer.status, "active")
        XCTAssertEqual(customer.archived, false)
        XCTAssertEqual(customer.value, 2)
    }

    func testCustomerWithUnderscorePrefixFields() throws {
        let json = Data("""
        {
            "_id": "customer-999",
            "_checkExpireDate": true,
            "_service": {
                "default_gateway_id": "gateway-999"
            },
            "first_name": "Test",
            "last_name": "User",
            "__v": 1
        }
        """.utf8)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let customer = try decoder.decode(Customer.self, from: json)

        XCTAssertEqual(customer.id, "customer-999")
        XCTAssertEqual(customer.checkExpireDate, true)
        XCTAssertEqual(customer.service?.defaultGatewayId, "gateway-999")
        XCTAssertEqual(customer.value, 1)
    }

    func testCustomerServiceInitialization() {
        let service = CustomerService(defaultGatewayId: "gateway-123")
        XCTAssertEqual(service.defaultGatewayId, "gateway-123")
    }

    func testCustomerServiceCodable() throws {
        let service = CustomerService(defaultGatewayId: "gateway-456")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(service)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(CustomerService.self, from: data)

        XCTAssertEqual(decoded.defaultGatewayId, "gateway-456")
    }

    func testCustomerStatisticsInitialization() {
        let statistics = CustomerStatistics(
            successfulTransactions: 5,
            totalCollectedAmount: 500
        )

        XCTAssertEqual(statistics.successfulTransactions, 5)
        XCTAssertEqual(statistics.totalCollectedAmount, 500)
    }

    func testCustomerStatisticsCodable() throws {
        let statistics = CustomerStatistics(
            successfulTransactions: 20,
            totalCollectedAmount: 2000
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(statistics)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(CustomerStatistics.self, from: data)

        XCTAssertEqual(decoded.successfulTransactions, 20)
        XCTAssertEqual(decoded.totalCollectedAmount, 2000)
    }

    func testCustomerWithNilFields() {
        let customer = Customer()

        XCTAssertNil(customer.companyId)
        XCTAssertNil(customer.firstName)
        XCTAssertNil(customer.lastName)
        XCTAssertNil(customer.email)
        XCTAssertNil(customer.id)
    }
}
