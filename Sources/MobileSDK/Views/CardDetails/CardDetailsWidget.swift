//
//  CardDetailsWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

public struct CardDetailsWidget: View {

    // MARK: - Properties
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) var sizeCategory
    @StateObject var viewModel: CardDetailsVM
    @State var appearance: CardDetailsWidgetAppearance
    @FocusState private var textFieldInFocus: CardDetailsFormManager.CardDetailsFocusable?
    @FocusState private var isViewFocused: Bool

    // MARK: - Initialisation

    public init(viewState: ViewState? = nil,
                config: CardDetailsWidgetConfig,
                appearance: CardDetailsWidgetAppearance = CardDetailsWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        _viewModel = StateObject(wrappedValue: CardDetailsVM(
            viewState: viewState ?? ViewState(state: .none),
            config: config,
            loadingDelegate: loadingDelegate,
            completion: completion))
        self.appearance = appearance
    }

    // MARK: - View protocol properties

    public var body: some View {
        VStack(spacing: appearance.verticalSpacing) {
            if viewModel.config.showCardTitle {
                HStack {
                    Text("Card information")
                        .font(appearance.title.text.customFont.font)
                        .foregroundColor(appearance.title.text.textColor)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }
                .customPadding(appearance.title.padding)
            }

            if let supportedSchemes = viewModel.config.schemeSupport.supportedSchemes, !supportedSchemes.isEmpty {
                HStack(spacing: 7) {
                    ForEach(CardScheme.sortedArray(from: supportedSchemes), id: \.self) { scheme in
                        getSchemeIcon(for: scheme)
                            .resizable()
                            .frame(width: 26, height: 20)
                            .scaledToFit()
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(
                    "Supported card schemes: " +
                    CardScheme.sortedArray(from: supportedSchemes)
                        .map(\.voiceoverName)
                        .joined(separator: ", ")
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
            }

            VStack(spacing: 8) {
                if viewModel.config.collectCardholderName {
                    OutlineTextField(
                        appearance: appearance.textField,
                        text: $viewModel.cardDetailsFormManager.cardholderNameText,
                        title: viewModel.cardDetailsFormManager.cardholderNameTitle,
                        placeholder: viewModel.cardDetailsFormManager.cardholderNamePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.cardholderNameError,
                        editing: $viewModel.cardDetailsFormManager.editingCardholderName,
                        valid: $viewModel.cardDetailsFormManager.cardHolderNameValid,
                        disabled: $viewModel.viewState.isDisabled,
                        textContentType: getCreditCardName(),
                        returnKeyType: .next,
                        onTapGesture: {
                            if !viewModel.viewState.isDisabled {
                                self.textFieldInFocus = .cardholderName
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardholderName)
                            }
                        }, onSubmit: {
                            textFieldInFocus = .cardNumber
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                        }
                    )
                    .onConditionalKeyPress(key: .tab, action: {
                        textFieldInFocus = .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                    })
                    .focused($textFieldInFocus, equals: .cardholderName)
                }

                OutlineTextField(
                    appearance: appearance.textField,
                    text: $viewModel.cardDetailsFormManager.cardNumberText,
                    title: viewModel.cardDetailsFormManager.cardNumberTitle,
                    placeholder: viewModel.cardDetailsFormManager.cardNumberPlaceholder,
                    errorMessage: $viewModel.cardDetailsFormManager.cardNumberError,
                    leftImage: $viewModel.cardDetailsFormManager.cardImage,
                    editing: $viewModel.cardDetailsFormManager.editingCardNumber,
                    valid: $viewModel.cardDetailsFormManager.cardNumberValid,
                    disabled: $viewModel.viewState.isDisabled,
                    textContentType: .creditCardNumber,
                    keyboardType: .numberPad,
                    onTapGesture: {
                        if !viewModel.viewState.isDisabled {
                            self.textFieldInFocus = .cardNumber
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                        }
                    },
                    onTextChange: { text, cursorPosition in
                        return viewModel.cardDetailsFormManager.formatCardNumber(updatedText: text, cursorPosition: cursorPosition)
                    }
                )
                .customToolbar(
                    buttonTitle: "Next",
                    font: UIFont(
                        name: appearance.toolbarButton.fonts.title.customFont.name,
                        size: appearance.toolbarButton.fonts.title.customFont.size),
                    textColor: UIColor(appearance.toolbarButton.colors.text)
                ) {
                    textFieldInFocus = .expiryDate
                    viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                }
                .onConditionalKeyPress(key: .tab, action: {
                    textFieldInFocus = .expiryDate
                    viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                })
                .focused($textFieldInFocus, equals: .cardNumber)

                let layout = shouldAlignVertically() ?
                AnyLayout(VStackLayout(spacing: appearance.verticalSpacing)) :
                AnyLayout(HStackLayout(alignment: .top, spacing: appearance.horizontalSpacing))
                layout {
                    OutlineTextField(
                        appearance: appearance.textField,
                        text: $viewModel.cardDetailsFormManager.expiryDateText,
                        title: viewModel.cardDetailsFormManager.expiryDateTitle,
                        placeholder: viewModel.cardDetailsFormManager.expiryDatePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.expiryDateError,
                        editing: $viewModel.cardDetailsFormManager.editingExpiryDate,
                        valid: $viewModel.cardDetailsFormManager.expiryDateValid,
                        disabled: $viewModel.viewState.isDisabled,
                        textContentType: getCreditCardExpiryDate(),
                        keyboardType: .numberPad,
                        onTapGesture: {
                            if !viewModel.viewState.isDisabled {
                                self.textFieldInFocus = .expiryDate
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                            }
                        },
                        onTextChange: { text, cursorPosition in
                            return viewModel.cardDetailsFormManager.formatExpiryDate(updatedText: text, cursorPosition: cursorPosition)
                        })
                    .keyboardType(.numberPad)
                    .customToolbar(
                        buttonTitle: "Next",
                        font: UIFont(
                            name: appearance.toolbarButton.fonts.title.customFont.name,
                            size: appearance.toolbarButton.fonts.title.customFont.size),
                        textColor: UIColor(appearance.toolbarButton.colors.text)
                    ) {
                        textFieldInFocus = .securityCode
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                    }
                    .onConditionalKeyPress(key: .tab, action: {
                        textFieldInFocus = .securityCode
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                    })
                    .focused($textFieldInFocus, equals: .expiryDate)

                    OutlineTextField(
                        appearance: appearance.textField,
                        text: $viewModel.cardDetailsFormManager.securityCodeText,
                        title: viewModel.cardDetailsFormManager.securityCodeTitle,
                        placeholder: viewModel.cardDetailsFormManager.securityCodePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.securityCodeError,
                        editing: $viewModel.cardDetailsFormManager.editingSecurityCode,
                        valid: $viewModel.cardDetailsFormManager.securityCodeValid,
                        disabled: $viewModel.viewState.isDisabled,
                        textContentType: getCreditCardSecurityCode(),
                        keyboardType: .numberPad,
                        onTapGesture: {
                            if !viewModel.viewState.isDisabled {
                                self.textFieldInFocus = .securityCode
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                            }
                        },
                        onTextChange: { text, cursorPosition in
                            return viewModel.cardDetailsFormManager.formatSecurityCode(updatedText: text, cursorPosition: cursorPosition)
                        })
                    .keyboardType(.numberPad)
                    .customToolbar(
                        buttonTitle: "Done",
                        font: UIFont(
                            name: appearance.toolbarButton.fonts.title.customFont.name,
                            size: appearance.toolbarButton.fonts.title.customFont.size),
                        textColor: UIColor(appearance.toolbarButton.colors.text)
                    ) {
                        textFieldInFocus = nil
                        viewModel.cardDetailsFormManager.endEditing()
                    }
                    .onConditionalKeyPress(key: .tab, action: {
                        let collectCardholderName = viewModel.config.collectCardholderName
                        textFieldInFocus = collectCardholderName ? .cardholderName : .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(
                            focusedField: collectCardholderName ? .cardholderName : .cardNumber)
                    })
                    .focused($textFieldInFocus, equals: .securityCode)
                }
            }

            if viewModel.config.allowSaveCard != nil {
                privacyView
            }

            SDKButton(title: viewModel.config.actionText,
                      isLoading: viewModel.isLoading && viewModel.showLoaders,
                      style: .custom(CustomButtonStyle(appearance: appearance.actionButton, isDisabled: viewModel.isActionButtonDisabled()))
            ) {
                textFieldInFocus = nil
                viewModel.cardDetailsFormManager.endEditing()
                viewModel.tokeniseCardDetails()
            }
            .customPadding(appearance.actionButton.dimensions.padding)
            .accessibilityHint("Submits card details information.")

            emptyFocusView
        }
        .padding(.horizontal, appearance.horizontalSpacing)
    }

    private var privacyView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.config.allowSaveCard?.consentText ?? "")
                    .applyAttributes(appearance.toggleText.text)
                    .customPadding(appearance.toggleText.padding)

                let text = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyText ?? ""
                let url = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyURL ?? ""
                let link = "[\(text)](\(url))"
                Text(.init(link))

                    .applyAttributes(appearance.linkText.text)
                    .customPadding(appearance.linkText.padding)
                    .accentColor(appearance.linkText.text.textColor)
                    .disabled(viewModel.viewState.isDisabled)
                    .frame(minHeight: 24.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard let url = URL(string: url) else { return }
                        openURL(url)
                    }
            }
            Spacer()
            Toggle(isOn: $viewModel.policyAccepted) {}
                .tint(appearance.toggle.activeColor)
                .frame(width: 64, height: 44)
                .disabled(viewModel.viewState.isDisabled)
                .accessibilityLabel(viewModel.config.allowSaveCard?.consentText ?? "")
        }
    }

    private var emptyFocusView: some View {
        VStack {}
            .conditionalFocusable()
            .focused($isViewFocused)
            .onConditionalKeyPress(key: .tab, action: {
                let collectCardholderName = viewModel.config.collectCardholderName
                textFieldInFocus = collectCardholderName ? .cardholderName : .cardNumber
                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: collectCardholderName ? .cardholderName : .cardNumber)
            })
            .onAppear {
                isViewFocused = true
            }
    }

    private func getSchemeIcon(for scheme: CardScheme) -> Image {
        switch scheme {
        case .amex: Image("american-express", bundle: Bundle.module)
        case .ausbc: Image("australian-commonwealth-bank", bundle: Bundle.module)
        case .diners: Image("diners", bundle: Bundle.module)
        case .discover: Image("discover", bundle: Bundle.module)
        case .japcb: Image("jcb", bundle: Bundle.module)
        case .mastercard: Image("mastercard", bundle: Bundle.module)
        case .solo: Image("solo", bundle: Bundle.module)
        case .visa: Image("visa", bundle: Bundle.module)
        }
    }

    private func shouldAlignVertically() -> Bool {
        switch sizeCategory {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge: return false
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: return true
        @unknown default: return false
        }
    }

    // MARK: - Autofill

    private func getCreditCardName() -> UITextContentType {
        if #available(iOS 17.0, *) {
            return .creditCardName
        } else {
            return .name
        }
    }

    private func getCreditCardExpiryDate() -> UITextContentType? {
        if #available(iOS 17.0, *) {
            return .creditCardExpiration
        } else {
            return .none
        }
    }

    private func getCreditCardSecurityCode() -> UITextContentType? {
        if #available(iOS 17.0, *) {
            return .creditCardSecurityCode
        } else {
            return .none
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidget(config: CardDetailsWidgetConfig(gatewayId: "", accessToken: ""), completion: { _ in })
            .previewLayout(.sizeThatFits)
    }
}
