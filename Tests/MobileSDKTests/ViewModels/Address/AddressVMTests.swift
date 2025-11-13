//
//  AddressVMTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.09.2025..
//

import XCTest
import SwiftUI
import MapKit
@testable import MobileSDK

@MainActor
final class AddressVMTests: XCTestCase {

    private var viewModel: AddressVM!
    private var formManager: TestAddressFormManager!
    private var config: AddressWidgetConfig!
    private var eventDelegate: WidgetEventDelegateUtil!
    private var completionAddress: Address?

    override func setUp() {
        super.setUp()
        completionAddress = nil
        formManager = TestAddressFormManager()
        config = AddressWidgetConfig(address: nil)
        eventDelegate = WidgetEventDelegateUtil()
        viewModel = AddressVM(
            config: config,
            appearance: AddressWidgetAppearance(),
            eventDelegate: nil,
            addressFormManager: formManager,
            localSearchCompleter: MKLocalSearchCompleter(),
            completion: { [weak self] address in
                self?.completionAddress = address
            })
    }

    override func tearDown() {
        viewModel = nil
        formManager = nil
        config = nil
        eventDelegate = nil
        completionAddress = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateDefaults() {
        XCTAssertEqual(viewModel.addressSearchSuggestions, [""])
        XCTAssertEqual(viewModel.countrySearchSuggestions, [""])
        XCTAssertEqual(viewModel.isDisabled, false)
        XCTAssertTrue(viewModel.mkLocalSearchCompletions.isEmpty)
        XCTAssertFalse(formManager.showAddressSearchPopup)
        XCTAssertFalse(formManager.showCountrySearchPopup)
        XCTAssertFalse(formManager.isAddressFormExpanded)
    }

    // MARK: - Country Search

    func testCountrySearchEmptyHidesPopupAndClearsSuggestions() {
        // Given
        formManager.showCountrySearchPopup = true

        // When
        viewModel.searchCountry("")

        // Then
        XCTAssertFalse(formManager.showCountrySearchPopup)
        XCTAssertEqual(viewModel.countrySearchSuggestions, [""])
    }

    func testCountrySearchFiltersAndShowsPopupWhenFocused() {
        // Given
        formManager.setEditingTextField(focusedField: .country)
        formManager.countrySearchText = "Uni"

        // When
        viewModel.searchCountry("Uni")

        // Then - should show popup and limit to 4 results
        XCTAssertTrue(formManager.showCountrySearchPopup)
        XCTAssertFalse(viewModel.countrySearchSuggestions.isEmpty)
        // Expect countries containing "Uni" (United Kingdom, United States)
        XCTAssertTrue(viewModel.countrySearchSuggestions.allSatisfy { $0.lowercased().contains("uni") })
        XCTAssertLessThanOrEqual(viewModel.countrySearchSuggestions.count, 4)
    }

    func testHandleTapOnCountryOptionUpdatesManagerAndHidesPopup() {
        // Given
        formManager.setEditingTextField(focusedField: .country)
        formManager.countrySearchText = "Aus"
        viewModel.searchCountry("Aus") // Produces ["Australia", "Austria"] in our deterministic list
        XCTAssertEqual(viewModel.countrySearchSuggestions.prefix(2), ["Australia", "Austria"]) // sanity

        // When
        viewModel.handleTapOnCountryOptionAt(index: 1) // "Austria"

        // Then
        XCTAssertEqual(formManager.countrySearchText, "Austria")
        XCTAssertEqual(formManager.countryText, "Austria")
        XCTAssertFalse(formManager.showCountrySearchPopup)
        XCTAssertEqual(viewModel.countrySearchSuggestions, [""])
    }

    // MARK: - Validation / Button State

    func testIsActionButtonDisabledReflectsFormValidity() {
        // Initially invalid
        XCTAssertTrue(viewModel.isActionButtonDisabled())

        // Fill in required fields to make it valid
        formManager.firstNameText = "John"
        formManager.lastNameText = "Doe"
        formManager.addressLine1Text = "123 Main St"
        formManager.cityText = "Sydney"
        formManager.stateText = "NSW"
        formManager.postcodeText = "2000"
        formManager.countryText = "Australia" // Valid per TestAddressFormManager

        XCTAssertFalse(viewModel.isActionButtonDisabled())
    }

    // MARK: - Save / Update Address

    func testSaveAddressCallsCompletionWithComposedAddress() {
        // Given - populate form fields
        formManager.firstNameText = "Jane"
        formManager.lastNameText = "Smith"
        formManager.addressLine1Text = "1 Infinite Loop"
        formManager.addressLine2Text = "Suite 100"
        formManager.cityText = "Cupertino"
        formManager.stateText = "CA"
        formManager.postcodeText = "95014"
        formManager.countryText = "United States"

        // When
        viewModel.saveAddress()

        // Then
        XCTAssertNotNil(completionAddress)
        XCTAssertEqual(completionAddress?.firstName, "Jane")
        XCTAssertEqual(completionAddress?.lastName, "Smith")
        XCTAssertEqual(completionAddress?.addressLine1, "1 Infinite Loop")
        XCTAssertEqual(completionAddress?.addressLine2, "Suite 100")
        XCTAssertEqual(completionAddress?.city, "Cupertino")
        XCTAssertEqual(completionAddress?.state, "CA")
        XCTAssertEqual(completionAddress?.postcode, "95014")
        XCTAssertEqual(completionAddress?.country, "United States")
        // Search text should be cleared by saveAddress
        XCTAssertEqual(formManager.addressSearchText, "")
    }

    func testUpdateAddressLoadsFromConfig() async throws {
        // Given
        let prefilled = Address(
            firstName: "Alice",
            lastName: "Wonder",
            addressLine1: "42 Fantasy Rd",
            addressLine2: "",
            city: "Wonderland",
            state: "WL",
            postcode: "4242",
            country: "Austria"
        )
        config = AddressWidgetConfig(address: prefilled)
        viewModel = AddressVM(
            config: config,
            appearance: AddressWidgetAppearance(),
            eventDelegate: nil,
            addressFormManager: formManager,
            localSearchCompleter: MKLocalSearchCompleter(),
            completion: { [weak self] address in
                self?.completionAddress = address
            }
        )

        // When
        viewModel.updateAddress()

        try await Task.sleep(nanoseconds: 500_000_000)
        // Then
        XCTAssertEqual(formManager.firstNameText, "Alice")
        XCTAssertEqual(formManager.lastNameText, "Wonder")
        XCTAssertEqual(formManager.addressLine1Text, "42 Fantasy Rd")
        XCTAssertEqual(formManager.addressLine2Text, "")
        XCTAssertEqual(formManager.cityText, "Wonderland")
        XCTAssertEqual(formManager.stateText, "WL")
        XCTAssertEqual(formManager.postcodeText, "4242")
        XCTAssertEqual(formManager.countryText, "Austria")
    }

    // MARK: - Address Search Binding & Delegate

    func testAddressSearchBindingEmptyHidesPopup() {
        // Given
        formManager.showAddressSearchPopup = true

        // When
        viewModel.addressSearchBinding.wrappedValue = "" // triggers searchAddress("")

        // Then
        XCTAssertFalse(formManager.showAddressSearchPopup)
    }

    // Deterministic AddressFormManager for testing country search logic
    private class TestAddressFormManager: AddressFormManager {
        override func getCountryList() -> [String] {
            return [
                "Australia",
                "Austria",
                "United Kingdom",
                "United States"
            ]
        }
    }

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesSaveEvent() {
        // Given
        let appearance = AddressWidgetAppearance()
        viewModel = AddressVM(
            config: config,
            appearance: appearance,
            eventDelegate: eventDelegate,
            addressFormManager: formManager,
            localSearchCompleter: MKLocalSearchCompleter(),
            completion: { [weak self] address in
                self?.completionAddress = address
            })

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(
            type: .button,
            properties: .button(
                WidgetEventButtonProperties(name: "SaveButton", action: .click, text: appearance.actionButton.text)))
        viewModel.handleSaveAddresTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateExpandEvent() {
        // Given
        let appearance = AddressWidgetAppearance()
        viewModel = AddressVM(
            config: config,
            appearance: appearance,
            eventDelegate: eventDelegate,
            addressFormManager: formManager,
            localSearchCompleter: MKLocalSearchCompleter(),
            completion: { [weak self] address in
                self?.completionAddress = address
            })

        // Reset any events from initialization
        eventDelegate.reset()

        // When
        let event = WidgetEvent(type: .button, properties: .button(WidgetEventButtonProperties(name: "ManualEntryButton", action: .click)))
        viewModel.handleExpandAddressFormTapAnalytics()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, event)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateWithoutDelegate() {
        // Given
        viewModel = AddressVM(
            config: config,
            appearance: AddressWidgetAppearance(),
            eventDelegate: nil,
            addressFormManager: formManager,
            localSearchCompleter: MKLocalSearchCompleter(),
            completion: { [weak self] address in
                self?.completionAddress = address
            })

        // Reset any events from initialization
        eventDelegate.reset()

        // For demonstration, we'll simulate what the view model would do:
        viewModel.saveAddress()

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 0)
        XCTAssertNil(eventDelegate.lastEvent)
    }
}
