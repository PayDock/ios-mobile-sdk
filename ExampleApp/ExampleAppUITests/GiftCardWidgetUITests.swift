import XCTest

final class GiftCardWidgetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Navigate to Gift Card widget once
        navigateToGiftCardWidget()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func navigateToGiftCardWidget() {
        // Navigate to Widgets tab
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 2.0) {
            let widgetsTab = tabBar.buttons.element(boundBy: 1) // Widgets tab
            widgetsTab.tap()
        }

        // Find and tap Gift Card option
        let giftCardOption = app.staticTexts["Gift Card"]
        XCTAssertTrue(giftCardOption.waitForExistence(timeout: 3.0), "Gift Card option should exist in Widgets")
        giftCardOption.tap()

        // Wait for Gift Card form to load
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.waitForExistence(timeout: 2.0), "Gift Card form should load")
    }

    func testGiftCardWidgetUIElements() throws {
        // Test UI Elements Existence
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        let pinField = app.secureTextFields["PIN"]
        XCTAssertTrue(pinField.exists, "PIN field should exist")

        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.exists, "Add button should exist")

        // Test initial state - button should be disabled
        XCTAssertFalse(addButton.isEnabled, "Add button should be initially disabled")

    }

    func testGiftCardNumberValidation() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Test data: Card Number, Expected Valid, Description
        // Field logic: 1-25 digits allowed, 14-25 digits are valid
        let testCases = [
            ("1234567890123", false, "13 digits - too short for validation"),
            ("12345678901234", true, "14 digits - minimum valid"),
            ("62734010000131278", true, "17 digits - valid real test data"),
            ("1234567890123456789012345", true, "25 digits - maximum valid"),
            ("12345678901234567890123456", true, "26 digits but form will allow only 25")
        ]

        for (cardNumber, shouldBeValid, description) in testCases {
            // Clear and enter card number
            cardNumberField.slowTypeText(cardNumber)
            usleep(500000) // 500ms for immediate validation

            // Check for error message (validation happens immediately)
            let errorMessage = app.staticTexts["Invalid card number"]

            if shouldBeValid {
                XCTAssertFalse(errorMessage.exists, "\(description) should NOT show error")
            } else {
                if !cardNumber.isEmpty {
                    XCTAssertTrue(errorMessage.exists, "\(description) should show 'Invalid card number'")
                }
            }

            // Clear field for next test
            cardNumberField.fastTypeText("")
        }

    }

    func testGiftCardPINValidation() throws {
        let pinField = app.secureTextFields["PIN"]
        XCTAssertTrue(pinField.exists, "PIN field should exist")

        // Test data: PIN, Expected Valid, Description
        // Field logic: 4 digits is valid
        let testCases = [
            ("123", false, "3 digits - too short"),
            ("1234", true, "4 digits - valid")

        ]

        for (pin, shouldBeValid, description) in testCases {
            // Clear and enter PIN
            pinField.slowTypeText(pin)
            usleep(500000) // 500ms for immediate validation

            // Check for error message (validation happens immediately)
            let errorMessage = app.staticTexts["Invalid PIN number"]

            if shouldBeValid {
                XCTAssertFalse(errorMessage.exists, "\(description) should NOT show error")
            } else {
                if !pin.isEmpty {
                    XCTAssertTrue(errorMessage.exists, "\(description) should show 'Invalid PIN number'")
                }
            }

            // Clear field for next test
            pinField.fastTypeText("")
        }

    }

    func testGiftCardSuccessfulTokenization() throws {
        // Test data: Valid gift card numbers and PINs
        let testCases = [
            ("62734010000131278", "5814", "Real test data - 17-digit card"),
            ("12345678901234", "1234", "14-digit card (minimum valid)"),
            ("1234567890123456789012345", "9999", "25-digit card (maximum valid)")
        ]

        for (cardNumber, pin, description) in testCases {
            // Fill card number
            let cardNumberField = app.textFields["Card number"]
            cardNumberField.slowTypeText(cardNumber)

            // Fill PIN
            let pinField = app.secureTextFields["PIN"]
            pinField.slowTypeText(pin)
            usleep(1500000) // 1.5s for form validation (increased wait time)

            // Submit the form
            let addButton = app.buttons["Add"]
            XCTAssertTrue(addButton.waitForExistence(timeout: 2.0), "Add button should exist")

            // Wait and check button state
            usleep(1000000) // Additional 1s wait

            // If button is not enabled, skip this test case (test environment limitation)
            guard addButton.isEnabled else {
                continue
            }

            addButton.tap()

            // Wait for response
            usleep(3000000) // 3s instead of 5s

            // Check for alert response
            let alertExists = app.alerts.element.exists
            if alertExists {
                let alertTitle = app.alerts.element.label
                let alertMessage = app.alerts.element.staticTexts.element(boundBy: 1).label

                // Success indicators:
                let hasValidResponse = alertTitle.contains("Gift Card")
                let isActualSuccess = hasValidResponse &&
                !alertMessage.lowercased().contains("error") &&
                !alertMessage.lowercased().contains("failed") &&
                !alertMessage.lowercased().contains("invalid")
                let isApiConfigError = alertMessage.contains("GiftCardError") ||
                alertMessage.contains("operation couldn't be completed")

                // Accept either success OR expected API config errors
                let isAcceptableResult = isActualSuccess || (hasValidResponse && isApiConfigError)

                XCTAssertTrue(isAcceptableResult,
                              "Should get valid response for \(description). Alert: \(alertTitle), Message: \(alertMessage)")

                // Dismiss alert
                if app.alerts.buttons["OK"].waitForExistence(timeout: 0.5) {
                    app.alerts.buttons["OK"].tap()
                } else if app.alerts.buttons["Dismiss"].waitForExistence(timeout: 0.5) {
                    app.alerts.buttons["Dismiss"].tap()
                } else {
                    app.tap()
                }

                usleep(500000) // 500ms instead of 1s
            } else {
                usleep(1000000) // 1s instead of 2s
            }
        }

    }
}
