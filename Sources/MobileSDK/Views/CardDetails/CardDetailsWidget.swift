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
    @ScaledMetric private var cardIconWidth: CGFloat = 26.0
    @StateObject var viewModel: CardDetailsVM
    @FocusState private var textFieldInFocus: CardDetailsFormManager.CardDetailsFocusable?

    // MARK: - Initialisation

    public init(viewState: ViewState? = nil,
                config: CardDetailsWidgetConfig,
                appearance: CardDetailsWidgetAppearance = CardDetailsWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                eventDelegate: WidgetEventDelegate? = nil,
                completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        _viewModel = StateObject(wrappedValue: CardDetailsVM(
            viewState: viewState ?? ViewState(state: .none),
            config: config,
            appearance: appearance,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: completion))
    }

    // MARK: - View protocol properties

    public var body: some View {
        VStack(spacing: viewModel.appearance.verticalSpacing) {
            if let supportedSchemes = viewModel.config.schemeSupport.supportedSchemes, !supportedSchemes.isEmpty {
                getCardSchemeIconList(supportedSchemes: supportedSchemes)
            }

            VStack(spacing: viewModel.appearance.textFieldVerticalSpacing) {
                if viewModel.config.collectCardholderName {
                    cardholderNameTextField
                }
                cardNumberTextField
                expiryDateAndSecurityCodeLayout
            }

            if viewModel.config.allowSaveCard != nil {
                let text = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyText
                let url = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyURL
                if viewModel.config.allowSaveCard?.privacyPolicyConfig != nil &&
                    !text!.isEmpty &&
                    viewModel.isValidURLString(url) {
                    saveCardViewWithPrivacyPolicy
                } else {
                    saveCardViewWithoutPrivacyPolicy
                }
            }

            primaryButton
        }
        .padding(.horizontal, viewModel.appearance.horizontalSpacing)
    }

    private var cardholderNameTextField: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
            text: $viewModel.cardDetailsFormManager.cardholderNameText,
            title: viewModel.cardDetailsFormManager.cardholderNameTitle,
            placeholder: viewModel.cardDetailsFormManager.cardholderNamePlaceholder,
            errorMessage: $viewModel.cardDetailsFormManager.cardholderNameError,
            editing: $viewModel.cardDetailsFormManager.editingCardholderName,
            valid: $viewModel.cardDetailsFormManager.cardHolderNameValid,
            disabled: $viewModel.viewState.isDisabled,
            textContentType: getCreditCardName(),
            returnKeyType: .next,
            autocorrectionDisabled: true,
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
        .customToolbar(
            buttonTitle: "Next",
            font: UIFont(
                name: viewModel.appearance.toolbarButton.fonts.title.customFont.fontName,
                size: viewModel.appearance.toolbarButton.fonts.title.customFont.size),
            textColor: UIColor(viewModel.appearance.toolbarButton.colors.text)
        ) {
            textFieldInFocus = .cardNumber
            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
        }
        .focused($textFieldInFocus, equals: .cardholderName)
    }

    private var cardNumberTextField: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
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
                name: viewModel.appearance.toolbarButton.fonts.title.customFont.fontName,
                size: viewModel.appearance.toolbarButton.fonts.title.customFont.size),
            textColor: UIColor(viewModel.appearance.toolbarButton.colors.text)
        ) {
            textFieldInFocus = .expiryDate
            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
        }
        .focused($textFieldInFocus, equals: .cardNumber)
    }

    private var expiryDateTextField: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
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
                name: viewModel.appearance.toolbarButton.fonts.title.customFont.fontName,
                size: viewModel.appearance.toolbarButton.fonts.title.customFont.size),
            textColor: UIColor(viewModel.appearance.toolbarButton.colors.text)
        ) {
            textFieldInFocus = .securityCode
            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
        }
        .focused($textFieldInFocus, equals: .expiryDate)
    }

    private var securityCodeTextField: some View {
        OutlineTextField(
            appearance: viewModel.appearance.textField,
            text: $viewModel.cardDetailsFormManager.securityCodeText,
            title: viewModel.cardDetailsFormManager.securityCodeTitle,
            placeholder: viewModel.cardDetailsFormManager.securityCodePlaceholder,
            errorMessage: $viewModel.cardDetailsFormManager.securityCodeError,
            editing: $viewModel.cardDetailsFormManager.editingSecurityCode,
            valid: $viewModel.cardDetailsFormManager.securityCodeValid,
            disabled: $viewModel.viewState.isDisabled,
            textContentType: getCreditCardSecurityCode(),
            keyboardType: .numberPad,
            // Mask the security code input for PCI DSS compliance
            isSecureTextEntry: true,
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
                name: viewModel.appearance.toolbarButton.fonts.title.customFont.fontName,
                size: viewModel.appearance.toolbarButton.fonts.title.customFont.size),
            textColor: UIColor(viewModel.appearance.toolbarButton.colors.text)
        ) {
            textFieldInFocus = nil
            viewModel.cardDetailsFormManager.endEditing()
        }
        .focused($textFieldInFocus, equals: .securityCode)
    }

    private var expiryDateAndSecurityCodeLayout: some View {
        let layout = shouldAlignVertically() ?
            AnyLayout(VStackLayout(spacing: viewModel.appearance.verticalSpacing)) :
            AnyLayout(HStackLayout(alignment: .top, spacing: viewModel.appearance.horizontalSpacing))
        return layout {
            expiryDateTextField
            securityCodeTextField
        }
    }

    private var primaryButton: some View {
        SDKButton(title: viewModel.appearance.actionButton.text,
                  isLoading: viewModel.isLoading && viewModel.showLoaders,
                  style: .custom(
                    CustomButtonStyle(
                        appearance: viewModel.appearance.actionButton,
                        isDisabled: viewModel.isActionButtonDisabled())),
                  shouldTemplate: true) {
            textFieldInFocus = nil
            viewModel.cardDetailsFormManager.endEditing()
            viewModel.tokeniseCardDetails()
            viewModel.handleTokenisationTapAnalytics()
        }
                  .customPadding(viewModel.appearance.actionButton.dimensions.padding)
                  .accessibilityHint("Submits card details information.")
        }

    private var saveCardViewWithPrivacyPolicy: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.config.allowSaveCard?.consentText ?? "")
                    .applyAttributesWithScaledFont(viewModel.appearance.toggleText.text)
                    .customPadding(viewModel.appearance.toggleText.padding)

                let text = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyText ?? ""
                let url = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyURL ?? ""
                let link = "[\(text)](\(url))"
                Text(.init(link))
                    .applyAttributesWithScaledFont(viewModel.appearance.linkText.text)
                    .customPadding(viewModel.appearance.linkText.padding)
                    .accentColor(viewModel.appearance.linkText.text.textColor)
                    .disabled(viewModel.viewState.isDisabled)
                    .frame(minHeight: 24.0)
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.handleLinkTapAnalytics(url: url)
                    })
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle(isOn: $viewModel.policyAccepted) {}
                .conditionalToggleStyle(appearance: viewModel.appearance.toggle)
                .disabled(viewModel.viewState.isDisabled)
                .accessibilityLabel(viewModel.config.allowSaveCard?.consentText ?? "")
                .fixedSize()
        }
    }

    private var saveCardViewWithoutPrivacyPolicy: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(viewModel.config.allowSaveCard?.consentText ?? "")
                .applyAttributesWithScaledFont(viewModel.appearance.toggleText.text)
                .customPadding(viewModel.appearance.toggleText.padding)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle(isOn: $viewModel.policyAccepted) {}
                .conditionalToggleStyle(appearance: viewModel.appearance.toggle)
                .disabled(viewModel.viewState.isDisabled)
                .accessibilityLabel(viewModel.config.allowSaveCard?.consentText ?? "")
                .fixedSize()
        }
    }

    private func getCardSchemeIconList(supportedSchemes: Set<CardScheme>) -> some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: cardIconWidth + 4), spacing: 0)
        ], spacing: 8.0) {
            ForEach(CardScheme.sortedArray(from: supportedSchemes), id: \.self) { scheme in
                viewModel.getSchemeIcon(for: scheme)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardIconWidth)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(
            "Supported card schemes: " +
            CardScheme.sortedArray(from: supportedSchemes)
                .map(\.voiceoverName)
                .joined(separator: ", ")
        )
        .accessibilityRespondsToUserInteraction(false)
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Preview

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidget(config: CardDetailsWidgetConfig(gatewayId: "", accessToken: ""), completion: { _ in })
            .previewLayout(.sizeThatFits)
    }
}
