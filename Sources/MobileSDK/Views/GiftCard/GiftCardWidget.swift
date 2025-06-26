//
//  GiftCardWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 09.11.2023..
//

import SwiftUI

public struct GiftCardWidget: View {
    @StateObject private var viewModel: GiftCardVM
    @FocusState private var textFieldInFocus: GiftCardFormManager.GiftCardFocusable?
    @FocusState private var isViewFocused: Bool
    @State var appearance: GiftCardWidgetAppearance

    
    public init(viewState: ViewState? = nil,
                config: GiftCardWidgetConfig,
                appearance: GiftCardWidgetAppearance = GiftCardWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                completion: @escaping (Result<GiftCardResult, GiftCardError>) -> Void) {
        self.appearance = appearance
        _viewModel = StateObject(wrappedValue: GiftCardVM(
            viewState: viewState ?? ViewState(state: .none),
            config: config,
            loadingDelegate: loadingDelegate,
            completion: completion))
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: appearance.verticalSpacing) {
                    HStack(spacing: appearance.horizontalSpacing) {
                        cardNumberTextField
                        pinTextField
                    }
                    primaryButton
                    emptyFocusView
                }
            }
            .padding(16.0)
        }
    }
    
    private var cardNumberTextField: some View {
        return OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.giftCardFormManager.cardNumberText,
            title: viewModel.giftCardFormManager.cardNumberTitle,
            placeholder: viewModel.giftCardFormManager.cardNumberPlaceholder,
            errorMessage: $viewModel.giftCardFormManager.cardNumberError,
            leftImage: .constant(Image("credit-card", bundle: Bundle.module)),
            editing: $viewModel.giftCardFormManager.editingCardNumber,
            valid: $viewModel.giftCardFormManager.cardNumberValid,
            disabled: $viewModel.viewState.isDisabled,
            onTapGesture: {
                if (!viewModel.viewState.isDisabled) {
                    self.textFieldInFocus = .cardNumber
                    viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
                }
            })
        .keyboardType(.numberPad)
        .toolbar {
            if textFieldInFocus == .cardNumber {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        textFieldInFocus = .pin
                        viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
                    } label: {
                        Text("Next")
                            .font(appearance.toolbarButton.fonts.title.customFont.font)
                            .foregroundColor(appearance.toolbarButton.colors.text)
                    }
                }
            }
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .pin
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
        })
        .focused($textFieldInFocus, equals: .cardNumber)
    }
    
    private var pinTextField: some View {
        return OutlineTextField(
            appearance: appearance.textField,
            text: $viewModel.giftCardFormManager.pinText,
            title: viewModel.giftCardFormManager.pinTitle,
            placeholder: viewModel.giftCardFormManager.pinPlaceholder,
            errorMessage: $viewModel.giftCardFormManager.pinError,
            editing: $viewModel.giftCardFormManager.editingPin,
            valid: $viewModel.giftCardFormManager.pinValid,
            disabled: $viewModel.viewState.isDisabled,
            onTapGesture: {
                if (!viewModel.viewState.isDisabled) {
                    self.textFieldInFocus = .pin
                    viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
                }
            })
        .keyboardType(.numberPad)
        .toolbar {
            if textFieldInFocus == .pin {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        textFieldInFocus = nil
                        viewModel.giftCardFormManager.endEditing()
                    } label: {
                        Text("Done")
                            .font(appearance.toolbarButton.fonts.title.customFont.font)
                            .foregroundColor(appearance.toolbarButton.colors.text)
                    }
                }
            }
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .cardNumber
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
        })
        .focused($textFieldInFocus, equals: .pin)
        .frame(width: UIScreen.main.bounds.width * 0.25)
    }
    
    private var primaryButton: some View {
        let plusIcon = Image(systemName: "plus.circle")

        return SDKButton(title: "Add", image: plusIcon,
                         isLoading: viewModel.isLoading,
                         style: .custom(CustomButtonStyle(appearance: appearance.actionButton, isDisabled: viewModel.isActionButtonDisabled())),
                         shouldTemplate: true) {
            viewModel.giftCardFormManager.endEditing()
            viewModel.tokeniseGiftCard()
        }
        .padding(.top, appearance.actionButton.dimensions.padding.top)
        .padding(.leading, appearance.actionButton.dimensions.padding.leading)
        .padding(.bottom, appearance.actionButton.dimensions.padding.bottom)
        .padding(.trailing, appearance.actionButton.dimensions.padding.trailing)
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
}

struct GiftCardView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidget(config: GiftCardWidgetConfig(accessToken: ""), completion: { _ in })
    }
}
