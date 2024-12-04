//
//  PayPalVaultServiceNegativeTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 08.10.2024..
//

import XCTest
@testable import MobileSDK
@testable import NetworkingLib

final class PayPalVaultServiceNegativeTests: XCTestCase {

    private var sut: PayPalVaultServiceMock!

    override func setUp() {
        super.setUp()

        self.sut = PayPalVaultServiceMock()
        sut.sendError = true
    }
    
    func testCreateTokenFailure() async {
        sut.responseFilename = .authFail
        do {
            let request = PayPalVaultAuthReq(gatewayId: "some_gateway_id")
            _ = try await sut.createToken(request: request, accessToken: "some_access_token")
            XCTFail("Expected to throw an error, but no error was thrown.")
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            XCTAssertEqual(errorResponse.error?.code, "ValidationError")
        } catch {
            XCTFail("Should always fail with known error response!")
        }
    }
    
    func testCreateSetupTokenFailure() async {
        // TODO: - Update error responses once we know how they will look
        sut.responseFilename = .authFail
        do {
            let req = PayPalVaultSetupTokenReq(gatewayId: "some_gateway_id", token: "received_oauth_token")
            _ = try await sut.createSetupTokenData(req: req, accessToken: "some_access_token")
            XCTFail("Expected to throw an error, but no error was thrown.")
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            XCTAssertEqual(errorResponse.error?.code, "ValidationError")
        } catch {
            XCTFail("Should always fail with known error response!")
        }
    }
    
    func testGetClientIdFailure() async {
        // TODO: - Update error responses once we know how they will look
        sut.responseFilename = .authFail
        do {
            _ = try await sut.getClientId(gatewayId: "some_gateway_id", accessToken: "some_access_token")
            XCTFail("Expected to throw an error, but no error was thrown.")
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            XCTAssertEqual(errorResponse.error?.code, "ValidationError")
        } catch {
            XCTFail("Should always fail with known error response!")
        }
    }
    
    func testCreatePaymentTokenFailure() async {
        // TODO: - Update error responses once we know how they will look
        sut.responseFilename = .authFail
        do {
            let request = PayPalVaultPaymentTokenReq(gatewayId: "some_gateway_id")
            _ = try await sut.createPaymentToken(request: request, setupToken: "some_token", accessToken: "some_access_token")
            XCTFail("Expected to throw an error, but no error was thrown.")
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            XCTAssertEqual(errorResponse.error?.code, "ValidationError")
        } catch {
            XCTFail("Should always fail with known error response!")
        }
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}
