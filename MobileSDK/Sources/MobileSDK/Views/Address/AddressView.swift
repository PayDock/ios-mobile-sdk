//
//  AddressView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

struct AddressView: View {

    @StateObject var viewModel = AddressVM()

    @FocusState private var textFieldInFocus: AddressFormManager.AddressFocusable?

    var body: some View {
        ScrollView {
            VStack {
                nameHeader
                nameAndLastNameView
                findAnAddressHeader
                autocompleteTextFieldView
                addressLine1View
                addressLine2View
                cityView
                stateView
                postcodeView
                countryView
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 600)

    }

    private var nameHeader: some View {
        HStack {
            Text("Name")
                .customFont(.body, weight: .normal)
                .foregroundColor(.gray)
            Spacer()
        }
    }

    private var nameAndLastNameView: some View {
        HStack(spacing: 12) {
            OutlineTextField(
                text: $viewModel.addressFormManager.firstNameText,
                title: viewModel.addressFormManager.firstNameTitle,
                placeholder: viewModel.addressFormManager.firstNamePlaceholder,
                errorMessage: $viewModel.addressFormManager.firstNameError,
                editing: $viewModel.addressFormManager.editingFirstName,
                valid: $viewModel.addressFormManager.firstNameValid)
            .focused($textFieldInFocus, equals: .firstName)
            .onTapGesture {
                self.textFieldInFocus = .firstName
                viewModel.addressFormManager.setEditingTextField(focusedField: .firstName)
            }

            OutlineTextField(
                text: $viewModel.addressFormManager.lastNameText,
                title: viewModel.addressFormManager.lastNameTitle,
                placeholder: viewModel.addressFormManager.lastNamePlaceholder,
                errorMessage: $viewModel.addressFormManager.lastNameError,
                editing: $viewModel.addressFormManager.editingLastName,
                valid: $viewModel.addressFormManager.lastNameValid)
            .focused($textFieldInFocus, equals: .lastName)
            .onTapGesture {
                self.textFieldInFocus = .lastName
                viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
            }
        }
    }

    private var findAnAddressHeader: some View {
        HStack {
            Text("Find an address")
                .customFont(.body, weight: .normal)
                .foregroundColor(.gray)
            Spacer()
        }
    }
    

    private var autocompleteTextFieldView: some View {
        AutocompleteTextField(
            text: viewModel.addressSearchBinding,
            title: viewModel.addressFormManager.addressSearchTitle,
            placeholder: viewModel.addressFormManager.addressSearchPlaceholder,
            errorMessage: $viewModel.addressFormManager.addressSearchError,
            editing: $viewModel.addressFormManager.editingAddressSearch,
            valid: $viewModel.addressFormManager.addressSearchValid,
            showPopup: $viewModel.addressFormManager.showAddressSearchPopup,
            options: $viewModel.addressSearchSuggestions, onSelection: {
                viewModel.reverseGeoForOptionAt(index: $0)
            })
        .focused($textFieldInFocus, equals: .searchAddress)
        .onTapGesture {
            self.textFieldInFocus = .searchAddress
            viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
        }
        .zIndex(1)
    }

    private var addressLine1View: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.addressLine1Text,
            title: viewModel.addressFormManager.addressLine1Title,
            placeholder: viewModel.addressFormManager.addressLine1Placeholder,
            errorMessage: $viewModel.addressFormManager.addressLine1Error,
            editing: $viewModel.addressFormManager.editingAddressLine1,
            valid: $viewModel.addressFormManager.addressLine1Valid)
        .focused($textFieldInFocus, equals: .addressLine1)
        .onTapGesture {
            self.textFieldInFocus = .addressLine1
            viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine1)
        }
    }

    private var addressLine2View: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.addressLine2Text,
            title: viewModel.addressFormManager.addressLine2Title,
            placeholder: viewModel.addressFormManager.addressLine2Placeholder,
            errorMessage: $viewModel.addressFormManager.addressLine2Error,
            editing: $viewModel.addressFormManager.editingAddressLine2,
            valid: $viewModel.addressFormManager.addressLine2Valid)
        .focused($textFieldInFocus, equals: .addressLine2)
        .onTapGesture {
            self.textFieldInFocus = .addressLine2
            viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
        }
    }

    private var cityView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.cityText,
            title: viewModel.addressFormManager.cityTitle,
            placeholder: viewModel.addressFormManager.cityPlaceholder,
            errorMessage: $viewModel.addressFormManager.cityError,
            editing: $viewModel.addressFormManager.editingCity,
            valid: $viewModel.addressFormManager.cityValid)
        .focused($textFieldInFocus, equals: .city)
        .onTapGesture {
            self.textFieldInFocus = .city
            viewModel.addressFormManager.setEditingTextField(focusedField: .city)
        }
    }

    private var stateView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.stateText,
            title: viewModel.addressFormManager.stateTitle,
            placeholder: viewModel.addressFormManager.statePlaceholder,
            errorMessage: $viewModel.addressFormManager.stateError,
            editing: $viewModel.addressFormManager.editingState,
            valid: $viewModel.addressFormManager.stateValid)
        .focused($textFieldInFocus, equals: .state)
        .onTapGesture {
            self.textFieldInFocus = .state
            viewModel.addressFormManager.setEditingTextField(focusedField: .state)
        }
    }

    private var postcodeView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.postcodeText,
            title: viewModel.addressFormManager.postcodeTitle,
            placeholder: viewModel.addressFormManager.postcodePlaceholder,
            errorMessage: $viewModel.addressFormManager.postcodeError,
            editing: $viewModel.addressFormManager.editingPostcode,
            valid: $viewModel.addressFormManager.postcodeValid)
        .focused($textFieldInFocus, equals: .postcode)
        .onTapGesture {
            self.textFieldInFocus = .postcode
            viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
        }
    }

    private var countryView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.countryText,
            title: viewModel.addressFormManager.countryTitle,
            placeholder: viewModel.addressFormManager.countryPlaceholder,
            errorMessage: $viewModel.addressFormManager.countryError,
            editing: $viewModel.addressFormManager.editingCountry,
            valid: $viewModel.addressFormManager.countryValid)
        .focused($textFieldInFocus, equals: .country)
        .onTapGesture {
            self.textFieldInFocus = .country
            viewModel.addressFormManager.setEditingTextField(focusedField: .country
            )
        }
    }

}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView()
    }
}
