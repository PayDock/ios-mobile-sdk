//
//  AddressFormManager.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 22.08.2023..
//

import Foundation
import SwiftUI

class AddressFormManager: ObservableObject {

    // MARK: - Properties

    @Published var firstNameError = " "
    @Published var lastNameError = " "
    @Published var addressSearchError = " "
    @Published var addressLine1Error = " "
    @Published var addressLine2Error = " "
    @Published var cityError = " "
    @Published var stateError = " "
    @Published var postcodeError = " "
    @Published var countryError = " "

    @Published var editingFirstName = false
    @Published var editingLastName = false
    @Published var editingAddressSearch = false
    @Published var editingAddressLine1 = false
    @Published var editingAddressLine2 = false
    @Published var editingCity = false
    @Published var editingState = false
    @Published var editingPostcode = false
    @Published var editingCountry = false

    @Published var firstNameValid: Bool?
    @Published var lastNameValid: Bool?
    @Published var addressSearchValid: Bool?
    @Published var addressLine1Valid: Bool?
    @Published var addressLine2Valid: Bool?
    @Published var cityValid: Bool?
    @Published var stateValid: Bool?
    @Published var postcodeValid: Bool?
    @Published var countryValid: Bool?

    let firstNameTitle = "First name"
    let lastNameTitle = "Last name"
    let addressSearchTitle = "Search for your address"
    let addressLine1Title = "Address Line 1"
    let addressLine2Title = "Address Line 2 (Optional)"
    let cityTitle = "City"
    let stateTitle = "State"
    let postcodeTitle = "Postal Code"
    let countryTitle = "Country"

    let firstNamePlaceholder = ""
    let lastNamePlaceholder = ""
    let addressSearchPlaceholder = ""
    let addressLine1Placeholder = ""
    let addressLine2Placeholder = ""
    let cityPlaceholder = ""
    let statePlaceholder = ""
    let postcodePlaceholder = ""
    let countryPlaceholder = ""

    var firstNameText = "" {
        didSet {
            if !firstNameText.isEmpty {
                self.validateTextField(.firstName)
            }
        }
    }
    @Published var lastNameText = "" {
        didSet {
            if !lastNameText.isEmpty {
                self.validateTextField(.lastName)
            }
        }
    }
    @Published var addressSearchText = ""

    @Published var addressLine1Text = "" {
        didSet {
            if !addressLine1Text.isEmpty {
                self.validateTextField(.addressLine1)
            }
        }
    }
    @Published var addressLine2Text = ""

    @Published var cityText = "" {
        didSet {
            if !cityText.isEmpty {
                self.validateTextField(.city)
            }
        }
    }
    @Published var stateText = "" {
        didSet {
            if !stateText.isEmpty {
                self.validateTextField(.state)
            }
        }
    }
    @Published var postcodeText = "" {
        didSet {
            if !postcodeText.isEmpty {
                self.validateTextField(.postcode)
            }
        }
    }
    @Published var countrySearchText = ""

    @Published var countryText = "" {
        didSet {
            if !countryText.isEmpty {
                self.validateTextField(.country)
            }
        }
    }

    private(set) var currentTextField: AddressFocusable?
    @Published var showAddressSearchPopup = false
    @Published var showCountrySearchPopup = false
    @Published var isAddressFormExpanded = false

    // MARK: - Methods

    func setEditingTextField(focusedField: AddressFocusable?) {
        // Hide address search popup when moving away from search address field
        if currentTextField == .searchAddress && focusedField != .searchAddress {
            showAddressSearchPopup = false
        }

        // Hide country search popup when moving away from country field
        if currentTextField == .country && focusedField != .country {
            showCountrySearchPopup = false
        }

        currentTextField = focusedField

        editingFirstName = focusedField == .firstName
        editingLastName = focusedField == .lastName
        editingAddressSearch = focusedField == .searchAddress
        editingAddressLine1 = focusedField == .addressLine1
        editingAddressLine2 = focusedField == .addressLine2
        editingCity = focusedField == .city
        editingState = focusedField == .state
        editingPostcode = focusedField == .postcode
        editingCountry = focusedField == .country
    }

    // MARK: - Validations

    func validateAllTextFields() {
        AddressFocusable.allCases.forEach {
            validateTextField($0)
        }
    }

    private func validateAllAddressFields() {
        AddressFocusable.allCases.forEach {
            if $0 != .firstName && $0 != .lastName {
                validateTextField($0)
            }
        }
    }

