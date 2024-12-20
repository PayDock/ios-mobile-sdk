//
//  CardServiceTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 31.07.2023..
//

import XCTest
@testable import MobileSDK

final class CardServiceTests: XCTestCase {

    private var sut: CardServiceMock!

    override func setUp() {
        super.setUp()

        self.sut = CardServiceMock()
    }

    func testCardServiceMock() async {

        do {
            let req = TokeniseCardDetailsReq(
                gatewayId: "SomeID",
                cardName: "Wanda Mertz",
                cardNumber: "4242424242424242",
                expireMonth: "09",
                expireYear: "21",
                cardCcv: "123")
            let cardToken = try await sut.createToken(tokeniseCardDetailsReq: req, accessToken: "access-token")

            XCTAssertEqual(cardToken, "bc8cb1a5-0c7b-454a-ab33-62a6d874ce3e")
        } catch {
            XCTFail("Card tokenisation FAILED!")
        }
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}
