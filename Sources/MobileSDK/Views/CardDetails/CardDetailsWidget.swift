//
//  CardDetailsWidget.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

public struct CardDetailsWidget: View {

    // MARK: - Properties
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) var sizeCategory
    @ScaledMetric private var cardIconWidth: CGFloat = 26.0
    @StateObject var viewModel: CardDetailsVM
    @FocusState private var textFieldInFocus: CardDetailsFocusable?
    @AccessibilityFocusState private var voiceOverFocusedField: CardDetailsFocusable?
    @State private var announcing: Bool = false

    // Callback for scroll requests
    private let onScrollToField: ((CardDetailsFocusable) -> Void)?

    // MARK: - Initialisation

    public init(viewState: ViewState? = nil,
                config: CardDetailsWidgetConfig,
                appearance: CardDetailsWidgetAppearance = CardDetailsWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                eventDelegate: WidgetEventDelegate? = nil,
                onScrollToField: ((CardDetailsFocusable) -> Void)? = nil,
                completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        self.onScrollToField = onScrollToField
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
                        .id(CardDetailsFocusable.cardholderName)
                }
                cardNumberTextField
                    .id(CardDetailsFocusable.cardNumber)
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
            appearance: viewModel.appearance.cardNameTextField,
            text: $viewModel.cardDetailsFormManager.cardholderNameText,
            title: viewModel.cardDetailsFormManager.cardholderNameTitle,
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
        .onChange(of: viewModel.cardDetailsFormManager.cardholderNameError) { newValue in
            if !newValue.isEmpty && !announcing {
                announceFieldError(newValue)
            }
        }
        .focused($textFieldInFocus, equals: .cardholderName)
        .accessibilityFocused($voiceOverFocusedField, equals: .cardholderName)
    }

    private var cardNumberTextField: some View {
        OutlineTextField(
            appearance: viewModel.appearance.cardNumberTextField,
            text: $viewModel.cardDetailsFormManager.cardNumberText,
            title: viewModel.cardDetailsFormManager.cardNumberTitle,
            errorMessage: $viewModel.cardDetailsFormManager.cardNumberError,
            leftImage: $viewModel.cardDetailsFormManager.cardImage,
            editing: $viewModel.cardDetailsFormManager.editingCardNumber,
            valid: $viewModel.cardDetailsFormManager.cardNumberValid,
            disabled: $viewModel.viewState.isDisabled,
            textContentType: .creditCardNumber,
            keyboardType: .numberPad,
            accessibilityValue: String(viewModel.cardDetailsFormManager.cardNumberText.filter { $0.isNumber }),
            spellOutValue: true,
            leftImageAccessibilityLabel: $viewModel.cardDetailsFormManager.cardImageAccessibilityLabel,
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
        .onChange(of: viewModel.cardDetailsFormManager.cardNumberError) { newValue in
            if !newValue.isEmpty && !announcing {
                announceFieldError(newValue)
            }
        }
        .focused($textFieldInFocus, equals: .cardNumber)
        .accessibilityFocused($voiceOverFocusedField, equals: .cardNumber)
    }

    private var expiryDateTextField: some View {
        OutlineTextField(
            appearance: viewModel.appearance.cardExpiryTextField,
            text: $viewModel.cardDetailsFormManager.expiryDateText,
            title: viewModel.cardDetailsFormManager.expiryDateTitle,
            errorMessage: $viewModel.cardDetailsFormManager.expiryDateError,
            editing: $viewModel.cardDetailsFormManager.editingExpiryDate,
            valid: $viewModel.cardDetailsFormManager.expiryDateValid,
            disabled: $viewModel.viewState.isDisabled,
            textContentType: getCreditCardExpiryDate(),
            keyboardType: .numberPad,
            accessibilityValue: viewModel.cardDetailsFormManager.expiryDateText,
            spellOutValue: true,
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
        .onChange(of: viewModel.cardDetailsFormManager.expiryDateError) { newValue in
            if !newValue.isEmpty && !announcing {
                announceFieldError(newValue)
            }
        }
        .focused($textFieldInFocus, equals: .expiryDate)
        .accessibilityFocused($voiceOverFocusedField, equals: .expiryDate)
    }

    private var securityCodeTextField: some View {
        var fieldAppearance = viewModel.appearance.cardSecurityTextField
        fieldAppearance.placeholderText = viewModel.cardDetailsFormManager.securityCodePlaceholder
        return OutlineTextField(
            appearance: fieldAppearance,
            text: $viewModel.cardDetailsFormManager.securityCodeText,
            title: viewModel.cardDetailsFormManager.securityCodeTitle,
            errorMessage: $viewModel.cardDetailsFormManager.securityCodeError,
            editing: $viewModel.cardDetailsFormManager.editingSecurityCode,
            valid: $viewModel.cardDetailsFormManager.securityCodeValid,
            disabled: $viewModel.viewState.isDisabled,
            textContentType: getCreditCardSecurityCode(),
            keyboardType: .numberPad,
            // Mask the security code input for PCI DSS compliance
            isSecureTextEntry: true,
            accessibilityValue: viewModel.cardDetailsFormManager.securityCodeText,
            spellOutValue: true,
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
        .onChange(of: viewModel.cardDetailsFormManager.securityCodeError) { newValue in
            if !newValue.isEmpty && !announcing {
                announceFieldError(newValue)
            }
        }
        .focused($textFieldInFocus, equals: .securityCode)
        .accessibilityFocused($voiceOverFocusedField, equals: .securityCode)
    }

    private var expiryDateAndSecurityCodeLayout: some View {
        let layout = shouldAlignVertically() ?
            AnyLayout(VStackLayout(spacing: viewModel.appearance.verticalSpacing)) :
            AnyLayout(HStackLayout(alignment: .top, spacing: viewModel.appearance.horizontalSpacing))
        return layout {
            expiryDateTextField
                .id(CardDetailsFocusable.expiryDate)
            securityCodeTextField
                .id(CardDetailsFocusable.securityCode)
        }
    }

    private var primaryButton: some View {
        let dynamicHint: String? = {
            if viewModel.isActionButtonDisabled() {
                return "Complete all required fields to enable submission."
            } else if viewModel.isLoading {
                return "Processing your card details"
            } else {
                // Use custom hint from appearance, or let SDKButton provide smart default
                return viewModel.appearance.actionButton.accessibilityHint
            }
        }()

        return SDKButton(
            title: viewModel.appearance.actionButton.text,
            isLoading: viewModel.isLoading && viewModel.showLoaders,
            style: .custom(
                CustomButtonStyle(
                    appearance: viewModel.appearance.actionButton,
                    isDisabled: viewModel.isActionButtonDisabled())),
            shouldTemplate: true,
            accessibilityHint: dynamicHint
        ) {
            // Move focus to primary button
            textFieldInFocus = nil

            // Suppress per-field error announcements before they're triggered by endEditing()
            // and validateForm(). Both mutate @Published error strings whose .onChange handlers
            // would otherwise fire announceFieldError at high priority and drown out the count.
            let voiceOverRunning = UIAccessibility.isVoiceOverRunning
            if voiceOverRunning {
                self.announcing = true
            }

            viewModel.cardDetailsFormManager.endEditing()

            // Only scroll and refocus in voiceover mode
            if !viewModel.ctaButtonTapped() && voiceOverRunning {
                let errorCount = viewModel.numberOfValidationErrors

                Task { @MainActor in
                    // Wait for VoiceOver to finish whatever it was speaking when the button
                    // was activated (button label/hint, "activated", etc.) before announcing
                    // the count — otherwise the default-priority count gets queued behind
                    // the in-progress speech and discarded when focus subsequently moves.
                    try? await Task.sleep(for: .seconds(1))
                    announceErrorCount(errorCount)

                    // Give the count time to be spoken in full before moving focus, since
                    // focus-change events also trigger VoiceOver speech and would cut it off.
                    try? await Task.sleep(for: .seconds(2))

                    // Request scroll to the first field with an error
                    if let firstInvalid = viewModel.firstTextFieldWithError {
                        // Call the scroll callback if provided
                        onScrollToField?(firstInvalid)

                        // Wait for the scroll animation to settle before flipping focus.
                        // VoiceOver silently drops a focus request to an off-screen element, so
                        // focusing mid-scroll fails. The worst case is the topmost field
                        // (cardholder name) when submitting from the bottom of the form at large
                        // Dynamic Type sizes — that scroll covers the greatest distance, so the
                        // previous short delay (tuned for the nearer fields) left the name field
                        // still off-screen when focus was applied. This delay must comfortably
                        // outlast the scroll animation for the longest-distance field.
                        try? await Task.sleep(for: .milliseconds(600))

                        voiceOverFocusedField = firstInvalid
                    }

                    self.announcing = false
                }
            } else if voiceOverRunning {
                // Form was valid (or VoiceOver wasn't relevant) — reset so future field changes
                // can announce normally.
                self.announcing = false
            }
        }
        .disabled(viewModel.isActionButtonDisabled())
        .customPadding(viewModel.appearance.actionButton.dimensions.padding)
    }

    private func announceErrorCount(_ count: Int) {
        let message: String
        switch count {
        case 0: return
        case 1: message = "There is 1 error in form"
        default: message = "There are \(count) errors in form"
        }

        if #available(iOS 17.0, *) {
            var attributed = AttributedString(message)
            // Use `.high` only if you want to cut off whatever VoiceOver is saying.
            attributed.accessibilitySpeechAnnouncementPriority = .default
            AccessibilityNotification.Announcement(attributed).post()
        } else {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    private func announceFieldError(_ message: String) {
        let prefixed = "Error: \(message)"
        if #available(iOS 17.0, *) {
            var attributed = AttributedString(prefixed)
            attributed.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(attributed).post()
        } else {
            UIAccessibility.post(notification: .announcement, argument: prefixed)
        }
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
                    .accessibilityLabel(text)
                    .accessibilityHint("Opens \(text) in browser")
                    .accessibilityAddTraits(.isLink)
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
        Group {
            // Recommended: With scroll-to-error support
            ScrollViewReader { proxy in
                ScrollView {
                    CardDetailsWidget(
                        config: CardDetailsWidgetConfig(gatewayId: "", accessToken: ""),
                        onScrollToField: { field in
                            withAnimation {
                                proxy.scrollTo(field, anchor: .center)
                            }
                        },
                        completion: { _ in }
                    )
                    .padding()
                }
            }
            .previewDisplayName("With Scroll-to-Error")

            // In a larger form
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Order Summary")
                            .font(.headline)

                        CardDetailsWidget(
                            config: CardDetailsWidgetConfig(gatewayId: "", accessToken: ""),
                            onScrollToField: { field in
                                withAnimation {
                                    proxy.scrollTo(field, anchor: .center)
                                }
                            },
                            completion: { _ in }
                        )

                        Text("Terms and Conditions")
                            .font(.headline)
                    }
                    .padding()
                }
            }
            .previewDisplayName("In Larger Form")
        }
    }
}
