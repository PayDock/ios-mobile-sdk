//
//  CardDetailsWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

public struct CardDetailsWidget: View {

    // MARK: - Properties

    @StateObject var viewModel: CardDetailsVM
    @FocusState private var textFieldInFocus: CardDetailsFormManager.CardDetailsFocusable?

    // MARK: - Initialisation

    public init(gatewayId: String,
                completion: @escaping (Result<String, CardDetailsError>) -> Void) {
        _viewModel = StateObject(wrappedValue: CardDetailsVM(gatewayId: gatewayId, completion: completion))
    }

    // MARK: - View protocol properties

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("Card information")
                        .customFont(.body)
                        .foregroundColor(.placeholderColor)
                    Spacer()
                }
                .padding(.bottom, 12)

                VStack(spacing: max(max(.spacing - 10, 0), 0)) {
                    OutlineTextField(
                        text: viewModel.cardDetailsFormManager.cardHolderNameBinding,
                        title: viewModel.cardDetailsFormManager.cardholderNameTitle,
                        placeholder: viewModel.cardDetailsFormManager.cardholderNamePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.cardholderNameError,
                        editing: $viewModel.cardDetailsFormManager.editingCardholderName,
                        valid: $viewModel.cardDetailsFormManager.cardHolderNameValid)
                    .focused($textFieldInFocus, equals: .cardholderName)
                    .onTapGesture {
                        self.textFieldInFocus = .cardholderName
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardholderName)
                    }

                    OutlineTextField(
                        text: viewModel.cardDetailsFormManager.cardNumberBinding,
                        title: viewModel.cardDetailsFormManager.cardNumberTitle,
                        placeholder: viewModel.cardDetailsFormManager.cardNumberPlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.cardNumberError,
                        leftImage: $viewModel.cardDetailsFormManager.cardImage,
                        editing: $viewModel.cardDetailsFormManager.editingCardNumber,
                        valid: $viewModel.cardDetailsFormManager.cardNumberValid)
                    .focused($textFieldInFocus, equals: .cardNumber)
                    .onTapGesture {
                        self.textFieldInFocus = .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                    }

                    HStack(spacing: .spacing * 0.75) {
                        OutlineTextField(
                            text: viewModel.cardDetailsFormManager.expiryDateBinding,
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
                            text: viewModel.cardDetailsFormManager.securityCodeBinding,
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
                }
                LargeButton(title: "Save card") {
                    viewModel.tokeniseCardDetails()
                }
                .padding(.bottom, 16)
                .padding(.top, .spacing)
                .customFont(.body)
            }
            .padding(.horizontal, max(16, .spacing))
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .frame(height: 380, alignment: .top)
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidget(gatewayId: "asdf", completion: { _ in })
            .previewLayout(.sizeThatFits)
    }
}