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
                HStack {
                    Text("Gift Card")
                        .customFont(.body)
                        .foregroundColor(.placeholderColor)
                    Spacer()
                }
                .padding(.bottom, 12)

                VStack(spacing: max(max(.spacing - 10, 0), 0)) {
                    HStack(spacing: .spacing * 0.75) {
                        OutlineTextField(
                            text: viewModel.giftCardFormManager.cardNumberBinding,
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
                        .focused($textFieldInFocus, equals: .cardNumber)
                        .frame(width: UIScreen.main.bounds.width * 0.65)
                        
                        OutlineTextField(
                            text: viewModel.giftCardFormManager.pinBinding,
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
                        .focused($textFieldInFocus, equals: .pin)
                    }
                }
                let plusIcon = Image(systemName: "plus.circle")
                SDKButton(title: "Add", image: plusIcon, style: .fill(FillButtonStyle(isDisabled: viewModel.isDisabled))) {
                    viewModel.tokeniseGiftCard()
                }
                .frame(height: 48)
                .padding(.bottom, 16)
                .padding(.top, .spacing)
                .customFont(.body)
            }
            .padding(.horizontal, max(16, .spacing))
        }
        .frame(height: 200, alignment: .top)
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
}

struct GiftCardView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidget(accessToken: "", completion: { _ in })
    }
}
