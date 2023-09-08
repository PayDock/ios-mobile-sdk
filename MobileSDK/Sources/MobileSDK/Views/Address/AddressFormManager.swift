//
//  AddressFormManager.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.08.2023..
//

import Foundation

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

    @Published var firstNameValid = true
    @Published var lastNameValid = true
    @Published var addressSearchValid = true
    @Published var addressLine1Valid = true
    @Published var addressLine2Valid = true
    @Published var cityValid = true
    @Published var stateValid = true
    @Published var postcodeValid = true
    @Published var countryValid = true

    let firstNameTitle = "First name"
    let lastNameTitle = "Last name"
    let addressSearchTitle = "Search for your address"
    let addressLine1Title = "Address Line 1"
    let addressLine2Title = "Address Line 2 (Optional)"
    let cityTitle = "City"
    let stateTitle = "State"
    let postcodeTitle = "Postcode"
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

    @Published var firstNameText = ""
    @Published var lastNameText = ""
    @Published var addressSearchText = ""
    @Published var addressLine1Text = ""
    @Published var addressLine2Text = ""
    @Published var cityText = ""
    @Published var stateText = ""
    @Published var postcodeText = ""
    @Published var countryText = ""

    private var currentTextField: AddressFocusable?
    @Published var showAddressSearchPopup = false
    @Published var isAddressFormExpanded = false

    // MARK: - Methods

    func setEditingTextField(focusedField: AddressFocusable?) {
        validateTextField(currentTextField)
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
            firstNameValid = !firstNameText.isEmpty
            firstNameError = firstNameText.isEmpty ? "Mandatory field" : ""

        case .lastName:
            lastNameValid = !lastNameText.isEmpty
            lastNameError = lastNameText.isEmpty ? "Mandatory field" : ""

        case .searchAddress: break // Search field - no need to validate

        case .addressLine1:
            addressLine1Valid = !addressLine1Text.isEmpty
            addressLine1Error = addressLine1Text.isEmpty ? "Mandatory field" : ""

        case .addressLine2: break

        case .city:
            cityValid = !cityText.isEmpty
            cityError = cityText.isEmpty ? "Mandatory field" : ""

        case .state:
            stateValid = !stateText.isEmpty
            stateError = stateText.isEmpty ? "Mandatory field" : ""

        case .postcode:
            postcodeValid = !postcodeText.isEmpty
            postcodeError = postcodeText.isEmpty ? "Mandatory field" : ""

        case .country:
            countryValid = !countryText.isEmpty
            countryError = countryText.isEmpty ? "Mandatory field" : ""
        }
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
