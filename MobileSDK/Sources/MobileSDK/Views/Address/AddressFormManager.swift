//
//  AddressFormManager.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.08.2023..
//

import Foundation

class AddressFormManager {

    // MARK: - Properties

    @Published var firstNameError = ""
    @Published var lastNameError = ""
    @Published var addressSearchError = ""
    @Published var addressLine1Error = ""
    @Published var addressLine2Error = ""
    @Published var cityError = ""
    @Published var stateError = ""
    @Published var postcodeError = ""
    @Published var countryError = ""

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

    var firstNameText = ""
    var lastNameText = ""
    var addressSearchText = ""
    var addressLine1Text = ""
    var addressLine2Text = ""
    var cityText = ""
    var stateText = ""
    var postcodeText = ""
    var countryText = ""

    private var currentTextField: AddressFocusable?
    @Published var showAddressSearchPopup = false

    // MARK: - Methods

    func setEditingTextField(focusedField: AddressFocusable?) {
        validateOldTextField(currentTextField)
        currentTextField = focusedField

        guard let focusedField = focusedField else { return }

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

    private func validateOldTextField(_ textField: AddressFocusable?) {

    }

}

extension AddressFormManager {

    enum AddressFocusable: Hashable {
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
