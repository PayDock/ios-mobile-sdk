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
    @State var isPresented = false

    // MARK: - View protocol properties

    var body: some View {
        VStack {
            HStack {
                Text("Card information")
                Spacer()
            }
            .padding(.horizontal, 16)

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
                    $viewModel.cardNumberText,
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
                        $viewModel.expiryDateText,
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
            .listStyle(.plain)
            .frame(height: 300)
            Spacer()
        }
        .onChange(of: viewModel.cardNumberText) { newValue in
            print("new value")
            viewModel.validateCardNumber()
        }
    }


}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView()
            .previewLayout(.sizeThatFits)
    }
}
