//
//  GiftCardView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.11.2023..
//

import SwiftUI

struct GiftCardView: View {
    @StateObject private var viewModel = GiftCardVM()
    @FocusState private var textFieldInFocus: GiftCardFormManager.GiftCardFocusable?
    @State private var gatewayId: String
    @Binding private var onCompletion: String

    // TODO: - Add proper data passing once endpoints are implemented
    public init(gatewayId: String,
                onCompletion: Binding<String>) {
        self._onCompletion = onCompletion
        self.gatewayId = gatewayId
    }

    var body: some View {
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
                            editing: $viewModel.giftCardFormManager.editingCardNumber,
                            valid: $viewModel.giftCardFormManager.cardNumberValid)
                        .keyboardType(.numberPad)
                        .focused($textFieldInFocus, equals: .cardNumber)
                        .frame(width: UIScreen.main.bounds.width * 0.65)
                        .onTapGesture {
                            self.textFieldInFocus = .cardNumber
                            viewModel.giftCardFormManager.setEditingTextField(focusedField: .cardNumber)
                        }
                        
                        OutlineTextField(
                            text: viewModel.giftCardFormManager.pinBinding,
                            title: viewModel.giftCardFormManager.pinTitle,
                            placeholder: viewModel.giftCardFormManager.pinPlaceholder,
                            errorMessage: $viewModel.giftCardFormManager.pinError,
                            editing: $viewModel.giftCardFormManager.editingPin,
                            valid: $viewModel.giftCardFormManager.pinValid)
                        .focused($textFieldInFocus, equals: .pin)
                        .onTapGesture {
                            self.textFieldInFocus = .pin
                            viewModel.giftCardFormManager.setEditingTextField(focusedField: .pin)
                        }
                    }
                }
                LargeButton(title: "Add") {
                    
                }
                .padding(.bottom, 16)
                .padding(.top, .spacing)
                .customFont(.body)
            }
            .padding(.horizontal, max(16, .spacing))
        }
        .frame(height: 180, alignment: .top)
    }
}

//#Preview {
//    PayPalView(
//        applePayRequest: .init(token: "asdf", merchanIdentifier: "asdf", request: .),
//        onCompletion: .constant(.init(status: "asd", amount: 10, currency: "USD"))
//        , onFailure: .constant(.paymentFailed))
//}
