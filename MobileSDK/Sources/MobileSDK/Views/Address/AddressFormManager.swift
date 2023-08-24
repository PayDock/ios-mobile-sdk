//
//  AddressFormManager.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.08.2023..
//

import Foundation

class AddressFormManager {

    // MARK: - Properties

    @Published var addressSearchError = ""

    @Published var editingAddressSearch = false
    @Published var showAddressSearchPopup = false

    @Published var addressSearchErrorValid = true

    let addressSearchErrorTitle = "Search for your address"

    var addressSearchErrorPlaceholder = ""

    var addressSearchErrorText: String = ""

    var addressSearchText: String = ""


    private var currentTextField: AddressFocusable?

    // MARK: - Methods

    func setEditingTextField(focusedField: AddressFocusable?) {
        validateOldTextField(currentTextField)
        currentTextField = focusedField

        guard let focusedField = focusedField else { return }
        switch focusedField {
        case .searchAddress:
            editingAddressSearch = true
            showAddressSearchPopup = true
        }
    }

    // MARK: - Validations

    private func validateOldTextField(_ textField: AddressFocusable?) {

    }

}

extension AddressFormManager {

    enum AddressFocusable: Hashable {
        case searchAddress
    }

}
