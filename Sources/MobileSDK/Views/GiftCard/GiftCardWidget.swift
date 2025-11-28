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
    @FocusState private var isViewFocused: Bool

    public init(viewState: ViewState? = nil,
                config: GiftCardWidgetConfig,
                appearance: GiftCardWidgetAppearance = GiftCardWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                eventDelegate: WidgetEventDelegate? = nil,
                completion: @escaping (Result<GiftCardResult, GiftCardError>) -> Void) {
        _viewModel = StateObject(wrappedValue: GiftCardVM(
            appearance: appearance,
            viewState: viewState ?? ViewState(state: .none),
            config: config,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: completion))
    }

    public var body: some View {
        ScrollView {
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
                    primaryButton
                        .accessibilityHint("Saves a gift card.")
                    emptyFocusView
                }
            }
            .padding(.horizontal, viewModel.appearance.horizontalSpacing)
        }
    }

    private var cardNumberTextField: some View {
        return OutlineTextField(
            appearance: viewModel.appearance.textField,
            text: $viewModel.giftCardFormManager.cardNumberText,
            title: viewModel.giftCardFormManager.cardNumberTitle,
            placeholder: viewModel.giftCardFormManager.cardNumberPlaceholder,
            errorMessage: $viewModel.giftCardFormManager.cardNumberError,
            leftImage: .constant(Image("credit-card", bundle: Bundle.module)),
            editing: $viewModel.giftCardFormManager.editingCardNumber,
            valid: $viewModel.giftCardFormManager.cardNumberValid,
            disabled: $viewModel.viewState.isDisabled,
            keyboardType: .numberPad,
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
            font: UIFont(name: viewModel.appearance.toolbarButton.fonts.title.customFont.name,
                         size: viewModel.appearance.toolbarButton.fonts.title.customFont.size),
            textColor: UIColor(viewModel.appearance.toolbarButton.colors.text)
        ) {
            textFieldInFocus = .pin
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .pin
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
        })
        .focused($textFieldInFocus, equals: .cardNumber)
    }

    private var pinTextField: some View {
        return OutlineTextField(
            appearance: viewModel.appearance.textField,
            text: $viewModel.giftCardFormManager.pinText,
            title: viewModel.giftCardFormManager.pinTitle,
            placeholder: viewModel.giftCardFormManager.pinPlaceholder,
            errorMessage: $viewModel.giftCardFormManager.pinError,
            editing: $viewModel.giftCardFormManager.editingPin,
            valid: $viewModel.giftCardFormManager.pinValid,
            disabled: $viewModel.viewState.isDisabled,
            keyboardType: .numberPad,
            onTapGesture: {
                if !viewModel.viewState.isDisabled {
                    self.textFieldInFocus = .pin
                    viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
                }
            },
            onTextChange: { text, cursorPosition in
                return viewModel.giftCardFormManager.formatPinNumber(updatedText: text, cursorPosition: cursorPosition)
            })
        .customToolbar(
            buttonTitle: "Done",
            font: UIFont(name: viewModel.appearance.toolbarButton.fonts.title.customFont.name,
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
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .cardNumber
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
        })
        .focused($textFieldInFocus, equals: .pin)
        .frame(width: shouldAlignVertically() ?
               UIScreen.main.bounds.width - viewModel.appearance.horizontalSpacing * 2 :
                UIScreen.main.bounds.width * 0.30)
    }

    private var primaryButton: some View {
        return SDKButton(
            title: viewModel.appearance.actionButton.text,
            isLoading: viewModel.isLoading,
            style: .custom(CustomButtonStyle(
                appearance: viewModel.appearance.actionButton,
                isDisabled: viewModel.isActionButtonDisabled())),
            shouldTemplate: true) {
                viewModel.giftCardFormManager.endEditing()
                viewModel.tokeniseGiftCard()
                viewModel.handleButtonTapAnalytics()
            }
            .padding(.top, viewModel.appearance.actionButton.dimensions.padding.top)
            .padding(.leading, viewModel.appearance.actionButton.dimensions.padding.leading)
            .padding(.bottom, viewModel.appearance.actionButton.dimensions.padding.bottom)
            .padding(.trailing, viewModel.appearance.actionButton.dimensions.padding.trailing)
    }

    private var emptyFocusView: some View {
        VStack {}
            .conditionalFocusable()
            .focused($isViewFocused)
            .onConditionalKeyPress(key: .tab, action: {
                textFieldInFocus = .cardNumber
                viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
            })
            .onAppear {
                isViewFocused = true
            }
    }

    private func shouldAlignVertically() -> Bool {
        switch sizeCategory {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge: return false
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: return true
        @unknown default: return false
        }
    }
}

struct GiftCardView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidget(config: GiftCardWidgetConfig(accessToken: ""), completion: { _ in })
    }
}
