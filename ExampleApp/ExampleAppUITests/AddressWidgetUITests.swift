import XCTest

final class AddressWidgetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Navigate to Address widget once per test suite
        navigateToAddressWidget()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func navigateToAddressWidget() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 2.0), "Tab bar should exist")

        // Tap Widgets tab
        tabBar.buttons.element(boundBy: 1).tap()

        // Tap Address option
        let addressOption = app.staticTexts["Address"]
        XCTAssertTrue(addressOption.waitForExistence(timeout: 3.0), "Address option should exist")
        addressOption.tap()

        // Wait for Address widget to load
        let firstNameField = app.textFields["First name"]
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 2.0), "First name field should exist")
    }

    func testAddressWidgetUIElements() throws {
        // Verify form fields exist
        XCTAssertTrue(app.textFields["First name"].exists, "First name field should exist")
        XCTAssertTrue(app.textFields["Last name"].exists, "Last name field should exist")
        XCTAssertTrue(app.textFields["Search for your address"].exists, "Address search field should exist")

        // Verify Save button exists. The example config uses `activePrimaryButton: true`
        // (see ConfigManager), so Save is always tappable and validates on tap.
        let saveButton = app.buttons["Add"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled (activePrimaryButton = true)")

        // Check for manual entry button (before expanding form)
        let manualEntryButton = app.buttons["Or enter address manually"]
        XCTAssertTrue(manualEntryButton.exists, "Manual entry button should exist")

        // Tap "Or enter address manually" to expand the form
        manualEntryButton.tap()
        usleep(1000000) // 1s for form expansion

        // Assert that all manual address fields become visible after expansion
        XCTAssertTrue(app.textFields["Address Line 1"].waitForExistence(timeout: 2.0), "Address Line 1 field should appear")
        XCTAssertTrue(app.textFields["City"].exists, "City field should appear")
        XCTAssertTrue(app.textFields["State"].exists, "State field should appear")
        XCTAssertTrue(app.textFields["Postal Code"].exists, "Postal Code field should appear")
        XCTAssertTrue(app.textFields["Country"].exists, "Country field should appear")

        // Check for optional field
        XCTAssertTrue(app.textFields["Address Line 2 (Optional)"].exists, "Address Line 2 (Optional) field should appear")

        // Verify all name fields are still present after expansion
        XCTAssertTrue(app.textFields["First name"].exists, "First name field should still exist")
        XCTAssertTrue(app.textFields["Last name"].exists, "Last name field should still exist")

        // Verify address search field is still present
        XCTAssertTrue(app.textFields["Search for your address"].exists, "Address search field should still exist")

        // Verify Save button is still present after expansion and remains enabled (activePrimaryButton = true)
        let saveButtonAfterExpansion = app.buttons["Add"]
        XCTAssertTrue(saveButtonAfterExpansion.exists, "Save button should still exist after expansion")
        XCTAssertTrue(saveButtonAfterExpansion.isEnabled,
                      "Save button should remain enabled after expansion (activePrimaryButton = true)")
    }

    func testNoAddressSearchResults() throws {
        // Step 1: Input first name and last name
        let firstNameField = app.textFields["First name"]
        let lastNameField = app.textFields["Last name"]

        firstNameField.addressSlowTypeText("John")
        lastNameField.addressSlowTypeText("Doe")

        // Step 2: Search with gibberish text that should return no results
        let addressSearchField = app.textFields["Search for your address"]
        addressSearchField.addressSlowTypeText("#$%&%%")

        // The autocomplete dropdown is driven by MapKit's local-search completer, which needs network.
        // When it responds, a gibberish query yields the "no results" state; when there is no network
        // (e.g. CI) the completer never calls back and the popup never appears. Verify the popup
        // lifecycle only when it responds, but always verify the deterministic behaviour below.
        let noResultsMessage = app.staticTexts["Dropdown menu has no results."]
        let searchResponded = noResultsMessage.waitForExistence(timeout: 5.0)

        // Clear the search text (select-all + delete).
        addressSearchField.tap()
        usleep(500000) // 500ms to ensure field is focused
        addressSearchField.doubleTap() // Select all
        usleep(500000) // Wait for selection
        addressSearchField.typeText(XCUIKeyboardKey.delete.rawValue) // Delete
        usleep(500000) // Wait for deletion to complete
        usleep(1000000) // 1s for UI update

        // If the completer responded, clearing the field should dismiss the "no results" popup.
        if searchResponded {
            XCTAssertFalse(noResultsMessage.exists,
                           "No results message should disappear when the search field is cleared")
        }

        // Verify search field is now empty
        let clearedSearchFieldValue = addressSearchField.value as? String ?? ""
        XCTAssertTrue(clearedSearchFieldValue.isEmpty ||
                      clearedSearchFieldValue == "Search for your address",
                      "Search field should be empty or show placeholder after clearing")

        // Save stays enabled regardless of address validity (activePrimaryButton = true); validation runs on tap.
        let saveButton = app.buttons["Add"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        XCTAssertTrue(saveButton.isEnabled, "Save button should remain enabled when no valid address is found (activePrimaryButton = true)")
    }

    func testAddressActivePrimaryButtonEnabledByDefault() throws {
        // With `activePrimaryButton: true`, the Save button is enabled even before any input.
        let saveButton = app.buttons["Add"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3.0), "Save button should exist")
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled on an empty form (activePrimaryButton = true)")

        // Tapping with an empty/invalid form validates in place (revealing the manual-entry fields)
        // rather than completing.
        saveButton.tap()
        XCTAssertTrue(app.textFields["Address Line 1"].waitForExistence(timeout: 2.0),
                      "Tapping Save on an invalid collapsed form should expand it to reveal the fields to fix")
    }

//// swiftlint:disable:next function_body_length
//    func testSuccessfulAddressSaveViaSearchAndSelection() throws {
//        // Step 1: Input first name and last name
//        let firstNameField = app.textFields["First name"]
//        let lastNameField = app.textFields["Last name"]
//
//        firstNameField.addressSlowTypeText("John")
//        lastNameField.addressSlowTypeText("Doe")
//
//        // Step 2: Search for address in the search box
//        let addressSearchField = app.textFields["Search for your address"]
//        addressSearchField.addressSlowTypeText("44 hunt road")
//
//        // Wait for search suggestions to appear
//        usleep(1000000)
//
//        // Step 3: Select from suggestions
//        // Wait for address suggestions to appear
//        usleep(1000000)
//
//        var suggestionTapped = false
//
//        // Look for suggestions containing "44 Hunt Road"
//        let elementTypes = [
//            app.buttons.containing(NSPredicate(format: "label CONTAINS[c] '44 Hunt Road'")),
//            app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] '44 Hunt Road'")),
//            app.cells.containing(NSPredicate(format: "label CONTAINS[c] '44 Hunt Road'")),
//            app.otherElements.containing(NSPredicate(format: "label CONTAINS[c] '44 Hunt Road'"))
//        ]
//
//        for query in elementTypes {
//            if suggestionTapped { break }
//
//            if query.count > 0 {
//                let suggestion = query.firstMatch
//                if suggestion.waitForExistence(timeout: 1.0) {
//                    suggestion.tap()
//                    suggestionTapped = true
//                    break
//                }
//            }
//        }
//
//        // Assert that we found and tapped a suggestion
//        XCTAssertTrue(suggestionTapped, "Should have found and tapped an address suggestion from the visible list")
//
//        // Step 4: Verify all fields are auto-populated and search box is cleared
//        usleep(2000000) // 2s for auto-population
//
//        // Check that search box is cleared after selection
//        let searchFieldValue = addressSearchField.value as? String ?? ""
//        XCTAssertTrue(searchFieldValue.isEmpty, "Search field should be cleared after address selection")
//
//        // Verify address fields are auto-populated
//        let addressLine1Field = app.textFields["Address Line 1"]
//        let cityField = app.textFields["City"]
//        let stateField = app.textFields["State"]
//        let postcodeField = app.textFields["Postal Code"]
//        let countryField = app.textFields["Country"]
//
//        // Verify address fields exist and have content
//        XCTAssertTrue(addressLine1Field.exists, "Address Line 1 field should exist")
//        XCTAssertTrue(cityField.exists, "City field should exist")
//        XCTAssertTrue(stateField.exists, "State field should exist")
//        XCTAssertTrue(postcodeField.exists, "Postal Code field should exist")
//        XCTAssertTrue(countryField.exists, "Country field should exist")
//
//        XCTAssertFalse((addressLine1Field.value as? String ?? "").isEmpty, "Address Line 1 should have content")
//        XCTAssertFalse((cityField.value as? String ?? "").isEmpty, "City should have content")
//        XCTAssertFalse((stateField.value as? String ?? "").isEmpty, "State should have content")
//        XCTAssertFalse((postcodeField.value as? String ?? "").isEmpty, "Postal Code should have content")
//        XCTAssertFalse((countryField.value as? String ?? "").isEmpty, "Country should have content")
//
//        // Step 5: Check for additional mandatory fields and save
//        let saveButton = app.buttons["Add"]
//        XCTAssertTrue(saveButton.waitForExistence(timeout: 2.0), "Save button should be available")
//
//        // Wait for form validation after auto-population
//        usleep(1000000) // 1s for form validation
//
//        // Tap save button if enabled
//        if saveButton.isEnabled {
//            saveButton.tap()
//            usleep(3000000) // 3s for save operation
//        } else {
//            XCTFail("Save button should be enabled after address auto-population")
//        }
//    }

//    func testSuccessfulAddressSaveViaManualInput() throws {
//        // Step 1: Input first name and last name
//        let firstNameField = app.textFields["First name"]
//        let lastNameField = app.textFields["Last name"]
//
//        firstNameField.addressSlowTypeText("John")
//        lastNameField.addressSlowTypeText("Doe")
//
//        // Step 2: Click on manual entry button
//        let manualEntryButton = app.buttons["Or enter address manually"]
//        XCTAssertTrue(manualEntryButton.exists, "Manual entry button should exist")
//        manualEntryButton.tap()
//        usleep(1000000) // 1s for form expansion
//
//        // Step 3: Input address details manually
//        let addressLine1Field = app.textFields["Address Line 1"]
//        let cityField = app.textFields["City"]
//        let stateField = app.textFields["State"]
//        let postalCodeField = app.textFields["Postal Code"]
//        let countryField = app.textFields["Country"]
//
//        // Verify all manual entry fields are now visible
//        XCTAssertTrue(addressLine1Field.waitForExistence(timeout: 2.0), "Address Line 1 field should appear")
//        XCTAssertTrue(cityField.exists, "City field should appear")
//        XCTAssertTrue(stateField.exists, "State field should appear")
//        XCTAssertTrue(postalCodeField.exists, "Postal Code field should appear")
//        XCTAssertTrue(countryField.exists, "Country field should appear")
//
//        // Fill in address details
//        addressLine1Field.addressSlowTypeText("123 Main Street")
//        cityField.addressSlowTypeText("Sydney")
//        stateField.addressSlowTypeText("NSW")
//        postalCodeField.addressSlowTypeText("2000")
//        countryField.addressSlowTypeText("Australia")
//
//        // Wait for form validation
//        usleep(1000000) // 1s for form validation
//
//        // Step 4: Tap save button
//        let saveButton = app.buttons["Add"]
//        XCTAssertTrue(saveButton.waitForExistence(timeout: 2.0), "Save button should be available")
//        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled after filling all mandatory fields")
//
//        saveButton.tap()
//        usleep(3000000) // 3s for save operation
//    }

}

extension XCUIElement {
    func addressSlowTypeText(_ text: String) {
        guard self.exists else { return }

        // Step 1: Focus and clear the field efficiently
        self.tap()
        usleep(300000) // 300ms initial focus wait (reduced from 1s)

        // Step 2: Clear the field once with robust method
        self.doubleTap() // Select all
        usleep(200000) // Wait for selection (reduced from 500ms)
        self.typeText(XCUIKeyboardKey.delete.rawValue)
        usleep(200000) // Wait for deletion (reduced from 500ms)

        // Step 3: Type each character with minimal delays
        for char in text {
            self.typeText(String(char))
            usleep(150000) // 150ms delay between characters (reduced from 400ms)
        }

        // Step 4: Brief final wait
        usleep(300000) // 300ms final wait (reduced from 1s)
    }
}
