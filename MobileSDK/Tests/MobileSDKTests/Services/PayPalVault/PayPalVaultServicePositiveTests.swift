//
//  PayPalVaultServicePositiveTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 07.10.2024..
//

import XCTest
@testable import MobileSDK

final class PayPalVaultServicePositiveTests: XCTestCase {

    private var sut: PayPalVaultServiceMock!

    override func setUp() {
        super.setUp()

        self.sut = PayPalVaultServiceMock()
    }
    
    func testCreateTokenSuccess() async {
        sut.responseFilename = .authSuccess
        do {
            let request = PayPalVaultAuthReq(gatewayId: "some_gateway_id")
            let token = try await sut.createToken(request: request, accessToken: "some_access_token")
            XCTAssertEqual(token, "some_access_token")
        } catch {
            XCTFail("Getting PayPal auth token FAILED!")
        }
    }
    
    func testCreateSetupTokenSuccess() async {
        sut.responseFilename = .setupTokenSuccess
        do {
            let req = PayPalVaultSetupTokenReq(gatewayId: "some_gateway_id", oauthToken: "some_oauth_token")
            let token = try await sut.createSetupToken(req: req, accessToken: "some_access_token")
            XCTAssertEqual(token, "XObCsxdHXe")
        } catch {
            XCTFail("Getting PayPal setup token FAILED!")
        }
    }
    
    func testGetClientIdSuccess() async {
        sut.responseFilename = .getClientId
        do {
            let clientId = try await sut.getClientId(gatewayId: "some_gateway_id", accessToken: "some_access_token")
            XCTAssertEqual(clientId, "AY-iOYV1QKAX6ZRomt-gXigd0-pToRMwdoLW4UxFSITOApI2jUa5UgM39MKC0qeip3SCbPozbAusuGO0")
        } catch {
            XCTFail("Getting PayPal client ID FAILED!")
        }
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}
