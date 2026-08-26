//
//  WidgetAppearancePerFieldTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import SwiftUI
@testable import MobileSDK

@MainActor
final class WidgetAppearancePerFieldTests: XCTestCase {

    // MARK: - GiftCardWidgetAppearance

    func testGiftCardAppearance_PerFieldOverrides_DefaultToBakedPlaceholderAndHint() {
        // The defaults are seeded (not nil) so the placeholder/hint text is discoverable and
        // editable via the appearance object (e.g. shown in the styling screen) rather than
        // living only as fallbacks inside the widget's rendering code.
        let appearance = GiftCardWidgetAppearance()
        XCTAssertEqual(appearance.cardNumberTextField?.placeholderText, "XXXX XXXX XXXX XXXX")
        XCTAssertEqual(appearance.cardNumberTextField?.hintText, "Enter your gift card number")
        XCTAssertEqual(appearance.pinTextField?.placeholderText, "XXXX")
        XCTAssertEqual(appearance.pinTextField?.hintText, "Enter your 4-digit PIN")
    }

    func testGiftCardAppearance_PerFieldOverrides_CanBeExplicitlyNiled() {
        // The override remains optional: passing nil explicitly opts out of the per-field default,
        // and the widget then falls back to the shared `textField` appearance.
        let appearance = GiftCardWidgetAppearance(cardNumberTextField: nil, pinTextField: nil)
        XCTAssertNil(appearance.cardNumberTextField)
        XCTAssertNil(appearance.pinTextField)
    }

    func testGiftCardAppearance_PerFieldOverrides_AreSettable() {
        let cardNumber = Theme.TextFieldAppearance(placeholderText: "card-ph", hintText: "card-hint")
        let pin = Theme.TextFieldAppearance(placeholderText: "pin-ph")
        let appearance = GiftCardWidgetAppearance(cardNumberTextField: cardNumber, pinTextField: pin)

        XCTAssertEqual(appearance.cardNumberTextField?.placeholderText, "card-ph")
        XCTAssertEqual(appearance.cardNumberTextField?.hintText, "card-hint")
        XCTAssertEqual(appearance.pinTextField?.placeholderText, "pin-ph")
    }

    // MARK: - AddressWidgetAppearance

    func testAddressAppearance_PerFieldOverrides_DefaultToNil() {
        let appearance = AddressWidgetAppearance()
        XCTAssertNil(appearance.firstNameTextField)
        XCTAssertNil(appearance.lastNameTextField)
        XCTAssertNil(appearance.addressLine1TextField)
        XCTAssertNil(appearance.addressLine2TextField)
        XCTAssertNil(appearance.cityTextField)
        XCTAssertNil(appearance.stateTextField)
        XCTAssertNil(appearance.postcodeTextField)
    }

    func testAddressAppearance_PerFieldOverride_IsSettable() {
        let city = Theme.TextFieldAppearance(placeholderText: "city-ph")
        let appearance = AddressWidgetAppearance(cityTextField: city)

        XCTAssertEqual(appearance.cityTextField?.placeholderText, "city-ph")
        XCTAssertNil(appearance.postcodeTextField)
    }

    func testAddressAppearance_RenamedInitLabels_AssignToProperties() {
        // Verifies the renamed public parameter labels (textField:/actionButton:/expandSectionButton:)
        // map onto the matching properties.
        let textField = Theme.TextFieldAppearance(placeholderText: "base-ph")
        var actionButton = GlobalTheme.shared.globalTheme.actionButton
        actionButton.text = "Save it"
        var expandButton = GlobalTheme.shared.globalTheme.expandSectionButton
        expandButton.text = "Expand it"

        let appearance = AddressWidgetAppearance(
            textField: textField,
            actionButton: actionButton,
            expandSectionButton: expandButton)

        XCTAssertEqual(appearance.textField.placeholderText, "base-ph")
        XCTAssertEqual(appearance.actionButton.text, "Save it")
        XCTAssertEqual(appearance.expandSectionButton.text, "Expand it")
    }
}