    private func validateTextField(_ textField: AddressFocusable?) {
        guard let textField = textField else { return }

        switch textField {
        case .firstName:
            let isValid = !firstNameText.trimmingCharacters(in: .whitespaces).isEmpty
            firstNameValid = isValid
            firstNameError = isValid ? "" : "Mandatory field"

        case .lastName:
            let isValid = !lastNameText.trimmingCharacters(in: .whitespaces).isEmpty
            lastNameValid = isValid
            lastNameError = isValid ? "" : "Mandatory field"

        case .searchAddress: break // Search field - no need to validate

        case .addressLine1:
            let isValid = !addressLine1Text.trimmingCharacters(in: .whitespaces).isEmpty
            addressLine1Valid = isValid
            addressLine1Error = isValid ? "" : "Mandatory field"

        case .addressLine2: break

        case .city:
            let isValid = !cityText.trimmingCharacters(in: .whitespaces).isEmpty
            cityValid = isValid
            cityError = isValid ? "" : "Mandatory field"

        case .state:
            let isValid = !stateText.trimmingCharacters(in: .whitespaces).isEmpty
            stateValid = isValid
            stateError = isValid ? "" : "Mandatory field"

        case .postcode:
            let isValid = !postcodeText.trimmingCharacters(in: .whitespaces).isEmpty
            postcodeValid = isValid
            postcodeError = isValid ? "" : "Mandatory field"

        case .country:
            let trimmedInput = countryText.trimmingCharacters(in: .whitespacesAndNewlines)
            let isValid = getCountryList().contains { $0.caseInsensitiveCompare(trimmedInput) == .orderedSame }
            countryValid = isValid
            countryError = isValid ? "" : "Mandatory field"
        }
    }

    private func isCountryValid() -> Bool {
        let trimmedInput = countryText.trimmingCharacters(in: .whitespacesAndNewlines)
        return getCountryList().contains { $0.caseInsensitiveCompare(trimmedInput) == .orderedSame }
    }

    func isFormValid() -> Bool {
        let firstNameValid = !firstNameText.trimmingCharacters(in: .whitespaces).isEmpty
        let lastNameValid = !lastNameText.trimmingCharacters(in: .whitespaces).isEmpty
        let addressLine1Valid = !addressLine1Text.trimmingCharacters(in: .whitespaces).isEmpty
        let cityValid = !cityText.trimmingCharacters(in: .whitespaces).isEmpty
        let stateValid = !stateText.trimmingCharacters(in: .whitespaces).isEmpty
        let postcodeValid = !postcodeText.trimmingCharacters(in: .whitespaces).isEmpty
        let countryValid = isCountryValid()

        return firstNameValid && lastNameValid && addressLine1Valid && cityValid && stateValid && postcodeValid && countryValid
    }

    func updateFormWith(reversedGeoLocation: ReversedGeoLocation) {
        addressLine1Text = reversedGeoLocation.formattedAddressLine
        cityText = reversedGeoLocation.city
        stateText = reversedGeoLocation.state
        postcodeText = reversedGeoLocation.zipCode
        countryText = reversedGeoLocation.country

        validateAllAddressFields()
    }

    func updateFormWith(address: Address?) {
        guard let address = address else { return }
        firstNameText = address.firstName
        lastNameText = address.lastName
        addressLine1Text = address.addressLine1
        addressLine2Text = address.addressLine2
        cityText = address.city
        stateText = address.state
        postcodeText = address.postcode
        countryText = address.country

        validateAllTextFields()
    }

    func getCountryList() -> [String] {
        let englishLocale = Locale(identifier: "en")
        let countryCodes = Locale.Region.isoRegions.filter { $0.subRegions.isEmpty }.map { $0.identifier }.sorted()

        let countryNames = countryCodes.compactMap { code in
            englishLocale.localizedString(forRegionCode: code)
        }.sorted()

        return countryNames
    }

    // MARK: - Editing

    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        editingFirstName = false
        editingLastName = false
        editingAddressSearch = false
        editingAddressLine1 = false
        editingAddressLine2 = false
        editingCity = false
        editingState = false
        editingPostcode = false
        editingCountry = false
    }

}

extension AddressFormManager {

    enum AddressFocusable: Hashable, CaseIterable {
        case firstName
        case lastName
        case searchAddress
        case addressLine1
        case addressLine2
        case city
        case state
        case postcode
        case country
    }

}
