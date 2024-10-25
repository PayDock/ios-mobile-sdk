//
//  CardDetailsWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

public struct CardDetailsWidget: View {

    // MARK: - Properties

    @StateObject var viewModel: CardDetailsVM
    @FocusState private var textFieldInFocus: CardDetailsFormManager.CardDetailsFocusable?

    // MARK: - Initialisation

    public init(gatewayId: String?,
                accessToken: String,
                actionText: String = "Submit",
                showCardTitle: Bool = true,
                allowSaveCard: SaveCardConfig? = nil,
                completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        _viewModel = StateObject(wrappedValue: CardDetailsVM(
            gatewayId: gatewayId,
            accessToken: accessToken,
            actionText: actionText,
            showCardTitle: showCardTitle,
            allowSaveCard: allowSaveCard,
            completion: completion))
    }

    // MARK: - View protocol properties

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.showCardTitle {
                HStack {
                    Text("Card information")
                        .customFont(.body)
                        .foregroundColor(.placeholderColor)
                    Spacer()
                }
                .padding(.bottom, 14)
            }

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
                .keyboardType(.numberPad)
                .focused($textFieldInFocus, equals: .cardNumber)
                .onTapGesture {
                    self.textFieldInFocus = .cardNumber
                    viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                }

                HStack(alignment: .top, spacing: .spacing * 0.75) {
                    OutlineTextField(
                        text: viewModel.cardDetailsFormManager.expiryDateBinding,
                        title: viewModel.cardDetailsFormManager.expiryDateTitle,
                        placeholder: viewModel.cardDetailsFormManager.expiryDatePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.expiryDateError,
                        editing: $viewModel.cardDetailsFormManager.editingExpiryDate,
                        valid: $viewModel.cardDetailsFormManager.expiryDateValid)
                    .keyboardType(.numberPad)
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
                    .keyboardType(.numberPad)
                    .focused($textFieldInFocus, equals: .securityCode)
                    .onTapGesture {
                        self.textFieldInFocus = .securityCode
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                    }
                }
                if viewModel.allowSaveCard != nil {
                    privacyView
                }
            }
            SDKButton(title: viewModel.actionText, style: .fill(FillButtonStyle(isDisabled: !viewModel.cardDetailsFormManager.isFormValid()))) {
                viewModel.tokeniseCardDetails()
            }
            .padding(.bottom, 16)
            .padding(.top, .spacing)
            .customFont(.body)
        }
        .padding(.horizontal, max(16, .spacing))
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }

    private var privacyView: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.allowSaveCard?.consentText ?? "")
                        .customFont(.body3)
                        .foregroundColor(.textColor)
                    let text = viewModel.allowSaveCard?.privacyPolicyConfig?.privacyPolicyText ?? ""
                    let url = viewModel.allowSaveCard?.privacyPolicyConfig?.privacyPolicyURL ?? ""
                    let link = "[\(text)](\(url))"
                    Text(.init(link))
                        .customFont(.body3)
                        .foregroundColor(.textColor)
                        .underline()
                }
                Spacer()
                Toggle(isOn: $viewModel.policyAccepted) {}
                    .tint(.primaryColor)
                    .frame(width: 64, height: 44)
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidget(gatewayId: "", accessToken: "", completion: { _ in })
            .previewLayout(.sizeThatFits)
    }
}
