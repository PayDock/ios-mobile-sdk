//
//  AddressWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

public struct AddressWidget: View {

    @StateObject var viewModel: AddressVM
    @FocusState private var textFieldInFocus: AddressFormManager.AddressFocusable?

    @State private var address: Address?

    // MARK: - Initialisation

    public init(address: Address? = nil,
                completion: @escaping (Result<Address, Error>) -> Void) {
        _viewModel = StateObject(wrappedValue: AddressVM(completion: completion))
        self.address = address
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: max(max(.spacing - 12, 0), 0)) {
                nameAndLastNameView
                autocompleteTextFieldView

                if viewModel.addressFormManager.isAddressFormExpanded {
                    addressLine1View
                    addressLine2View
                    cityView
                    stateView
                    postcodeView
                    countryView
                } else {
                    manualEntryButton
                }

                saveButton
            }
            .padding(.horizontal, .spacing)
        }
        .background(Color.backgroundColor)
        .onAppear {
            viewModel.addressFormManager.updateFormWith(address: address)
        }
        .onTapGesture {
            viewModel.addressFormManager.setEditingTextField(focusedField: nil)
        }
    }

    private var nameHeader: some View {
        HStack {
            Text("Name")
                .customFont(.body)
                .foregroundColor(.placeholderColor)
            Spacer()
        }
        .padding(.bottom, 20)
    }

    private var nameAndLastNameView: some View {
        VStack(spacing: 0) {
            nameHeader

            HStack(spacing: .spacing * 0.75) {
                OutlineTextField(
                    text: $viewModel.addressFormManager.firstNameText,
                    title: viewModel.addressFormManager.firstNameTitle,
                    placeholder: viewModel.addressFormManager.firstNamePlaceholder,
                    errorMessage: $viewModel.addressFormManager.firstNameError,
                    editing: $viewModel.addressFormManager.editingFirstName,
                    valid: $viewModel.addressFormManager.firstNameValid,
                    onTapGesture: {
                        self.textFieldInFocus = .firstName
                        viewModel.addressFormManager.setEditingTextField(focusedField: .firstName)
                    })
                .focused($textFieldInFocus, equals: .firstName)

                OutlineTextField(
                    text: $viewModel.addressFormManager.lastNameText,
                    title: viewModel.addressFormManager.lastNameTitle,
                    placeholder: viewModel.addressFormManager.lastNamePlaceholder,
                    errorMessage: $viewModel.addressFormManager.lastNameError,
                    editing: $viewModel.addressFormManager.editingLastName,
                    valid: $viewModel.addressFormManager.lastNameValid,
                    onTapGesture: {
                        self.textFieldInFocus = .lastName
                        viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
                    })
                .focused($textFieldInFocus, equals: .lastName)
            }
            .padding(.bottom, 20)
        }
    }

    private var findAnAddressHeader: some View {
        HStack {
            Text("Find an address")
                .customFont(.body)
                .font(.largeTitle)
                .foregroundColor(.placeholderColor)
            Spacer()
        }
        .padding(.bottom, 20)
    }
    

    private var autocompleteTextFieldView: some View {
        VStack(spacing: 0) {
            findAnAddressHeader

            AutocompleteTextField(
                text: viewModel.addressSearchBinding,
                title: viewModel.addressFormManager.addressSearchTitle,
                placeholder: viewModel.addressFormManager.addressSearchPlaceholder,
                errorMessage: $viewModel.addressFormManager.addressSearchError,
                editing: $viewModel.addressFormManager.editingAddressSearch,
                valid: $viewModel.addressFormManager.addressSearchValid,
                showPopup: $viewModel.addressFormManager.showAddressSearchPopup,
                options: $viewModel.addressSearchSuggestions,
                onSelection: {
                    viewModel.handleTapOnOptionAt(index: $0)
                }, onTapGesture: {
                    self.textFieldInFocus = .searchAddress
                    viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
                })
            .focused($textFieldInFocus, equals: .searchAddress)
            .padding(.bottom, 6)
        }
        .zIndex(1)
    }

    private var manualEntryButton: some View {
        HStack {
            Button {
                self.viewModel.addressFormManager.isAddressFormExpanded = true
            } label: {
                Text("Or enter address manually")
                    .customFont(.body3)
                    .foregroundColor(.primaryColor)
                    .underline()
            }
            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 16)
    }

    private var addressLine1View: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.addressLine1Text,
            title: viewModel.addressFormManager.addressLine1Title,
            placeholder: viewModel.addressFormManager.addressLine1Placeholder,
            errorMessage: $viewModel.addressFormManager.addressLine1Error,
            editing: $viewModel.addressFormManager.editingAddressLine1,
            valid: $viewModel.addressFormManager.addressLine1Valid,
            onTapGesture: {
                self.textFieldInFocus = .addressLine1
                viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine1)
            })
        .focused($textFieldInFocus, equals: .addressLine1)
    }

    private var addressLine2View: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.addressLine2Text,
            title: viewModel.addressFormManager.addressLine2Title,
            placeholder: viewModel.addressFormManager.addressLine2Placeholder,
            errorMessage: $viewModel.addressFormManager.addressLine2Error,
            editing: $viewModel.addressFormManager.editingAddressLine2,
            valid: $viewModel.addressFormManager.addressLine2Valid,
            onTapGesture: {
                self.textFieldInFocus = .addressLine2
                viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
            })
        .focused($textFieldInFocus, equals: .addressLine2)
    }

    private var cityView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.cityText,
            title: viewModel.addressFormManager.cityTitle,
            placeholder: viewModel.addressFormManager.cityPlaceholder,
            errorMessage: $viewModel.addressFormManager.cityError,
            editing: $viewModel.addressFormManager.editingCity,
            valid: $viewModel.addressFormManager.cityValid,
            onTapGesture: {
                self.textFieldInFocus = .city
                viewModel.addressFormManager.setEditingTextField(focusedField: .city)
            })
        .focused($textFieldInFocus, equals: .city)
    }

    private var stateView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.stateText,
            title: viewModel.addressFormManager.stateTitle,
            placeholder: viewModel.addressFormManager.statePlaceholder,
            errorMessage: $viewModel.addressFormManager.stateError,
            editing: $viewModel.addressFormManager.editingState,
            valid: $viewModel.addressFormManager.stateValid,
            onTapGesture: {
                self.textFieldInFocus = .state
                viewModel.addressFormManager.setEditingTextField(focusedField: .state)
            })
        .focused($textFieldInFocus, equals: .state)
    }

    private var postcodeView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.postcodeText,
            title: viewModel.addressFormManager.postcodeTitle,
            placeholder: viewModel.addressFormManager.postcodePlaceholder,
            errorMessage: $viewModel.addressFormManager.postcodeError,
            editing: $viewModel.addressFormManager.editingPostcode,
            valid: $viewModel.addressFormManager.postcodeValid,
            onTapGesture: {
                self.textFieldInFocus = .postcode
                viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
            })
        .focused($textFieldInFocus, equals: .postcode)
    }

    private var countryView: some View {
        OutlineTextField(
            text: $viewModel.addressFormManager.countryText,
            title: viewModel.addressFormManager.countryTitle,
            placeholder: viewModel.addressFormManager.countryPlaceholder,
            errorMessage: $viewModel.addressFormManager.countryError,
            editing: $viewModel.addressFormManager.editingCountry,
            valid: $viewModel.addressFormManager.countryValid, onTapGesture: {
                self.textFieldInFocus = .country
                viewModel.addressFormManager.setEditingTextField(focusedField: .country)
            })
        .focused($textFieldInFocus, equals: .country)
    }

    private var saveButton: some View {
        SDKButton(title: "Save", style: .fill(FillButtonStyle())) {
            viewModel.saveAddress()
        }
        .frame(height: 48)
        .padding(.vertical, 16)
        .customFont(.body)
    }

}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidget(completion: { _ in})
    }
}
