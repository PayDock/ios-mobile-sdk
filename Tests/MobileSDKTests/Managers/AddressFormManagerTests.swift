//
//  AddressFormManagerTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

@MainActor
final class AddressFormManagerTests: XCTestCase {

    private var sut: AddressFormManager!

    override func setUp() {
        super.setUp()
        sut = AddressFormManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialErrorsAreEmpty() {
        // Normalised from the old " " (single space) defaults so an untouched field shows no error row.
        XCTAssertEqual(sut.firstNameError, "")
        XCTAssertEqual(sut.lastNameError, "")
        XCTAssertEqual(sut.addressSearchError, "")
        XCTAssertEqual(sut.addressLine1Error, "")
        XCTAssertEqual(sut.addressLine2Error, "")
        XCTAssertEqual(sut.cityError, "")
        XCTAssertEqual(sut.stateError, "")
        XCTAssertEqual(sut.postcodeError, "")
        XCTAssertEqual(sut.countryError, "")
    }

    func testInitialValidityIsNil() {
        XCTAssertNil(sut.firstNameValid)
        XCTAssertNil(sut.countryValid)
        XCTAssertNil(sut.firstFieldWithError)
        XCTAssertEqual(sut.numberOfValidationFailures, 0)
    }

    // MARK: - validateForm (submit)

    func testValidateForm_AllEmpty_FlagsSevenRequiredFields_FirstIsFirstName() {
        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .firstName)
        // firstName, lastName, addressLine1, city, state, postcode, country — addressLine2 is optional.
        XCTAssertEqual(sut.numberOfValidationFailures, 7)
        XCTAssertEqual(sut.firstNameError, "Mandatory field")
    }

    func testValidateForm_OnlyFirstNameFilled_FirstErrorIsLastName_CountSix() {
        sut.firstNameText = "Jane"

        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .lastName)
        XCTAssertEqual(sut.numberOfValidationFailures, 6)
    }

    func testValidateForm_AllRequiredValid_ReturnsTrue_NoErrors() {
        populateValidForm()

        XCTAssertTrue(sut.validateForm())
        XCTAssertNil(sut.firstFieldWithError)
        XCTAssertEqual(sut.numberOfValidationFailures, 0)
    }

    func testValidateForm_AddressLine2Optional_DoesNotCountAsError() {
        populateValidForm()
        sut.addressLine2Text = "" // optional, left blank

        XCTAssertTrue(sut.validateForm())
        XCTAssertEqual(sut.numberOfValidationFailures, 0)
    }

    func testValidateForm_InvalidCountry_FlaggedAsError() {
        populateValidForm()
        sut.countryText = "Not A Real Country"

        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .country)
        XCTAssertEqual(sut.numberOfValidationFailures, 1)
    }

    func testValidateForm_RecoversAfterInvalid_ClearsFirstFieldAndCount() {
        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.numberOfValidationFailures, 7)

        populateValidForm()

        XCTAssertTrue(sut.validateForm())
        XCTAssertNil(sut.firstFieldWithError)
        XCTAssertEqual(sut.numberOfValidationFailures, 0)
    }

    // MARK: - Helpers

    private func populateValidForm() {
        sut.firstNameText = "Jane"
        sut.lastNameText = "Doe"
        sut.addressLine1Text = "1 Test Street"
        sut.cityText = "Sydney"
        sut.stateText = "NSW"
        sut.postcodeText = "2000"
        sut.countryText = "Australia" // deterministic via the English-locale country list
    }
}
