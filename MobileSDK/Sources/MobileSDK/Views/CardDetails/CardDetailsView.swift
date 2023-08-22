//
//  CardDetailsView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct CardDetailsView: View {

    // MARK: - Properties

    @StateObject private var viewModel = CardDetailsVM()
    @FocusState private var textFieldInFocus: CardDetailsVM.CardDetailsFocusable?
    @Binding private var onCompletion: String
    @State private var gatewayId: String

    // MARK: - Initialisation

    public init(gatewayId: String,
                onCompletion: Binding<String>) {
        self._onCompletion = onCompletion
        self.gatewayId = gatewayId
    }

    // MARK: - View protocol properties

    var body: some View {
        VStack {
            HStack {
                Text("Card information")
                    .customFont(.body, weight: .normal)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 16)

            VStack {
                List {
                    OutlineTextField(
                        text: $viewModel.cardholderNameText,
                        title: viewModel.cardholderNameTitle,
                        placeholder: viewModel.cardholderNamePlaceholder,
                        errorMessage: $viewModel.cardholderNameError,
                        editing: $viewModel.editingCardholderName,
                        valid: $viewModel.cardHolderNameValid)
                    .focused($textFieldInFocus, equals: .cardholderName)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        self.textFieldInFocus = .cardholderName
                        viewModel.setEditingTextField(focusedField: .cardholderName)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    OutlineTextField(
                        text: viewModel.cardNumberBinding,
                        title: viewModel.cardNumberTitle,
                        placeholder: viewModel.cardNumberPlaceholder,
                        errorMessage: $viewModel.cardNumberError,
                        leftImage: $viewModel.cardImage,
                        editing: $viewModel.editingCardNumber,
                        valid: $viewModel.cardNumberValid)
                    .focused($textFieldInFocus, equals: .cardNumber)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        self.textFieldInFocus = .cardNumber
                        viewModel.setEditingTextField(focusedField: .cardNumber)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    HStack(spacing: 12) {
                        OutlineTextField(
                            text: viewModel.expiryDateBinding,
                            title: viewModel.expiryDateTitle,
                            placeholder: viewModel.expiryDatePlaceholder,
                            errorMessage: $viewModel.expiryDateError,
                            editing: $viewModel.editingExpiryDate,
                            valid: $viewModel.expiryDateValid)
                        .focused($textFieldInFocus, equals: .expiryDate)
                        .onTapGesture {
                            self.textFieldInFocus = .expiryDate
                            viewModel.setEditingTextField(focusedField: .expiryDate)
                        }

                        OutlineTextField(
                            text: $viewModel.securityCodeText,
                            title: viewModel.securityCodeTitle,
                            placeholder: viewModel.securityCodePlaceholder,
                            errorMessage: $viewModel.securityCodeError,
                            editing: $viewModel.editingSecurityCode,
                            valid: $viewModel.securityCodeValid)
                        .focused($textFieldInFocus, equals: .securityCode)
                        .onTapGesture {
                            self.textFieldInFocus = .securityCode
                            viewModel.setEditingTextField(focusedField: .securityCode)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                }
                LargeButton(title: "Save card") {
                    viewModel.tokeniseCardDetails()
                }
                .customFont(.body)
                .padding(.horizontal, 16)
            }
            .listStyle(.plain)
            .frame(height: 300)
            Spacer()
        }
        .onAppear {
            viewModel.gatewayId = gatewayId
            viewModel.onCompletion = $onCompletion
        }
    }

}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView(gatewayId: "asdf", onCompletion: .constant("asdf"))
            .previewLayout(.sizeThatFits)
    }
}
