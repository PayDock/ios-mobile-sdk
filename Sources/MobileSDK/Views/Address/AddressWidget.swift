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
    @State private var keyboardHeight: CGFloat = 0

    // MARK: - Initialisation

    public init(config: AddressWidgetConfig,
                appearance: AddressWidgetAppearance = AddressWidgetAppearance(),
                completion: @escaping (Address) -> Void) {
        _viewModel = StateObject(wrappedValue: AddressVM(config: config, completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: appearance.verticalSpacing) {
                        VStack(spacing: 8.0) {
                            nameAndLastNameView
                            autocompleteTextFieldView
                                .zIndex(100)
                                .padding(.bottom, viewModel.addressFormManager.showAddressSearchPopup ? 140 : 0)
                            if viewModel.addressFormManager.isAddressFormExpanded {
                                addressLine1View
                                addressLine2View
                                cityView
                                stateView
                                postcodeView
                                countryView
                                    .zIndex(100)
                                    .padding(.bottom, viewModel.addressFormManager.showCountrySearchPopup ? 140 : 0)
                            } else {
                                manualEntryButton
                            }
                        }

                        saveButton
                            .id("saveButton")
                        emptyFocusView
                    }
                    .animation(.easeInOut, value: viewModel.addressFormManager.showAddressSearchPopup)
                    .animation(.easeInOut, value: viewModel.addressFormManager.showCountrySearchPopup)
                    .padding(.horizontal, 16.0)
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 20 : 0)
                }
                .modifier(AddressAutoScrollModifier(textFieldInFocus: textFieldInFocus, proxy: proxy))
            }
            .onAppear {
                viewModel.updateAddress()
                observeKeyboard()
            }
        }
    }

    private func scrollToField(_ field: AddressFormManager.AddressFocusable, proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(field, anchor: .center)
            }
        }
    }

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = keyboardFrame.height
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = 0
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
                    returnKeyType: .next,
                    onTapGesture: {
                        self.textFieldInFocus = .firstName
                        viewModel.addressFormManager.setEditingTextField(focusedField: .firstName)
                    }, onSubmit: {
                        textFieldInFocus = .lastName
                        viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
                    }
                )
                .onConditionalKeyPress(key: .tab, action: {
                    textFieldInFocus = .lastName
                    viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
                })
                .focused($textFieldInFocus, equals: .firstName)
                .id(AddressFormManager.AddressFocusable.firstName)

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
                    returnKeyType: .next,
                    onTapGesture: {
                        self.textFieldInFocus = .lastName
                        viewModel.addressFormManager.setEditingTextField(focusedField: .lastName)
                    }, onSubmit: {
                        textFieldInFocus = .searchAddress
                        viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
                    }
                )
                .onConditionalKeyPress(key: .tab, action: {
                    textFieldInFocus = .searchAddress
                    viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
                })
                .focused($textFieldInFocus, equals: .lastName)
                .id(AddressFormManager.AddressFocusable.lastName)
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
                },
                returnKeyType: .next,
                onSubmit: {
                    let isFormExpanded = viewModel.addressFormManager.isAddressFormExpanded
                    textFieldInFocus = isFormExpanded ? .addressLine1 : nil

                    if isFormExpanded {
                        viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine1)
                    } else {
                        viewModel.addressFormManager.endEditing()
                    }
                }
            )
            .submitLabel(.next)
            .onConditionalKeyPress(key: .tab, action: {
                let isFormExpanded = viewModel.addressFormManager.isAddressFormExpanded
                textFieldInFocus = isFormExpanded ? .addressLine1 : .firstName
                viewModel.addressFormManager.setEditingTextField(focusedField: isFormExpanded ? .addressLine1 : .firstName)
            })
            .focused($textFieldInFocus, equals: .searchAddress)
            .id(AddressFormManager.AddressFocusable.searchAddress)
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
            .accessibilityHint("Saves address information.")
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
            returnKeyType: .next,
            onTapGesture: {
                self.textFieldInFocus = .addressLine1
                viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine1)
            }, onSubmit: {
                textFieldInFocus = .addressLine2
                viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
            }
        )
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .addressLine2
            viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
        })
        .focused($textFieldInFocus, equals: .addressLine1)
        .id(AddressFormManager.AddressFocusable.addressLine1)
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
            returnKeyType: .next,
            onTapGesture: {
                self.textFieldInFocus = .addressLine2
                viewModel.addressFormManager.setEditingTextField(focusedField: .addressLine2)
            }, onSubmit: {
                textFieldInFocus = .city
                viewModel.addressFormManager.setEditingTextField(focusedField: .city)
            }
        )
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .city
            viewModel.addressFormManager.setEditingTextField(focusedField: .city)
        })
        .focused($textFieldInFocus, equals: .addressLine2)
        .id(AddressFormManager.AddressFocusable.addressLine2)
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
            returnKeyType: .next,
            onTapGesture: {
                textFieldInFocus = .city
                viewModel.addressFormManager.setEditingTextField(focusedField: .city)
            }, onSubmit: {
                textFieldInFocus = .state
                viewModel.addressFormManager.setEditingTextField(focusedField: .state)
            }
        )
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .state
            viewModel.addressFormManager.setEditingTextField(focusedField: .state)
        })
        .focused($textFieldInFocus, equals: .city)
        .id(AddressFormManager.AddressFocusable.city)
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
            returnKeyType: .next,
            onTapGesture: {
                self.textFieldInFocus = .state
                viewModel.addressFormManager.setEditingTextField(focusedField: .state)
            }, onSubmit: {
                textFieldInFocus = .postcode
                viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
            }
        )
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .postcode
            viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
        })
        .focused($textFieldInFocus, equals: .state)
        .id(AddressFormManager.AddressFocusable.state)
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
            returnKeyType: .next,
            onTapGesture: {
                self.textFieldInFocus = .postcode
                viewModel.addressFormManager.setEditingTextField(focusedField: .postcode)
            }, onSubmit: {
                textFieldInFocus = .country
                viewModel.addressFormManager.setEditingTextField(focusedField: .country)
            }
        )
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .country
            viewModel.addressFormManager.setEditingTextField(focusedField: .country)
        })
        .focused($textFieldInFocus, equals: .postcode)
        .id(AddressFormManager.AddressFocusable.postcode)
    }

    private var countryView: some View {
        AutocompleteTextField(
            appearance: appearance.searchDropdown,
            text: viewModel.countrySearchBinding,
            title: viewModel.addressFormManager.countryTitle,
            placeholder: viewModel.addressFormManager.countryPlaceholder,
            errorMessage: $viewModel.addressFormManager.countryError,
            editing: $viewModel.addressFormManager.editingCountry,
            valid: $viewModel.addressFormManager.countryValid,
            showPopup: $viewModel.addressFormManager.showCountrySearchPopup,
            disabled: $viewModel.isDisabled,
            validationIconEnabled: true,
            options: $viewModel.countrySearchSuggestions,
            textContentType: .countryName,
            onSelection: {
                viewModel.handleTapOnCountryOptionAt(index: $0)
            },
            onTapGesture: {
                self.textFieldInFocus = .country
                viewModel.addressFormManager.setEditingTextField(focusedField: .country)
            }, onSubmit: {
                textFieldInFocus = nil
                viewModel.addressFormManager.endEditing()
            }
        )
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .firstName
            viewModel.addressFormManager.setEditingTextField(focusedField: .firstName)
        })
        .focused($textFieldInFocus, equals: .country)
        .id(AddressFormManager.AddressFocusable.country)
    }

    private var saveButton: some View {
        SDKButton(title: "Save",
                  style: .custom(CustomButtonStyle(appearance: appearance.actionButton, isDisabled: viewModel.isActionButtonDisabled()))) {
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
