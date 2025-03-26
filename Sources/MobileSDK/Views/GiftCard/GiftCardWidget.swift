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
    
    public init(storePin: Bool = true,
                accessToken: String,
                loadingDelegate: WidgetLoadingDelegate? = nil,
                completion: @escaping (Result<String, GiftCardError>) -> Void) {
        _viewModel = StateObject(wrappedValue: GiftCardVM(
            accessToken: accessToken,
            storePin: storePin,
            loadingDelegate: loadingDelegate,
            completion: completion))
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: max(max(.spacing - 10, 0), 0)) {
                    HStack(spacing: .spacing * 0.75) {
                        cardNumberTextField
                        pinTextField
                    }
                    primaryButton
                    emptyFocusView
                }
                .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
                .background(Color.backgroundColor)
            }
            .padding(max(16, .spacing))
        }
    }
    
    private var cardNumberTextField: some View {
        return OutlineTextField(
            text: $viewModel.giftCardFormManager.cardNumberText,
            title: viewModel.giftCardFormManager.cardNumberTitle,
            placeholder: viewModel.giftCardFormManager.cardNumberPlaceholder,
            errorMessage: $viewModel.giftCardFormManager.cardNumberError,
            leftImage: .constant(Image("credit-card", bundle: Bundle.module)),
            editing: $viewModel.giftCardFormManager.editingCardNumber,
            valid: $viewModel.giftCardFormManager.cardNumberValid,
            disabled: $viewModel.isDisabled,
            onTapGesture: {
                self.textFieldInFocus = .cardNumber
                viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
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
                            .customFont(.body)
                            .foregroundColor(.primaryColor)
                    }
                }
            }
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .pin
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
        })
        .focused($textFieldInFocus, equals: .cardNumber)
        .frame(width: UIScreen.main.bounds.width * 0.65)
    }
    
    private var pinTextField: some View {
        return OutlineTextField(
            text: $viewModel.giftCardFormManager.pinText,
            title: viewModel.giftCardFormManager.pinTitle,
            placeholder: viewModel.giftCardFormManager.pinPlaceholder,
            errorMessage: $viewModel.giftCardFormManager.pinError,
            editing: $viewModel.giftCardFormManager.editingPin,
            valid: $viewModel.giftCardFormManager.pinValid,
            disabled: $viewModel.isDisabled,
            onTapGesture: {
                self.textFieldInFocus = .pin
                viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
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
                            .customFont(.body)
                            .foregroundColor(.primaryColor)
                    }
                }
            }
        }
        .onConditionalKeyPress(key: .tab, action: {
            textFieldInFocus = .cardNumber
            viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
        })
        .focused($textFieldInFocus, equals: .pin)
    }
    
    private var primaryButton: some View {
        let plusIcon = Image(systemName: "plus.circle")
        return SDKButton(title: "Add", image: plusIcon, style: .fill(FillButtonStyle(isDisabled: viewModel.isActionButtonDisabled()))) {
            viewModel.giftCardFormManager.endEditing()
            viewModel.tokeniseGiftCard()
        }
        .padding(.bottom, 16)
        .padding(.top, .spacing)
        .customFont(.body)

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
        GiftCardWidget(accessToken: "", completion: { _ in })
    }
}
