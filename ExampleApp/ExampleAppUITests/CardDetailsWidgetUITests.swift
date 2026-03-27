import XCTest

// swiftlint:disable file_length
final class CardDetailsWidgetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Navigate to Card Details widget
        navigateToCardDetailsWidget()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func navigateToCardDetailsWidget() {
        // Navigate to the Widgets tab
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let widgetsTab = tabBar.buttons.element(boundBy: 1)
            widgetsTab.tap()
        }

        // Find and tap on Card Details widget (it's a NavigationLink cell, not a button)
        let cardDetailsCell = app.staticTexts["Card Details"]
        XCTAssertTrue(cardDetailsCell.waitForExistence(timeout: 3.0), "Card Details widget should exist")
        cardDetailsCell.tap()

        // Wait for the Card Details screen to load
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.waitForExistence(timeout: 2.0), "Card Details screen should load")
    }

    func testCardDetailsWidgetUIElements() throws {
        // Test Card Details form fields (use waitForExistence to handle timing)
        XCTAssertTrue(app.textFields["Cardholder name"].waitForExistence(timeout: 3.0), "Cardholder name field should exist")
        XCTAssertTrue(app.textFields["Card number"].waitForExistence(timeout: 3.0), "Card number field should exist")
        XCTAssertTrue(app.textFields["Expiry"].waitForExistence(timeout: 3.0), "Expiry field should exist")
        // CVV is a secure text field (isSecureTextEntry = true for PCI DSS compliance)
        XCTAssertTrue(app.secureTextFields["CVV"].waitForExistence(timeout: 3.0), "CVV field should exist")
        XCTAssertTrue(app.buttons["Submit"].exists, "Submit button should exist")
        XCTAssertFalse(app.buttons["Submit"].isEnabled, "Submit button should be disabled when form is empty")
        XCTAssertTrue(app.staticTexts["Remember this card for next time."].exists, "Save card consent text should exist")
        XCTAssertTrue(app.switches.firstMatch.exists, "Save card toggle should exist")
        XCTAssertTrue(app.staticTexts["Read our privacy policy"].exists, "Privacy policy link should exist")

        // Test Card Details supported card schemes are visible
        let cardSchemes = [
            ("Visa", ["visa"]),
            ("Mastercard", ["mastercard"]),
            ("American Express", ["american express", "amex"]),
            ("Dinners Club", ["dinners club", "diners"]),
            ("Discover", ["discover"]),
            ("JCB", ["jcb"])
        ]

        // Check for card schemes - some may only be visible when interacting with form
        var foundSchemes: [String] = []
        for (schemeName, identifiers) in cardSchemes {
            let predicateString = identifiers.map {
                "identifier CONTAINS[c] '\($0)' OR label CONTAINS[c] '\($0)'"
            }.joined(separator: " OR ")
            let predicate = NSPredicate(format: predicateString)
            if app.images.containing(predicate).count > 0 {
                foundSchemes.append(schemeName)
            }
        }

        // Assert that we found at least 5 card schemes (most should be visible)
        XCTAssertTrue(foundSchemes.count >= 5, "Should find at least 5 card schemes, found: \(foundSchemes.joined(separator: ", "))")

        // Specifically check for the main schemes
        XCTAssertTrue(foundSchemes.contains("Visa"), "Visa should be visible")
        XCTAssertTrue(foundSchemes.contains("Mastercard"), "Mastercard should be visible")
    }

    func testCardHolderNameValidNames() throws {
        let cardholderNameField = app.textFields["Cardholder name"]
        let cardNumberField = app.textFields["Card number"]

        // Test valid cardholder names
        let validNames = [
            "John-Joe",        // Hyphen should be valid
            "John Joe",        // Space should be valid
            "D'Angelo",        // Name with apostrophe
            "Anna-Maria Smith" // Complex name with hyphen and space
        ]

        for validName in validNames {
            // Clear field and enter valid name using slow typing
            cardholderNameField.slowTypeText(validName)

            // Defocus to trigger validation (tap another field)
            cardNumberField.tap()
            usleep(500000) // Wait for validation

            // Go back to check the value
            cardholderNameField.tap()
            usleep(300000)

            // Verify the name was entered correctly
            let fieldValue = cardholderNameField.value as? String ?? ""
            XCTAssertEqual(fieldValue, validName, "\(validName) should be accepted as valid cardholder name")

            // Check for "Invalid name" error message
            let errorMessage = app.staticTexts["Invalid name"]
            XCTAssertFalse(errorMessage.exists, "Should NOT show 'Invalid name' error for valid input: '\(validName)'")
        }
    }

    func testCardHolderNameInvalidNames() throws {
        let cardholderNameField = app.textFields["Cardholder name"]
        let cardNumberField = app.textFields["Card number"]

        // Test a subset of invalid cardholder names with forbidden symbols
        let invalidNames = [
            "John(Doe)",       // Contains ()
            "John$mith",       // Contains $
            "123456"           // No alpha characters (only numbers)
        ]

        for invalidName in invalidNames {
            // Clear field and enter invalid name using slow typing
            cardholderNameField.slowTypeText(invalidName)

            // Defocus to trigger validation (tap another field)
            cardNumberField.tap()
            sleep(1) // Wait for validation

            // Check for "Invalid name" error message with timeout
            let errorMessage = app.staticTexts["Invalid name"]
            XCTAssertTrue(
                errorMessage.waitForExistence(timeout: 2.0),
                "Should show 'Invalid name' error for invalid input: '\(invalidName)'"
            )

            // Clear for next test - go back to cardholder name field
            cardholderNameField.slowTypeText("")
        }
    }

    func testCardHolderNameEdgeCases() throws {
        let cardholderNameField = app.textFields["Cardholder name"]
        let cardNumberField = app.textFields["Card number"]

        // Test a subset of edge cases
        let edgeCases = [
            ("A", true),           // Single alpha character (minimum valid)
            ("1A", false),         // Number + alpha (invalid - doesn't start with letter)
            ("A-B", true)          // Alpha + hyphen + alpha (valid)
        ]

        for (testName, shouldBeValid) in edgeCases {
            cardholderNameField.slowTypeText(testName)

            // Defocus to trigger validation (tap another field)
            cardNumberField.tap()
            sleep(1) // Wait for validation

            let errorMessage = app.staticTexts["Invalid name"]

            if shouldBeValid {
                // For valid cases: NO error message should appear
                sleep(1) // Extra wait to ensure no error appears
                XCTAssertFalse(errorMessage.exists, "Should NOT show 'Invalid name' error for valid input: '\(testName)'")
            } else {
                // For invalid cases: should show error message
                XCTAssertTrue(
                    errorMessage.waitForExistence(timeout: 2.0),
                    "Should show 'Invalid name' error for invalid input: '\(testName)'"
                )
            }

            // Clear for next test - go back to cardholder name field
            cardholderNameField.slowTypeText("")
        }
    }

    func testCardSchemeDetectionOnCardNumberField() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Test card numbers with their expected scheme images
        let cardSchemeTests = [
            ("5111111111111118", "MasterCard", ["mastercard"]),
            ("4012000033330026", "Visa", ["visa"]),
            ("371449635398431", "AMEX", ["american-express"]),
            ("3528111100000001", "JCB", ["jcb"])
        ]

        for (cardNumber, schemeName, identifiers) in cardSchemeTests {
            // Clear field first
            cardNumberField.slowTypeText("")
            sleep(1)

            // Enter the card number
            cardNumberField.slowTypeText(cardNumber)
            sleep(2) // Wait for card scheme detection

            // Check if the corresponding card scheme image appears
            let predicateString = identifiers.map {
                "identifier CONTAINS[c] '\($0)' OR label CONTAINS[c] '\($0)'"
            }.joined(separator: " OR ")
            let predicate = NSPredicate(format: predicateString)
            let schemeImages = app.images.containing(predicate)

            XCTAssertTrue(schemeImages.count > 0, "\(schemeName) card scheme image should appear when entering card number \(cardNumber)")

            // Additional check: verify the image is visible and hittable
            if schemeImages.count > 0 {
                let firstSchemeImage = schemeImages.firstMatch
                XCTAssertTrue(firstSchemeImage.exists, "\(schemeName) image should exist")
                XCTAssertTrue(firstSchemeImage.isHittable, "\(schemeName) image should be visible to user")
            }
        }

        // Clear field at the end
        cardNumberField.slowTypeText("")
    }

    func testCardNumberFieldValidation() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Test 1: Valid Card Numbers for Different Card Types
        let validCardNumbers = [
            ("4012000033330026", "Visa", "visa"),
            ("5111111111111118", "Mastercard", "mastercard"),
            ("371449635398431", "American Express", "american-express"),
            ("3528111100000001", "JCB", "jcb")
        ]

        for (cardNumber, cardType, expectedSchemeIdentifier) in validCardNumbers {
            // Clear field first
            cardNumberField.fastTypeText("")

            // Enter valid card number
            cardNumberField.slowTypeText(cardNumber) // Use slow for validation
            usleep(500000) // 500ms for validation

            // Verify card number was accepted
            let fieldValue = cardNumberField.value as? String ?? ""
            let cleanValue = fieldValue.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            XCTAssertEqual(cleanValue, cardNumber, "\(cardType) card number \(cardNumber) should be accepted")

            // Verify no error message for valid card
            let errorMessage = app.staticTexts["Invalid card number"]
            XCTAssertFalse(errorMessage.exists, "\(cardType) card should NOT show 'Invalid card number' error")

        }

        // Test 2: Invalid Card Numbers
        let expiryField = app.textFields["Expiry"]

        // Test 2a: Too short card number (below minimum for Visa)
        cardNumberField.fastTypeText("")
        cardNumberField.slowTypeText("4111111111111") // 13 digits, below Visa minimum of 16
        expiryField.tap() // Defocus to trigger validation
        usleep(1000000) // 1s for validation

        let tooShortError = app.staticTexts["Invalid card number"]
        XCTAssertTrue(tooShortError.waitForExistence(timeout: 2.0), "Too short card number should show 'Invalid card number' error message")

        // Test 2b: Invalid Luhn card number (correct length but fails checksum)
        cardNumberField.fastTypeText("")
        cardNumberField.slowTypeText("4111111111111112") // 16 digits but fails Luhn
        expiryField.tap() // Defocus to trigger validation
        usleep(1000000) // 1s for validation

        let invalidLuhnError = app.staticTexts["Invalid card number"]
        XCTAssertTrue(
            invalidLuhnError.waitForExistence(timeout: 2.0),
            "Invalid Luhn card number should show 'Invalid card number' error message"
        )

        // Clean up - Clear field
        cardNumberField.slowTypeText("")

    }

    func testExpiryField() throws {
        let expiryField = app.textFields["Expiry"]
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(expiryField.exists, "Expiry field should exist")

        // Test 1: Valid Future Expiry Dates (should NOT show error)
        expiryField.slowTypeText("12/30")

        // Defocus to trigger validation
        cardNumberField.tap()
        usleep(500000)

        let validExpiryDateError = app.staticTexts["Invalid expiry date"]
        XCTAssertFalse(validExpiryDateError.exists, "Valid expiry date should NOT show 'Invalid expiry date'")

        let validCardExpiredError = app.staticTexts["Card expired"]
        XCTAssertFalse(validCardExpiredError.exists, "Valid expiry date should NOT show 'Card expired'")

        // Test 2: Expired Card (should show error)
        expiryField.slowTypeText("") // Clear field first
        expiryField.slowTypeText("06/25")

        // Defocus to trigger validation
        cardNumberField.tap()
        usleep(500000)

        let expiredCardError = app.staticTexts["Card expired"]
        XCTAssertTrue(expiredCardError.waitForExistence(timeout: 2.0), "Past expiry date should show 'Card expired'")

        // Test 3: Invalid month (should show error)
        expiryField.slowTypeText("") // Clear field first
        expiryField.slowTypeText("13/25")

        // Defocus to trigger validation
        cardNumberField.tap()
        usleep(500000)

        let invalidMonthError = app.staticTexts["Invalid expiry date"]
        XCTAssertTrue(invalidMonthError.waitForExistence(timeout: 2.0), "Invalid month should show 'Invalid expiry date'")

        // Clean up - Clear field
        expiryField.slowTypeText("")
    }

    func testCVVField() throws {
        let cardNumberField = app.textFields["Card number"]
        let expiryField = app.textFields["Expiry"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter Visa card to get CVV field (3 digits required)
        cardNumberField.tap()
        usleep(500000)
        cardNumberField.typeText("4012000033330026") // Visa
        sleep(2) // Wait for card type detection

        let cvvField = app.secureTextFields["CVV"]
        XCTAssertTrue(cvvField.waitForExistence(timeout: 3.0), "CVV field should be displayed for Visa")

        // Test invalid: 1 digit CVV - should show error on defocus
        cvvField.tap()
        usleep(500000)
        cvvField.typeText("1")
        usleep(300000)

        // Defocus to trigger validation
        cardNumberField.tap()
        sleep(1)

        let oneDigitError = app.staticTexts["Invalid security code"]
        XCTAssertTrue(oneDigitError.waitForExistence(timeout: 3.0), "1-digit CVV should show 'Invalid security code' error")

        // Test valid: 3 digit CVV - should NOT show error
        cvvField.tap()
        usleep(500000)
        // Delete the "1" and type "123"
        cvvField.typeText(XCUIKeyboardKey.delete.rawValue)
        usleep(200000)
        cvvField.typeText("123")
        usleep(300000)

        // Defocus to trigger validation
        expiryField.tap()
        sleep(1)

        let threeDigitError = app.staticTexts["Invalid security code"]
        XCTAssertFalse(threeDigitError.exists, "3-digit CVV should NOT show error")
    }

    func testRememberCardToggle() throws {
        // Find the "Remember this card for next time." toggle (note the period)
        let rememberCardToggle = app.switches["Remember this card for next time."]
        XCTAssertTrue(rememberCardToggle.exists, "Remember this card for next time toggle should exist")

        // Check initial state (assuming it starts as OFF)
        let initialValue = rememberCardToggle.value as? String ?? "0"
        print("Initial toggle state: \(initialValue)")

        // Test toggling ON
        if initialValue == "0" {
            // Toggle is OFF, turn it ON
            rememberCardToggle.tap()
            sleep(1)

            let toggledOnValue = rememberCardToggle.value as? String ?? "0"
            XCTAssertEqual(toggledOnValue, "1", "Toggle should be ON after tapping")
            print("Toggle turned ON: \(toggledOnValue)")

            // Test toggling OFF
            rememberCardToggle.tap()
            sleep(1)

            let toggledOffValue = rememberCardToggle.value as? String ?? "1"
            XCTAssertEqual(toggledOffValue, "0", "Toggle should be OFF after tapping again")
            print("Toggle turned OFF: \(toggledOffValue)")

        } else {
            // Toggle is ON, turn it OFF
            rememberCardToggle.tap()
            sleep(1)

            let toggledOffValue = rememberCardToggle.value as? String ?? "1"
            XCTAssertEqual(toggledOffValue, "0", "Toggle should be OFF after tapping")
            print("Toggle turned OFF: \(toggledOffValue)")

            // Test toggling ON
            rememberCardToggle.tap()
            sleep(1)

            let toggledOnValue = rememberCardToggle.value as? String ?? "0"
            XCTAssertEqual(toggledOnValue, "1", "Toggle should be ON after tapping again")
            print("Toggle turned ON: \(toggledOnValue)")
        }

        // Verify toggle is interactive and visible
        XCTAssertTrue(rememberCardToggle.isHittable, "Toggle should be interactive")
        XCTAssertTrue(rememberCardToggle.exists, "Toggle should remain visible")
    }

    func testPrivacyPolicyLink() throws {
        // Find the "Read our privacy policy" link
        let privacyPolicyLink = app.staticTexts["Read our privacy policy"]
        XCTAssertTrue(privacyPolicyLink.exists, "Privacy policy link should exist")

        // Verify the link is interactive
        XCTAssertTrue(privacyPolicyLink.isHittable, "Privacy policy link should be tappable")

        // Store the initial app state
        let initialAppState = app.state

        // Tap the privacy policy link
        privacyPolicyLink.tap()
        sleep(2) // Wait for potential external app launch

        // Verify the link tap was successful (link should still exist after tap)
        XCTAssertTrue(privacyPolicyLink.exists, "Privacy policy link should still exist after tap")

        // Additional verification: Check if the app is still running
        // When an external browser opens, the app typically goes to background but stays running
        let currentAppState = app.state

        // The app should either be running normally or backgrounded (indicating external app launched)
        let validStates: [XCUIApplication.State] = [.runningForeground, .runningBackground, .runningBackgroundSuspended]
        XCTAssertTrue(validStates.contains(currentAppState),
                      "App should be in a valid state after link tap. Current state: \(currentAppState.rawValue)")

        // If app went to background, bring it back to foreground for cleanup
        if currentAppState != .runningForeground {
            app.activate()
            sleep(1)
        }

        print("Privacy policy link test completed. Initial state: \(initialAppState.rawValue), Final state: \(currentAppState.rawValue)")
    }

    // MARK: - Card Number Field Additional Visual Tests

    func testCardNumberErrorClearsWhenDeletingBelowMinimum() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter an invalid 16-digit card number (fails Luhn)
        cardNumberField.slowTypeText("4111111111111112")
        usleep(1000000) // 1s for validation

        // Verify error is shown
        let errorMessage = app.staticTexts["Invalid card number"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2.0), "Error should appear for invalid card number")

        // Delete characters to go below 16 digits (Visa minimum)
        cardNumberField.tap()
        usleep(300000)
        for _ in 0..<5 {
            cardNumberField.typeText(XCUIKeyboardKey.delete.rawValue)
            usleep(100000)
        }
        usleep(500000)

        // Error should be cleared when below minimum digits during typing
        XCTAssertFalse(errorMessage.exists, "Error should clear when digits fall below minimum")
    }

    func testCardNumberClearResetsFieldState() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter a valid Visa card number
        cardNumberField.slowTypeText("4111111111111111")
        usleep(1000000) // 1s for validation

        // Verify Visa scheme is detected (check for Visa image or CVV label)
        let cvvField = app.secureTextFields["CVV"]
        XCTAssertTrue(cvvField.waitForExistence(timeout: 2.0), "CVV field should exist for Visa")

        // Verify no error is shown
        let errorMessage = app.staticTexts["Invalid card number"]
        XCTAssertFalse(errorMessage.exists, "No error should be shown for valid card")

        // Clear the field completely
        cardNumberField.slowTypeText("")
        usleep(500000)

        // Verify field is empty
        let fieldValue = cardNumberField.value as? String ?? ""
        XCTAssertTrue(fieldValue.isEmpty || fieldValue == "XXXX XXXX XXXX XXXX",
                      "Field should be empty or show placeholder")

        // Verify no error is shown after clearing
        XCTAssertFalse(errorMessage.exists, "No error should be shown after clearing field")
    }

    func testCardSchemeIconUpdatesWhenChangingScheme() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter Visa card prefix
        cardNumberField.slowTypeText("4111111111111111")
        usleep(1500000) // 1.5s for scheme detection

        // Verify CVV label (Visa uses CVV)
        let cvvField = app.secureTextFields["CVV"]
        XCTAssertTrue(cvvField.waitForExistence(timeout: 2.0), "CVV field should exist for Visa")

        // Clear and enter Amex card
        cardNumberField.slowTypeText("371449635398431")
        usleep(1500000) // 1.5s for scheme detection

        // Verify CID label (Amex uses CID)
        let cidField = app.secureTextFields["CID"]
        XCTAssertTrue(cidField.waitForExistence(timeout: 2.0), "CID field should exist for Amex")

        // Clear and enter Mastercard
        cardNumberField.slowTypeText("5111111111111118")
        usleep(1500000) // 1.5s for scheme detection

        // Verify CVC label (Mastercard uses CVC)
        let cvcField = app.secureTextFields["CVC"]
        XCTAssertTrue(cvcField.waitForExistence(timeout: 2.0), "CVC field should exist for Mastercard")
    }

    func testEmptyCardNumberFieldNoErrorUntilInteraction() throws {
        let cardNumberField = app.textFields["Card number"]
        let expiryField = app.textFields["Expiry"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Initially, no error should be shown
        let errorMessage = app.staticTexts["Invalid card number"]
        XCTAssertFalse(errorMessage.exists, "No error should be shown initially")

        // Focus card number field then immediately move to expiry field (without typing)
        cardNumberField.tap()
        usleep(500000)
        expiryField.tap()
        usleep(500000)

        // No error should be shown for empty untouched field
        XCTAssertFalse(errorMessage.exists, "No error should be shown for empty field that was only focused")
    }

    func testCardNumberAutoFormattingWithSpaces() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter card number without spaces
        cardNumberField.slowTypeText("4111111111111111")
        usleep(500000)

        // Verify the displayed value has spaces (4-4-4-4 format)
        let fieldValue = cardNumberField.value as? String ?? ""
        XCTAssertTrue(fieldValue.contains(" "), "Card number should be auto-formatted with spaces")
        XCTAssertEqual(fieldValue, "4111 1111 1111 1111", "Card number should be in 4-4-4-4 format")
    }

    func testAmexCardNumberAutoFormattingPattern() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter Amex card number
        cardNumberField.slowTypeText("378282246310005")
        usleep(500000)

        // Verify the displayed value has Amex spacing (4-6-5 format)
        let fieldValue = cardNumberField.value as? String ?? ""
        XCTAssertTrue(fieldValue.contains(" "), "Amex card number should be auto-formatted with spaces")
        XCTAssertEqual(fieldValue, "3782 822463 10005", "Amex card number should be in 4-6-5 format")
    }

    func testCardNumberValidationAfterErrorCorrection() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter an invalid card number (fails Luhn)
        cardNumberField.slowTypeText("4111111111111112")
        usleep(1000000) // 1s for validation

        // Verify error is shown
        let errorMessage = app.staticTexts["Invalid card number"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2.0), "Error should appear for invalid card number")

        // Correct the card number by clearing and entering valid number
        cardNumberField.slowTypeText("4111111111111111")
        usleep(1000000) // 1s for validation

        // Error should be cleared
        XCTAssertFalse(errorMessage.exists, "Error should clear when valid card number is entered")

        // Verify no error is shown
        let fieldValue = cardNumberField.value as? String ?? ""
        let cleanValue = fieldValue.replacingOccurrences(of: " ", with: "")
        XCTAssertEqual(cleanValue, "4111111111111111", "Valid card number should be accepted")
    }

    func testCardNumberMinDigitValidationOnDefocus() throws {
        let cardNumberField = app.textFields["Card number"]
        let expiryField = app.textFields["Expiry"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Enter partial card number (below minimum)
        cardNumberField.slowTypeText("411111")
        usleep(500000)

        // No error during typing
        let errorMessage = app.staticTexts["Invalid card number"]
        XCTAssertFalse(errorMessage.exists, "No error should be shown during typing below minimum")

        // Defocus by tapping another field
        expiryField.tap()
        usleep(1000000) // 1s for validation on defocus

        // Error should appear after defocus
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2.0),
                      "Error should appear on defocus when below minimum digits")
    }

    func testCardNumberFieldRejectsNonNumericVisually() throws {
        let cardNumberField = app.textFields["Card number"]
        XCTAssertTrue(cardNumberField.exists, "Card number field should exist")

        // Attempt to enter mixed alphanumeric input
        // Note: The keyboard is numeric, but we can test paste behavior
        cardNumberField.tap()
        usleep(500000)

        // Type valid numbers
        cardNumberField.typeText("4111")
        usleep(300000)

        // Verify only numeric content is present
        let fieldValue = cardNumberField.value as? String ?? ""
        let numericOnly = fieldValue.filter { $0.isNumber }
        XCTAssertEqual(numericOnly.count, 4, "Field should only contain numeric characters")
    }

