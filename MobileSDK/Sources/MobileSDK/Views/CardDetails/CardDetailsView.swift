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
//    @State var isPresented = false

    // MARK: - Initialisation

    public init(gatewayId: String,
                onCompletion: Binding<String>) {
        viewModel.gatewayId = gatewayId
        viewModel.onCompletion = onCompletion
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
                        $viewModel.cardholderNameText,
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
                        viewModel.cardNumberBinding,
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
                            viewModel.expiryDateBinding,
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
                            $viewModel.cvcText,
                            placeholder: viewModel.cvcPlaceholder,
                            errorMessage: $viewModel.cvcError,
                            editing: $viewModel.editingCVC,
                            valid: $viewModel.cvcValid)
                        .focused($textFieldInFocus, equals: .cvc)
                        .onTapGesture {
                            self.textFieldInFocus = .cvc
                            viewModel.setEditingTextField(focusedField: .cvc)
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
    }


}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView(gatewayId: "asdf", onCompletion: .constant("asdf"))
            .previewLayout(.sizeThatFits)
    }
}
