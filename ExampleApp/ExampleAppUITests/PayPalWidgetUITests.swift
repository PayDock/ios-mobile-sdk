//
//  PayPalWidgetUITests.swift
//  ExampleApp
//
//  Created by M2M3V72L25 on 18/08/2025.
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import XCTest

final class PayPalWidgetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        continueAfterFailure = false
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

//    func testPayPalWebViewIsPresented() throws {
//        // Launch app
//        app.launch()
//
//        // Navigate to Widgets tab
//        let widgetsTab = app.tabBars.firstMatch.buttons.element(boundBy: 1)  // Widgets is the second tab
//        XCTAssertTrue(widgetsTab.waitForExistence(timeout: 5), "Widgets tab not found")
//        widgetsTab.tap()
//
//        let paypalCell = app.scrollViews.firstMatch.staticTexts["PayPal"]
//        paypalCell.scrollToElement()
//        XCTAssertTrue(paypalCell.waitForExistence(timeout: 5))
//        paypalCell.tap()
//
//        // Wait for PayPal widget to be visible and tap it
//        let paypalCell = app.scrollViews.firstMatch.otherElements.containing(.staticText, identifier: "PayPal").firstMatch
//        XCTAssertTrue(paypalCell.waitForExistence(timeout: 5), "PayPal widget cell not found")
//        paypalCell.tap()
//
//        // Wait for PayPal button to be visible and tap it
//        let paypalButton = app.scrollViews.firstMatch.buttons.firstMatch
//        XCTAssertTrue(paypalButton.waitForExistence(timeout: 5), "PayPal button not found")
//        paypalButton.tap()
//
//        // Wait for PayPal webview
//        let webView = app.webViews.firstMatch
//        XCTAssertTrue(webView.waitForExistence(timeout: 10), "PayPal webview did not appear")
//    }
}