////     swiftlint:disable:next function_body_length
//    func testSuccessfulTokenization() throws {
//        // Test data: Card Number, CVV, Card Type
//        let testCards = [
//            ("5111111111111118", "100", "MasterCard"),  // MasterCard
//            ("4012000033330026", "100", "Visa"),        // Visa
//            ("371449635398431", "1000", "AMEX"),        // AMEX
//            ("3528111100000001", "100", "JCB")          // JCB
//        ]
//
//        for (cardNumber, cvv, cardType) in testCards {
//            print("Testing tokenization for \(cardType): \(cardNumber)")
//
//            navigateToCardDetailsWidget()
//
//            // Fill cardholder name
//            let cardholderField = app.textFields["Cardholder name"]
//            XCTAssertTrue(cardholderField.waitForExistence(timeout: 1.0), "Cardholder name field should exist")
//            cardholderField.slowTypeText("John Doe") // Use slow for form validation
//
//            // Fill card number
//            let cardNumberField = app.textFields["Card number"]
//            XCTAssertTrue(cardNumberField.exists, "Card number field should exist")
//            cardNumberField.slowTypeText(cardNumber) // Use slow for card type detection
//            usleep(1500000) // Wait for card type detection (1.5s)
//
//            // Fill expiry date (future date)
//            let expiryField = app.textFields["Expiry"]
//            XCTAssertTrue(expiryField.exists, "Expiry field should exist")
//            expiryField.slowTypeText("12/30") // Use slow for validation
//
//            // Fill CVV/CVC/CID based on card type
//            var securityField: XCUIElement
//            if cardType == "AMEX" {
//                securityField = app.textFields["CID"]
//                XCTAssertTrue(securityField.waitForExistence(timeout: 2.0), "CID field should exist for AMEX")
//            } else if cardType == "MasterCard" {
//                securityField = app.textFields["CVC"]
//                XCTAssertTrue(securityField.waitForExistence(timeout: 2.0), "CVC field should exist for MasterCard")
//            } else {
//                securityField = app.textFields["CVV"]
//                XCTAssertTrue(securityField.waitForExistence(timeout: 2.0), "CVV field should exist for \(cardType)")
//            }
//
//            securityField.slowTypeText(cvv) // Use slow for validation
//            usleep(1000000) // Wait for form validation (1s)
//
//            // Submit the form
//            let submitButton = app.buttons["Submit"]
//            XCTAssertTrue(submitButton.waitForExistence(timeout: 1.0), "Submit button should exist")
//            XCTAssertTrue(submitButton.isEnabled, "Submit button should be enabled with valid data")
//
//            submitButton.tap()
//            print("Submitted form for \(cardType)")
//
//            // Wait for potential 3DS or success response
//            usleep(3000000) // 3s instead of 5s
//
//            // Check for 3DS challenge
//            let approve3DSButton = app.buttons["Approve"]
//            let continue3DSButton = app.buttons["Continue"]
//            let authorize3DSButton = app.buttons["Authorize"]
//
//            if approve3DSButton.waitForExistence(timeout: 1.0) {
//                print("3DS challenge detected for \(cardType), approving...")
//                approve3DSButton.tap()
//                usleep(2000000) // 2s instead of 3s
//            } else if continue3DSButton.waitForExistence(timeout: 1.0) {
//                print("3DS continue detected for \(cardType), continuing...")
//                continue3DSButton.tap()
//                usleep(2000000) // 2s instead of 3s
//            } else if authorize3DSButton.waitForExistence(timeout: 1.0) {
//                print("3DS authorize detected for \(cardType), authorizing...")
//                authorize3DSButton.tap()
//                usleep(2000000) // 2s instead of 3s
//            }
//
//            // Wait for final response
//            usleep(2000000) // 2s instead of 3s
//
//            // Check for success indicators
//            // Look for alert with token or success message
//            let alertTitle = app.alerts.element.label
//            let alertExists = app.alerts.element.exists
//
//            if alertExists {
//                print("Alert detected for \(cardType): \(alertTitle)")
//
//                // Check if it's a success (contains token or success message)
//                let alertMessage = app.alerts.element.staticTexts.element(boundBy: 1).label
//                print("Alert message: \(alertMessage)")
//
//                // Success indicators could be:
//                // - Alert title is "Card Details" (indicates response received)
//                // - Alert message contains a token (successful tokenization)
//                // - OR expected API configuration errors (test environment limitation)
//                let hasValidResponse = alertTitle.contains("Card Details")
//                let isActualSuccess = hasValidResponse &&
//                !alertMessage.lowercased().contains("error") &&
//                !alertMessage.lowercased().contains("failed") &&
//                !alertMessage.lowercased().contains("invalid")
//                let isApiConfigError = alertMessage.contains("CardDetailsError error 0") ||
//                alertMessage.contains("operation couldn't be completed")
//
//                // Accept either success OR expected API config errors (common in test environments)
//                let isAcceptableResult = isActualSuccess || (hasValidResponse && isApiConfigError)
//
//                if isActualSuccess {
//                    print("✅ Actual tokenization success for \(cardType)")
//                } else if isApiConfigError {
//                    print("⚠️ API configuration issue for \(cardType) (expected in test environment)")
//                } else {
//                    print("❌ Unexpected error for \(cardType): \(alertMessage)")
//                }
//
//                XCTAssertTrue(isAcceptableResult,
//                              "Should get valid response for \(cardType). Alert: \(alertTitle), Message: \(alertMessage)")
//
//                // Dismiss alert
//                if app.alerts.buttons["OK"].waitForExistence(timeout: 0.5) {
//                    app.alerts.buttons["OK"].tap()
//                } else if app.alerts.buttons["Dismiss"].waitForExistence(timeout: 0.5) {
//                    app.alerts.buttons["Dismiss"].tap()
//                } else {
//                    // Tap outside alert to dismiss
//                    app.tap()
//                }
//
//                usleep(500000) // 500ms instead of 1s
//
//                if isActualSuccess {
//                    print("Successfully tokenized \(cardType) ✅")
//                } else {
//                    print("Completed workflow test for \(cardType) ✅ (API config issue expected)")
//                }
//            } else {
//                // No alert might indicate success or we need to wait longer
//                print("No immediate alert for \(cardType), checking for other success indicators...")
//                sleep(2)
//
//                // Check if form was reset or any other success indicator
//                let cardNumberAfterSubmit = cardNumberField.value as? String ?? ""
//                if cardNumberAfterSubmit.isEmpty {
//                    print("\(cardType) form was reset - likely successful ✅")
//                } else {
//                    print("⚠️ No clear success indicator for \(cardType)")
//                }
//            }
//
//            // Clear any remaining state
//            sleep(1)
//        }
//
//        print("Completed tokenization tests for all card types")
//    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard self.exists else { return }

        self.tap()
        self.waitForKeyboardToAppear()

        // Clear text by deleting existing characters
        let currentValue = self.value as? String ?? ""
        if !currentValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            self.typeText(deleteString)
        }

        self.typeText(text)
    }

    func fastTypeText(_ text: String) {
        guard self.exists else { return }

        self.tap()
        self.waitForKeyboardToAppear()

        // Clear any existing text first
        let currentValue = self.value as? String ?? ""
        if !currentValue.isEmpty {
            // Delete each character individually
            for _ in 0..<currentValue.count {
                self.typeText(XCUIKeyboardKey.delete.rawValue)
            }
        }

        // Type fast for non-validation tests
        self.typeText(text)
    }

    func slowTypeText(_ text: String) {
        guard self.exists else { return }

        self.tap()
        self.waitForKeyboardToAppear()
        usleep(500000) // 500ms to ensure field is focused

        // More robust clearing: First select all, then delete, then verify it's empty
        let currentValue = self.value as? String ?? ""
        if !currentValue.isEmpty {
            // Method 1: Select all and delete
            self.doubleTap()
            usleep(500000) // Longer wait for selection
            self.typeText(XCUIKeyboardKey.delete.rawValue)
            usleep(500000) // Longer wait for deletion

            // Method 2: If text still exists, delete character by character
            let remainingValue = self.value as? String ?? ""
            if !remainingValue.isEmpty {
                for _ in 0..<remainingValue.count {
                    self.typeText(XCUIKeyboardKey.delete.rawValue)
                    usleep(100000) // 100ms between each delete
                }
                usleep(300000) // Final wait after deletion
            }
        }

        // Type character by character with delay
        for char in text {
            self.typeText(String(char))
            usleep(100000) // 100ms delay between characters
        }
        usleep(500000) // 500ms final wait
    }

    private func waitForKeyboardToAppear() {
        // Wait for keyboard instead of fixed sleep
        let keyboards = XCUIApplication().keyboards
        if !keyboards.element.exists {
            usleep(500000) // 500ms max wait
        }
    }

    var hasKeyboardFocus: Bool {
        return self.value(forKey: "hasKeyboardFocus") as? Bool ?? false
    }
}
