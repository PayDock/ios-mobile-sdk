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
            _ = try await sut.createToken(gatewayId: "some_gateway_id", accessToken: "some_access_token")
            XCTFail("Expected to throw an error, but no error was thrown.")
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            XCTAssertEqual(errorResponse.error?.code, "ValidationError")
        } catch {
            XCTFail("Should always fail with known error response!")
        }
    }
    
    func testCreateSetupTokenFailure() async {
        sut.responseFilename = .authFail // same response as before
        do {
            let req = PayPalVaultSetupTokenReq(gatewayId: "some_gateway_id", oauthToken: "received_oauth_token")
            _ = try await sut.createSetupToken(req: req, accessToken: "some_access_token")
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
