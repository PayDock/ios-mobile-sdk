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
    @FocusState private var textFieldInFocus: CardDetailsFormManager.CardDetailsFocusable?
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
                        text: $viewModel.cardDetailsFormManager.cardholderNameText,
                        title: viewModel.cardDetailsFormManager.cardholderNameTitle,
                        placeholder: viewModel.cardDetailsFormManager.cardholderNamePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.cardholderNameError,
                        editing: $viewModel.cardDetailsFormManager.editingCardholderName,
                        valid: $viewModel.cardDetailsFormManager.cardHolderNameValid)
                    .focused($textFieldInFocus, equals: .cardholderName)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        self.textFieldInFocus = .cardholderName
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardholderName)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    OutlineTextField(
                        text: viewModel.cardNumberBinding,
                        title: viewModel.cardDetailsFormManager.cardNumberTitle,
                        placeholder: viewModel.cardDetailsFormManager.cardNumberPlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.cardNumberError,
                        leftImage: $viewModel.cardDetailsFormManager.cardImage,
                        editing: $viewModel.cardDetailsFormManager.editingCardNumber,
                        valid: $viewModel.cardDetailsFormManager.cardNumberValid)
                    .focused($textFieldInFocus, equals: .cardNumber)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        self.textFieldInFocus = .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    HStack(spacing: 12) {
                        OutlineTextField(
                            text: viewModel.expiryDateBinding,
                            title: viewModel.cardDetailsFormManager.expiryDateTitle,
                            placeholder: viewModel.cardDetailsFormManager.expiryDatePlaceholder,
                            errorMessage: $viewModel.cardDetailsFormManager.expiryDateError,
                            editing: $viewModel.cardDetailsFormManager.editingExpiryDate,
                            valid: $viewModel.cardDetailsFormManager.expiryDateValid)
                        .focused($textFieldInFocus, equals: .expiryDate)
                        .onTapGesture {
                            self.textFieldInFocus = .expiryDate
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                        }

                        OutlineTextField(
                            text: $viewModel.cardDetailsFormManager.securityCodeText,
                            title: viewModel.cardDetailsFormManager.securityCodeTitle,
                            placeholder: viewModel.cardDetailsFormManager.securityCodePlaceholder,
                            errorMessage: $viewModel.cardDetailsFormManager.securityCodeError,
                            editing: $viewModel.cardDetailsFormManager.editingSecurityCode,
                            valid: $viewModel.cardDetailsFormManager.securityCodeValid)
                        .focused($textFieldInFocus, equals: .securityCode)
                        .onTapGesture {
                            self.textFieldInFocus = .securityCode
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
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
