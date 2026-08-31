//
//  ApplePaySetupWidgetUITests.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import XCTest

/// UI coverage for the Apple Pay Setup widget. The button is Apple's native `PKPaymentButton`
/// forced to the `.setUp` type; tapping it opens the system Wallet (not automatable), so we only
/// assert existence, VoiceOver label/trait, and that a tap doesn't crash the app.
final class ApplePaySetupWidgetUITests: XCTestCase {

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

    private func navigateToSetup() {
        app.launch()
        let widgetsTab = app.tabBars.buttons["Widgets"]
        XCTAssertTrue(widgetsTab.waitForExistence(timeout: 10), "Widgets tab not found")
        widgetsTab.tap()

        let cell = app.staticTexts["Apple Pay Setup"]
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Apple Pay Setup row not found")
        cell.tap()
    }

    private func setupButton() -> XCUIElement {
        let byId = app.buttons["applePaySetupButton"]
        if byId.waitForExistence(timeout: 10) { return byId }
        return app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Apple Pay'")).firstMatch
    }

    func testSetupButton_ExistsEnabledAndLabelled() throws {
        navigateToSetup()
        let button = setupButton()
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Setup button not found")
        XCTAssertTrue(button.isEnabled)
        XCTAssertTrue(button.label.localizedCaseInsensitiveContains("Apple Pay"),
                      "Expected an Apple Pay VoiceOver label, got: \(button.label)")
        XCTAssertEqual(button.elementType, .button)
    }

    func testSetupButton_TapDoesNotCrash() throws {
        navigateToSetup()
        let button = setupButton()
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        button.tap()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
}
