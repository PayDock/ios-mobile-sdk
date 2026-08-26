//
//  ApplePayWidgetUITests.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import XCTest

/// UI coverage for the Apple Pay widget. The button is Apple's native `PKPaymentButton`, so we
/// locate it by the `applePayButton` accessibility identifier set in `ApplePayExampleView`, and
/// verify its VoiceOver label/trait (Apple provides a localised "… with Apple Pay" label). The
/// payment sheet itself is a system surface and is not automatable — we only assert presentation.
final class ApplePayWidgetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = .portrait
        app = nil
        super.tearDown()
    }

    private func navigateToApplePay(_ rowTitle: String = "Apple Pay") {
        app.launch()
        let widgetsTab = app.tabBars.buttons["Widgets"]
        XCTAssertTrue(widgetsTab.waitForExistence(timeout: 10), "Widgets tab not found")
        widgetsTab.tap()

        let cell = app.staticTexts[rowTitle]
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "\(rowTitle) row not found")
        cell.tap()
    }

    private func applePayButton() -> XCUIElement {
        // Prefer the identifier; fall back to any button whose label mentions Apple Pay.
        let byId = app.buttons["applePayButton"]
        if byId.waitForExistence(timeout: 10) { return byId }
        return app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Apple Pay'")).firstMatch
    }

    func testApplePayButton_ExistsAndEnabled() throws {
        navigateToApplePay()
        let button = applePayButton()
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Apple Pay button not found")
        XCTAssertTrue(button.isEnabled, "Apple Pay button should be enabled")
    }

    func testApplePayButton_VoiceOverLabelAndTrait() throws {
        navigateToApplePay()
        let button = applePayButton()
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        // Apple supplies a localised label containing "Apple Pay"; element is a button (activatable).
        XCTAssertTrue(button.label.localizedCaseInsensitiveContains("Apple Pay"),
                      "Expected an Apple Pay VoiceOver label, got: \(button.label)")
        XCTAssertEqual(button.elementType, .button)
        XCTAssertTrue(button.isHittable, "Button should be reachable/activatable")
    }

    func testApplePayButton_SurvivesRotation() throws {
        navigateToApplePay()
        let button = applePayButton()
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Apple Pay button not found in portrait")

        // Rotate to landscape — the native button must survive the layout change and stay reachable.
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(applePayButton().waitForExistence(timeout: 10), "Apple Pay button should survive rotation")
        XCTAssertTrue(applePayButton().isHittable, "Apple Pay button should remain reachable in landscape")

        // Rotate back to portrait.
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(applePayButton().waitForExistence(timeout: 10), "Apple Pay button should exist after rotating back")
    }

    func testApplePayButton_TapPresentsSheetOrStaysStable() throws {
        navigateToApplePay()
        let button = applePayButton()
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        button.tap()
        // The system Apple Pay sheet (or an availability alert) is a separate surface we can't
        // drive; assert the app did not crash and the button is still present afterwards.
        XCTAssertTrue(button.waitForExistence(timeout: 5))
    }
}
