//
//  GiftCardWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 09.11.2023..
//

import SwiftUI

public struct GiftCardWidget: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    @StateObject private var viewModel: GiftCardVM
    @FocusState private var textFieldInFocus: GiftCardFormManager.GiftCardFocusable?
    @AccessibilityFocusState private var voiceOverFocusedField: GiftCardFormManager.GiftCardFocusable?
    @State private var announcing: Bool = false

    // External submit trigger, for hosts using `config.showSubmitButton = false` to supply their own
    // submit UI. See `GiftCardWidgetConfig.showSubmitButton`.
    // - onFormValidityChange: raw form validity — NOT gated on `activePrimaryButton`. A host driving
    //   its own button's enabled state should branch on its own `activePrimaryButton` choice: if
    //   `true`, its button should stay enabled (matching the internal button's tap-to-validate
    //   behaviour); if `false`, disable it until this reports `true`. A submitting/loading signal is
    //   already available via `loadingDelegate` (`loadingDidStart()`/`loadingDidFinish()`).
    private let submitTrigger: Binding<Bool>
    private let onFormValidityChange: ((Bool) -> Void)?

    public init(viewState: ViewState? = nil,
                config: GiftCardWidgetConfig,
                appearance: GiftCardWidgetAppearance = GiftCardWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                eventDelegate: WidgetEventDelegate? = nil,
                submitTrigger: Binding<Bool> = .constant(false),
                onFormValidityChange: ((Bool) -> Void)? = nil,
                completion: @escaping (Result<GiftCardResult, GiftCardError>) -> Void) {
        self.submitTrigger = submitTrigger
        self.onFormValidityChange = onFormValidityChange
        _viewModel = StateObject(wrappedValue: GiftCardVM(
            appearance: appearance,
            viewState: viewState ?? ViewState(state: .none),
            config: config,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: completion))
    }

    public var body: some View {
        let isValid = viewModel.giftCardFormManager.isFormValid()
        return ScrollView {
            Spacer()
                .frame(height: 6.0) /// Adds a bit of inset to start of the scrollview
            VStack(spacing: 0) {
                VStack(spacing: viewModel.appearance.verticalSpacing) {
                    let layout = shouldAlignVertically() ?
                    AnyLayout(VStackLayout(spacing: viewModel.appearance.verticalSpacing)) :
                    AnyLayout(HStackLayout(alignment: .top, spacing: viewModel.appearance.horizontalSpacing))
                    layout {
                        cardNumberTextField
                        pinTextField
                    }
                    if viewModel.config.showSubmitButton {
                        primaryButton
                            .accessibilityHint("Saves a gift card.")
                    }
                }
            }
            .padding(.horizontal, viewModel.appearance.horizontalSpacing)
        }
        .onChange(of: submitTrigger.wrappedValue) { shouldSubmit in
            if shouldSubmit {
                submitTapped()
                submitTrigger.wrappedValue = false
            }
        }
        .onChange(of: isValid) { onFormValidityChange?($0) }
    }

    private var cardNumberTextField: some View {
        return OutlineTextField(
            appearance: resolvedCardNumberAppearance,
            text: $viewModel.giftCardFormManager.cardNumberText,
            title: viewModel.giftCardFormManager.cardNumberTitle,
            errorMessage: $viewModel.giftCardFormManager.cardNumberError,
            leftImage: .constant(Image("credit-card", bundle: Bundle.module)),
            editing: $viewModel.giftCardFormManager.editingCardNumber,
            valid: $viewModel.giftCardFormManager.cardNumberValid,
            disabled: $viewModel.viewState.isDisabled,
            keyboardType: .numberPad,
            accessibilityValue: String(viewModel.giftCardFormManager.cardNumberText.filter { $0.isNumber }),
            spellOutValue: true,
            accessibilityIdentifier: "giftCardNumberField",
            onTapGesture: {
                if !viewModel.viewState.isDisabled {
                    self.textFieldInFocus = .cardNumber
                    viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
                }
            },
            onTextChange: { text, cursorPosition in
                return viewModel.giftCardFormManager.formatCardNumber(updatedText: text, cursorPosition: cursorPosition)
            }
        )
        .customToolbar(
            buttonTitle: "Next",
            font: UIFont(name: viewModel.appearance.toolbarButton.fonts.title.customFont.fontName,
                         size: viewModel.appearance.toolbarButton.fonts.title.customFont.size),
            textColor: UIColor(viewModel.appearance.toolbarButton.colors.text)
        ) {
            textFieldInFocus = .pin
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
        }
        .announceError($viewModel.giftCardFormManager.cardNumberError, suppressed: announcing)
        .focused($textFieldInFocus, equals: .cardNumber)
        .accessibilityFocused($voiceOverFocusedField, equals: .cardNumber)
    }

    private var pinTextField: some View {
        return OutlineTextField(
            appearance: resolvedPinAppearance,
            text: $viewModel.giftCardFormManager.pinText,
            title: viewModel.giftCardFormManager.pinTitle,
            errorMessage: $viewModel.giftCardFormManager.pinError,
            editing: $viewModel.giftCardFormManager.editingPin,
            valid: $viewModel.giftCardFormManager.pinValid,
            disabled: $viewModel.viewState.isDisabled,
            keyboardType: .numberPad,
            isSecureTextEntry: true,
            accessibilityValue: viewModel.giftCardFormManager.pinText,
            spellOutValue: true,
            accessibilityIdentifier: "giftCardPinField",
            onTapGesture: {
                if !viewModel.viewState.isDisabled {
                    self.textFieldInFocus = .pin
                    viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
                }
            },
            onTextChange: { text, cursorPosition in
                return viewModel.giftCardFormManager.formatPinNumber(updatedText: text, cursorPosition: cursorPosition)
            })
        .announceError($viewModel.giftCardFormManager.pinError, suppressed: announcing)
        .customToolbar(
            buttonTitle: "Done",
            font: UIFont(name: viewModel.appearance.toolbarButton.fonts.title.customFont.fontName,
                         size: viewModel.appearance.toolbarButton.fonts.title.customFont.size),
            textColor: UIColor(viewModel.appearance.toolbarButton.colors.text)
        ) {
            textFieldInFocus = nil
            viewModel.giftCardFormManager.setEditingTextField(focusedField: nil)
        }
        .onSubmit {
            textFieldInFocus = nil
            viewModel.giftCardFormManager.setEditingTextField(focusedField: nil)
        }
        .focused($textFieldInFocus, equals: .pin)
        .accessibilityFocused($voiceOverFocusedField, equals: .pin)
        .frame(width: shouldAlignVertically() ?
               UIScreen.main.bounds.width - viewModel.appearance.horizontalSpacing * 2 :
                UIScreen.main.bounds.width * 0.30)
    }

    private var primaryButton: some View {
        return SDKButton(
            title: viewModel.appearance.actionButton.text,
            isLoading: viewModel.isLoading && viewModel.showLoaders,
            style: .custom(CustomButtonStyle(
                appearance: viewModel.appearance.actionButton,
                isDisabled: viewModel.isActionButtonDisabled())),
            shouldTemplate: true) {
                submitTapped()
            }
            .disabled(viewModel.isActionButtonDisabled())
            .padding(.top, viewModel.appearance.actionButton.dimensions.padding.top)
            .padding(.leading, viewModel.appearance.actionButton.dimensions.padding.leading)
            .padding(.bottom, viewModel.appearance.actionButton.dimensions.padding.bottom)
            .padding(.trailing, viewModel.appearance.actionButton.dimensions.padding.trailing)
    }

    /// Validates and, if valid, tokenises the gift card. Shared by the internal Add button and the
    /// external `submitTrigger` binding, so both entry points behave identically — see
    /// `GiftCardWidgetConfig.showSubmitButton`.
    private func submitTapped() {
        // The external trigger bypasses the button's own `.disabled(isActionButtonDisabled())` guard,
        // so both signals it's built from must be re-checked here: `isLoading` catches a request
        // genuinely in flight (immune to external tampering, unlike `viewState.isDisabled` — a host
        // can legitimately call `viewState.setState(.none)` at any time, including mid-request), and
        // `viewState.isDisabled` catches a host's deliberate external disable via `setState(.disabled)`
        // that isn't tied to any request of this widget's own.
        guard !viewModel.isLoading, !viewModel.viewState.isDisabled else { return }

        textFieldInFocus = nil

        // Suppress per-field error announcements so they don't drown out the aggregate count.
        let voiceOverRunning = UIAccessibility.isVoiceOverRunning
        if voiceOverRunning { self.announcing = true }

        viewModel.giftCardFormManager.setEditingTextField(focusedField: nil)
        viewModel.giftCardFormManager.endEditing()
        viewModel.handleButtonTapAnalytics()

        if viewModel.giftCardFormManager.validateForm() {
            viewModel.tokeniseGiftCard()
            if voiceOverRunning { self.announcing = false }
        } else if voiceOverRunning {
            let errorCount = viewModel.numberOfValidationErrors
            Task { @MainActor in
                // Let VoiceOver finish the button's own utterance before announcing the count.
                try? await Task.sleep(for: .seconds(1))
                announceErrorCount(errorCount)

                // Give the count time to be spoken before moving focus (focus changes cut off speech).
                try? await Task.sleep(for: .seconds(2))
                if let firstInvalid = viewModel.firstTextFieldWithError {
                    voiceOverFocusedField = firstInvalid
                }
                self.announcing = false
            }
        }
    }

    private func announceErrorCount(_ count: Int) {
        guard let message = AccessibilityAnnouncer.errorCountMessage(count) else { return }
        AccessibilityAnnouncer.post(message, priority: .queued)
    }

    private func shouldAlignVertically() -> Bool {
        switch sizeCategory {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge: return false
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: return true
        @unknown default: return false
        }
    }

    // MARK: - Per-field appearance resolution

    /// Resolves the card-number field appearance: the per-field override if set, otherwise the base
    /// `textField`, with sensible placeholder/hint defaults injected only when none were supplied.
    private var resolvedCardNumberAppearance: Theme.TextFieldAppearance {
        var resolved = viewModel.appearance.cardNumberTextField ?? viewModel.appearance.textField
        if resolved.placeholderText == nil { resolved.placeholderText = "XXXX XXXX XXXX XXXX" }
        if resolved.hintText == nil { resolved.hintText = "Enter your gift card number" }
        return resolved
    }

    /// Resolves the PIN field appearance, injecting placeholder/hint defaults only when none were supplied.
    private var resolvedPinAppearance: Theme.TextFieldAppearance {
        var resolved = viewModel.appearance.pinTextField ?? viewModel.appearance.textField
        if resolved.placeholderText == nil { resolved.placeholderText = "XXXX" }
        if resolved.hintText == nil { resolved.hintText = "Enter your 4-digit PIN" }
        return resolved
    }
}

struct GiftCardView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidget(config: GiftCardWidgetConfig(accessToken: ""), completion: { _ in })
    }
}
