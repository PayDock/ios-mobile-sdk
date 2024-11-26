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
                collectCardholderName: Bool = true,
                allowSaveCard: SaveCardConfig? = nil,
                loadingDelegate: WidgetLoadingDelegate? = nil,
                completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        _viewModel = StateObject(wrappedValue: CardDetailsVM(
            gatewayId: gatewayId,
            accessToken: accessToken,
            actionText: actionText,
            showCardTitle: showCardTitle,
            collectCardholderName: collectCardholderName,
            allowSaveCard: allowSaveCard,
            loadingDelegate: loadingDelegate,
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
                if viewModel.collectCardholderName {
                    OutlineTextField(
                        text: viewModel.cardDetailsFormManager.cardHolderNameBinding,
                        title: viewModel.cardDetailsFormManager.cardholderNameTitle,
                        placeholder: viewModel.cardDetailsFormManager.cardholderNamePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.cardholderNameError,
                        editing: $viewModel.cardDetailsFormManager.editingCardholderName,
                        valid: $viewModel.cardDetailsFormManager.cardHolderNameValid,
                        disabled: $viewModel.isDisabled,
                        onTapGesture: {
                            self.textFieldInFocus = .cardholderName
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardholderName)
                        }
                    )
                    .focused($textFieldInFocus, equals: .cardholderName)
                }

                OutlineTextField(
                    text: viewModel.cardDetailsFormManager.cardNumberBinding,
                    title: viewModel.cardDetailsFormManager.cardNumberTitle,
                    placeholder: viewModel.cardDetailsFormManager.cardNumberPlaceholder,
                    errorMessage: $viewModel.cardDetailsFormManager.cardNumberError,
                    leftImage: $viewModel.cardDetailsFormManager.cardImage,
                    editing: $viewModel.cardDetailsFormManager.editingCardNumber,
                    valid: $viewModel.cardDetailsFormManager.cardNumberValid,
                    disabled: $viewModel.isDisabled,
                    onTapGesture: {
                        self.textFieldInFocus = .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                    }
                )
                .keyboardType(.numberPad)
                .focused($textFieldInFocus, equals: .cardNumber)

                HStack(alignment: .top, spacing: .spacing * 0.75) {
                    OutlineTextField(
                        text: viewModel.cardDetailsFormManager.expiryDateBinding,
                        title: viewModel.cardDetailsFormManager.expiryDateTitle,
                        placeholder: viewModel.cardDetailsFormManager.expiryDatePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.expiryDateError,
                        editing: $viewModel.cardDetailsFormManager.editingExpiryDate,
                        valid: $viewModel.cardDetailsFormManager.expiryDateValid,
                        disabled: $viewModel.isDisabled,
                        onTapGesture: {
                            self.textFieldInFocus = .expiryDate
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                        }
                    )
                    .keyboardType(.numberPad)
                    .focused($textFieldInFocus, equals: .expiryDate)

                    OutlineTextField(
                        text: viewModel.cardDetailsFormManager.securityCodeBinding,
                        title: viewModel.cardDetailsFormManager.securityCodeTitle,
                        placeholder: viewModel.cardDetailsFormManager.securityCodePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.securityCodeError,
                        editing: $viewModel.cardDetailsFormManager.editingSecurityCode,
                        valid: $viewModel.cardDetailsFormManager.securityCodeValid,
                        disabled: $viewModel.isDisabled,
                        onTapGesture: {
                            self.textFieldInFocus = .securityCode
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                        }
                    )
                    .keyboardType(.numberPad)
                    .focused($textFieldInFocus, equals: .securityCode)
                }
                if viewModel.allowSaveCard != nil {
                    privacyView
                }
            }
            SDKButton(title: viewModel.actionText,
                      isLoading: viewModel.isLoading,
                      style: .fill(FillButtonStyle(isDisabled: viewModel.isActionButtonDisabled()))
            ) {
                viewModel.tokeniseCardDetails()
            }
            .frame(height: 48)
            .padding(.bottom, 16)
            .padding(.top, .spacing)
            .customFont(.body)
        }
        .padding(.horizontal, max(16, .spacing))
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
