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
    @FocusState private var isViewFocused: Bool
    @State var appearance: AddressWidgetAppearance

    // MARK: - Initialisation

    public init(config: AddressWidgetConfig,
                appearance: AddressWidgetAppearance = AddressWidgetAppearance(),
                completion: @escaping (Address) -> Void) {
        _viewModel = StateObject(wrappedValue: AddressVM(config: config, completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: appearance.verticalSpacing) {
                    VStack(spacing: 8.0) {
                        nameAndLastNameView
                        autocompleteTextFieldView
                            .zIndex(100)
                            .padding(.bottom, viewModel.addressFormManager.showAddressSearchPopup ? 120 : 0)
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
                    }

                    saveButton
                    emptyFocusView
                }
                .animation(.easeInOut, value: viewModel.addressFormManager.showAddressSearchPopup)
                .padding(.horizontal, 16.0)
            }
            .onAppear {
                viewModel.updateAddress()
            }
        }
    }

    private var nameHeader: some View {
        HStack {
            Text("Name")
                .font(appearance.title.text.customFont.font)
                .foregroundColor(appearance.title.text.textColor)
                .accessibilityAddTraits(.isHeader)
            Spacer()
        }
        .customPadding(appearance.title.padding)
    }

    private var nameAndLastNameView: some View {
        VStack(spacing: 0) {
            nameHeader

            HStack(spacing: appearance.horizontalSpacing) {
                OutlineTextField(
                    appearance: appearance.textField,
                    text: $viewModel.addressFormManager.firstNameText,
                    title: viewModel.addressFormManager.firstNameTitle,
                    placeholder: viewModel.addressFormManager.firstNamePlaceholder,
                    errorMessage: $viewModel.addressFormManager.firstNameError,
                    editing: $viewModel.addressFormManager.editingFirstName,
                    valid: $viewModel.addressFormManager.firstNameValid,
                    disabled: $viewModel.isDisabled,
                    textContentType: .givenName,
                    onTapGesture: {
                        self.textFieldInFocus = .firstName
                        viewModel.addressFormManager.setEditingTextField(focusedField: .firstName)
                    }
                )
                .submitLabel(.next)
                .onSubmit {
                    textFieldInFocus = .lastName
                    viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
                }
                .onConditionalKeyPress(key: .tab, action: {
                    textFieldInFocus = .lastName
                    viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
                })
                .focused($textFieldInFocus, equals: .firstName)

                OutlineTextField(
                    appearance: appearance.textField,
                    text: $viewModel.addressFormManager.lastNameText,
                    title: viewModel.addressFormManager.lastNameTitle,
                    placeholder: viewModel.addressFormManager.lastNamePlaceholder,
                    errorMessage: $viewModel.addressFormManager.lastNameError,
                    editing: $viewModel.addressFormManager.editingLastName,
                    valid: $viewModel.addressFormManager.lastNameValid,
                    disabled: $viewModel.isDisabled,
                    textContentType: .familyName,
                    onTapGesture: {
                        self.textFieldInFocus = .lastName
                        viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
                    }
                )
                .submitLabel(.next)
                .onSubmit {
                    textFieldInFocus = .searchAddress
                    viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
                }
                .onConditionalKeyPress(key: .tab, action: {
                    textFieldInFocus = .searchAddress
                    viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
                })
                .focused($textFieldInFocus, equals: .lastName)
            }
        }
    }

    private var findAnAddressHeader: some View {
        HStack {
            Text("Find an address")
                .font(appearance.title.text.customFont.font)
                .foregroundColor(appearance.title.text.textColor)
                .accessibilityAddTraits(.isHeader)
            Spacer()
        }
        .customPadding(appearance.title.padding)
    }
    

    private var autocompleteTextFieldView: some View {
        VStack(spacing: 0) {
            findAnAddressHeader

            AutocompleteTextField(
                appearance: appearance.searchDropdown,
                text: viewModel.addressSearchBinding,
                title: viewModel.addressFormManager.addressSearchTitle,
                placeholder: viewModel.addressFormManager.addressSearchPlaceholder,
                errorMessage: $viewModel.addressFormManager.addressSearchError,
                editing: $viewModel.addressFormManager.editingAddressSearch,
                valid: $viewModel.addressFormManager.addressSearchValid,
                showPopup: $viewModel.addressFormManager.showAddressSearchPopup,
                disabled: $viewModel.isDisabled,
                options: $viewModel.addressSearchSuggestions,
                textContentType: .location,
                onSelection: {
                    viewModel.handleTapOnOptionAt(index: $0)
                },
                onTapGesture: {
                    self.textFieldInFocus = .searchAddress
                    viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
                }
            )
            .submitLabel(.next)
            .onSubmit {
                let isFormExpanded = viewModel.addressFormManager.isAddressFormExpanded
                textFieldInFocus = isFormExpanded ? .addressLine1 : nil
                
                if isFormExpanded {
                    viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine1)
                } else {
                    viewModel.addressFormManager.endEditing()
                }
            }
            .onConditionalKeyPress(key: .tab, action: {
                let isFormExpanded = viewModel.addressFormManager.isAddressFormExpanded
                textFieldInFocus = isFormExpanded ? .addressLine1 : .firstName
                viewModel.addressFormManager.setEditingTextField(focusedField: isFormExpanded ? .addressLine1 : .firstName)
            })
            .focused($textFieldInFocus, equals: .searchAddress)
            .padding(.bottom, 6)
        }
    }

    private var manualEntryButton: some View {
        HStack {
            SDKButton(
                title: "Or enter address manually",
                style: .custom(CustomButtonStyle(appearance: appearance.expandSectionButton)),
                isLeftAligned: true,
                action: {
                    self.viewModel.addressFormManager.isAddressFormExpanded = true
                })
            Spacer()
        }
    }

    private var addressLine1View: some View {
        OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.addressFormManager.addressLine1Text,
            title: viewModel.addressFormManager.addressLine1Title,
            placeholder: viewModel.addressFormManager.addressLine1Placeholder,
            errorMessage: $viewModel.addressFormManager.addressLine1Error,
            editing: $viewModel.addressFormManager.editingAddressLine1,
            valid: $viewModel.addressFormManager.addressLine1Valid,
            disabled: $viewModel.isDisabled,
            textContentType: .streetAddressLine1,
            onTapGesture: {
                self.textFieldInFocus = .addressLine1
                viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine1)
            }
        )
        .submitLabel(.next)
        .onSubmit {
            textFieldInFocus = .addressLine2
            viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .addressLine2
            viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
        })
        .focused($textFieldInFocus, equals: .addressLine1)
    }

    private var addressLine2View: some View {
        OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.addressFormManager.addressLine2Text,
            title: viewModel.addressFormManager.addressLine2Title,
            placeholder: viewModel.addressFormManager.addressLine2Placeholder,
            errorMessage: $viewModel.addressFormManager.addressLine2Error,
            editing: $viewModel.addressFormManager.editingAddressLine2,
            valid: $viewModel.addressFormManager.addressLine2Valid,
            disabled: $viewModel.isDisabled,
            textContentType: .streetAddressLine2,
            onTapGesture: {
                self.textFieldInFocus = .addressLine2
                viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
            }
        )
        .submitLabel(.next)
        .onSubmit {
            textFieldInFocus = .city
            viewModel.addressFormManager.setEditingTextField(focusedField: .city)
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .city
            viewModel.addressFormManager.setEditingTextField(focusedField: .city)
        })
        .focused($textFieldInFocus, equals: .addressLine2)
    }

    private var cityView: some View {
        OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.addressFormManager.cityText,
            title: viewModel.addressFormManager.cityTitle,
            placeholder: viewModel.addressFormManager.cityPlaceholder,
            errorMessage: $viewModel.addressFormManager.cityError,
            editing: $viewModel.addressFormManager.editingCity,
            valid: $viewModel.addressFormManager.cityValid,
            disabled: $viewModel.isDisabled,
            textContentType: .addressCity,
            onTapGesture: {
                self.textFieldInFocus = .city
                viewModel.addressFormManager.setEditingTextField(focusedField: .city)
            }
        )
        .submitLabel(.next)
        .onSubmit {
            textFieldInFocus = .state
            viewModel.addressFormManager.setEditingTextField(focusedField: .state)
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .state
            viewModel.addressFormManager.setEditingTextField(focusedField: .state)
        })
        .focused($textFieldInFocus, equals: .city)
    }

    private var stateView: some View {
        OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.addressFormManager.stateText,
            title: viewModel.addressFormManager.stateTitle,
            placeholder: viewModel.addressFormManager.statePlaceholder,
            errorMessage: $viewModel.addressFormManager.stateError,
            editing: $viewModel.addressFormManager.editingState,
            valid: $viewModel.addressFormManager.stateValid,
            disabled: $viewModel.isDisabled,
            textContentType: .addressState,
            onTapGesture: {
                self.textFieldInFocus = .state
                viewModel.addressFormManager.setEditingTextField(focusedField: .state)
            }
        )
        .submitLabel(.next)
        .onSubmit {
            textFieldInFocus = .postcode
            viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .postcode
            viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
        })
        .focused($textFieldInFocus, equals: .state)
    }

    private var postcodeView: some View {
        OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.addressFormManager.postcodeText,
            title: viewModel.addressFormManager.postcodeTitle,
            placeholder: viewModel.addressFormManager.postcodePlaceholder,
            errorMessage: $viewModel.addressFormManager.postcodeError,
            editing: $viewModel.addressFormManager.editingPostcode,
            valid: $viewModel.addressFormManager.postcodeValid,
            disabled: $viewModel.isDisabled,
            textContentType: .postalCode,
            onTapGesture: {
                self.textFieldInFocus = .postcode
                viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
            }
        )
        .submitLabel(.next)
        .onSubmit {
            textFieldInFocus = .country
            viewModel.addressFormManager.setEditingTextField(focusedField: .country)
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .country
            viewModel.addressFormManager.setEditingTextField(focusedField: .country)
        })
        .focused($textFieldInFocus, equals: .postcode)
    }

    private var countryView: some View {
        OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.addressFormManager.countryText,
            title: viewModel.addressFormManager.countryTitle,
            placeholder: viewModel.addressFormManager.countryPlaceholder,
            errorMessage: $viewModel.addressFormManager.countryError,
            editing: $viewModel.addressFormManager.editingCountry,
            valid: $viewModel.addressFormManager.countryValid,
            disabled: $viewModel.isDisabled,
            textContentType: .countryName,
            onTapGesture: {
                self.textFieldInFocus = .country
                viewModel.addressFormManager.setEditingTextField(focusedField: .country)
            }
        )
        .submitLabel(.done)
        .onSubmit {
            textFieldInFocus = nil
            viewModel.addressFormManager.endEditing()
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .firstName
            viewModel.addressFormManager.setEditingTextField(focusedField: .firstName)
        })
        .focused($textFieldInFocus, equals: .country)
    }

    private var saveButton: some View {
        SDKButton(title: "Save", style: .custom(CustomButtonStyle(appearance: appearance.actionButton, isDisabled: viewModel.isDisabled))) {
            viewModel.saveAddress()
        }
        .customPadding(appearance.actionButton.dimensions.padding)
        .font(appearance.actionButton.fonts.title.customFont.font)
    }
    
    private var emptyFocusView: some View {
        VStack {}
            .conditionalFocusable()
            .focused($isViewFocused)
            .onConditionalKeyPress(key: .tab, action: {
                textFieldInFocus = .firstName
                viewModel.addressFormManager.setEditingTextField(focusedField: .firstName)
            })
            .onAppear {
                isViewFocused = true
            }
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidget(config: .init(), completion: { _ in})
    }
}
