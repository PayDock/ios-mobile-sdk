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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Initialisation

    public init(config: AddressWidgetConfig,
                appearance: AddressWidgetAppearance = AddressWidgetAppearance(),
                eventDelegate: WidgetEventDelegate? = nil,
                completion: @escaping (Address) -> Void) {
        _viewModel = StateObject(
            wrappedValue:
                AddressVM(
                    config: config,
                    appearance: appearance,
                    eventDelegate: eventDelegate,
                    completion: completion))
    }

    public var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: viewModel.appearance.verticalSpacing) {
                        VStack(spacing: viewModel.appearance.textFieldVerticalSpacing) {
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
                        }

                        saveButton
                            .id("saveButton")
                    }
                    .animation(.easeInOut(duration: 0.25), value: viewModel.addressFormManager.showAddressSearchPopup)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.countrySearchSuggestions)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.addressSearchSuggestions)
                    .padding(.horizontal, viewModel.appearance.horizontalSpacing)
                }
                .modifier(AddressAutoScrollModifier(textFieldInFocus: textFieldInFocus, proxy: proxy))
            }
            .onAppear {
                viewModel.updateAddress()
            }
            .onChange(of: dynamicTypeSize) { _ in
                viewModel.addressFormManager.endEditing()
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

    private var nameHeader: some View {
        HStack {
            Text("Name")
                .font(viewModel.appearance.title.text.customFont.scaledFont)
                .foregroundColor(viewModel.appearance.title.text.textColor)
                .accessibilityAddTraits(.isHeader)
            Spacer()
        }
        .customPadding(viewModel.appearance.title.padding)
    }

    private var nameAndLastNameView: some View {
        VStack(spacing: viewModel.appearance.verticalSpacing) {
            nameHeader

            let layout = shouldAlignVertically() ?
            AnyLayout(VStackLayout(spacing: viewModel.appearance.verticalSpacing)) :
            AnyLayout(HStackLayout(spacing: viewModel.appearance.horizontalSpacing))

            layout {
                OutlineTextField(
                    appearance: viewModel.appearance.textField,
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
                .focused($textFieldInFocus, equals: .firstName)
                .id(AddressFormManager.AddressFocusable.firstName)

                OutlineTextField(
                    appearance: viewModel.appearance.textField,
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
                .focused($textFieldInFocus, equals: .lastName)
                .id(AddressFormManager.AddressFocusable.lastName)
            }
        }
    }

    private var findAnAddressHeader: some View {
        HStack {
            Text("Find an address")
                .font(viewModel.appearance.title.text.customFont.scaledFont)
                .foregroundColor(viewModel.appearance.title.text.textColor)
                .accessibilityAddTraits(.isHeader)
            Spacer()
        }
        .customPadding(viewModel.appearance.title.padding)
    }

    private var autocompleteTextFieldView: some View {
        VStack(spacing: viewModel.appearance.verticalSpacing) {
            findAnAddressHeader

            AutocompleteTextField(
                appearance: viewModel.appearance.searchDropdown,
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
            .focused($textFieldInFocus, equals: .searchAddress)
            .id(AddressFormManager.AddressFocusable.searchAddress)
        }
    }

    private var manualEntryButton: some View {
        HStack {
            SDKButton(
                title: "Or enter address manually",
                style: .custom(CustomButtonStyle(appearance: viewModel.appearance.expandSectionButton)),
                isLeftAligned: true,
                contentPadding: 0.0,
                action: {
                    viewModel.expandAddressForm()
                    viewModel.handleExpandAddressFormTapAnalytics()
                })
            .accessibilityHint("Saves address information.")
            Spacer()
        }
    }

    private var addressLine1View: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
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
        .focused($textFieldInFocus, equals: .addressLine1)
        .id(AddressFormManager.AddressFocusable.addressLine1)
    }

    private var addressLine2View: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
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
        .focused($textFieldInFocus, equals: .addressLine2)
        .id(AddressFormManager.AddressFocusable.addressLine2)
    }

    private var cityView: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
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
        .focused($textFieldInFocus, equals: .city)
        .id(AddressFormManager.AddressFocusable.city)
    }

    private var stateView: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
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
        .focused($textFieldInFocus, equals: .state)
        .id(AddressFormManager.AddressFocusable.state)
    }

    private var postcodeView: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
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
        .focused($textFieldInFocus, equals: .postcode)
        .id(AddressFormManager.AddressFocusable.postcode)
    }

    private var countryView: some View {
        AutocompleteTextField(
            appearance: viewModel.appearance.searchDropdown,
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
        .focused($textFieldInFocus, equals: .country)
        .id(AddressFormManager.AddressFocusable.country)
        .animation(.easeInOut(duration: 0.25), value: viewModel.addressFormManager.showCountrySearchPopup)
        .animation(.easeInOut(duration: 0.25), value: viewModel.countrySearchSuggestions.count)
    }

    private var saveButton: some View {
        SDKButton(
            title: viewModel.appearance.actionButton.text,
            style: .custom(
                CustomButtonStyle(
                    appearance: viewModel.appearance.actionButton,
                    isDisabled: viewModel.isActionButtonDisabled())),
            shouldTemplate: true) {
                viewModel.saveAddress()
                viewModel.handleSaveAddresTapAnalytics()
            }
            .customPadding(viewModel.appearance.actionButton.dimensions.padding)
            .font(viewModel.appearance.actionButton.fonts.title.customFont.scaledFont)
    }

    private func shouldAlignVertically() -> Bool {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge: return false
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: return true
        @unknown default: return false
        }
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidget(config: .init(), completion: { _ in})
    }
}
