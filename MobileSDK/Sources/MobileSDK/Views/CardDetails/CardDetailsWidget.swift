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

    @Environment(\.dynamicTypeSize) var sizeCategory
    @StateObject var viewModel: CardDetailsVM
    @FocusState private var textFieldInFocus: CardDetailsFormManager.CardDetailsFocusable?

    // MARK: - Initialisation

    public init(viewState: ViewState? = nil,
                config: CardDetailsWidgetConfig,
                loadingDelegate: WidgetLoadingDelegate? = nil,
                completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        _viewModel = StateObject(wrappedValue: CardDetailsVM(
            viewState: viewState ?? ViewState(state: .none),
            config: config,
            loadingDelegate: loadingDelegate,
            completion: completion))
    }

    // MARK: - View protocol properties

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.config.showCardTitle {
                HStack {
                    Text("Card information")
                        .customFont(.body)
                        .foregroundColor(.placeholderColor)
                    Spacer()
                }
                .padding(.bottom, 14)
            }
            
            if let supportedSchemes = viewModel.config.schemeSupport.supportedSchemes, !supportedSchemes.isEmpty {
                HStack(spacing: 7) {
                    ForEach(Array(supportedSchemes), id: \.self) { scheme in
                        getSchemeIcon(for: scheme)
                            .resizable()
                            .frame(width: 26, height: 20)
                            .scaledToFit()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, .spacing)
            }

            VStack(spacing: max(max(.spacing - 10, 0), 0)) {
                if viewModel.config.collectCardholderName {
                    OutlineTextField(
                        text: $viewModel.cardDetailsFormManager.cardholderNameText,
                        title: viewModel.cardDetailsFormManager.cardholderNameTitle,
                        placeholder: viewModel.cardDetailsFormManager.cardholderNamePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.cardholderNameError,
                        editing: $viewModel.cardDetailsFormManager.editingCardholderName,
                        valid: $viewModel.cardDetailsFormManager.cardHolderNameValid,
                        disabled: $viewModel.viewState.isDisabled,
                        onTapGesture: {
                            if (!viewModel.viewState.isDisabled) {
                                self.textFieldInFocus = .cardholderName
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardholderName)
                            }
                        }
                    )
                    .focused($textFieldInFocus, equals: .cardholderName)
                }

                OutlineTextField(
                    text: $viewModel.cardDetailsFormManager.cardNumberText,
                    title: viewModel.cardDetailsFormManager.cardNumberTitle,
                    placeholder: viewModel.cardDetailsFormManager.cardNumberPlaceholder,
                    errorMessage: $viewModel.cardDetailsFormManager.cardNumberError,
                    leftImage: $viewModel.cardDetailsFormManager.cardImage,
                    editing: $viewModel.cardDetailsFormManager.editingCardNumber,
                    valid: $viewModel.cardDetailsFormManager.cardNumberValid,
                    disabled: $viewModel.viewState.isDisabled,
                    onTapGesture: {
                        if (!viewModel.viewState.isDisabled) {
                            self.textFieldInFocus = .cardNumber
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                        }
                    }
                )
                .keyboardType(.numberPad)
                .focused($textFieldInFocus, equals: .cardNumber)
                .onChange(of: viewModel.cardDetailsFormManager.cardNumberText) { newValue in
                    viewModel.cardDetailsFormManager.formatCardNumber(updatedText: newValue)
                }

                let layout = shouldAlignVertically() ?
                    AnyLayout(VStackLayout(spacing: max(max(.spacing - 10, 0), 0))) :
                    AnyLayout(HStackLayout(alignment: .top, spacing: .spacing * 0.75))
                layout {
                    OutlineTextField(
                        text: $viewModel.cardDetailsFormManager.expiryDateText,
                        title: viewModel.cardDetailsFormManager.expiryDateTitle,
                        placeholder: viewModel.cardDetailsFormManager.expiryDatePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.expiryDateError,
                        editing: $viewModel.cardDetailsFormManager.editingExpiryDate,
                        valid: $viewModel.cardDetailsFormManager.expiryDateValid,
                        disabled: $viewModel.viewState.isDisabled,
                        
                        onTapGesture: {
                            if (!viewModel.viewState.isDisabled) {
                                self.textFieldInFocus = .expiryDate
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                            }
                        }
                    )
                    .keyboardType(.numberPad)
                    .focused($textFieldInFocus, equals: .expiryDate)
                    .onChange(of: viewModel.cardDetailsFormManager.expiryDateText) { newValue in
                        viewModel.cardDetailsFormManager.formatExpiryDate(updatedText: newValue)
                    }

                    OutlineTextField(
                        text: $viewModel.cardDetailsFormManager.securityCodeText,
                        title: viewModel.cardDetailsFormManager.securityCodeTitle,
                        placeholder: viewModel.cardDetailsFormManager.securityCodePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.securityCodeError,
                        editing: $viewModel.cardDetailsFormManager.editingSecurityCode,
                        valid: $viewModel.cardDetailsFormManager.securityCodeValid,
                        disabled: $viewModel.viewState.isDisabled,
                        onTapGesture: {
                            if (!viewModel.viewState.isDisabled) {
                                self.textFieldInFocus = .securityCode
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                            }
                        }
                    )
                    .keyboardType(.numberPad)
                    .focused($textFieldInFocus, equals: .securityCode)
                }
                if viewModel.config.allowSaveCard != nil {
                    privacyView
                }
            }
            SDKButton(title: viewModel.config.actionText,
                      isLoading: viewModel.isLoading && viewModel.showLoaders,
                      style: .fill(FillButtonStyle(isDisabled: viewModel.isActionButtonDisabled()))
            ) {
                viewModel.cardDetailsFormManager.endEditing()
                viewModel.tokeniseCardDetails()
            }
            .padding(.bottom, 16)
            .padding(.top, .spacing)
            .customFont(.body)
        }
        .padding(.horizontal, max(16, .spacing))
    }

    private var privacyView: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.config.allowSaveCard?.consentText ?? "")
                        .customFont(.body3)
                        .foregroundColor(.textColor)
                    let text = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyText ?? ""
                    let url = viewModel.config.allowSaveCard?.privacyPolicyConfig?.privacyPolicyURL ?? ""
                    let link = "[\(text)](\(url))"
                    Text(.init(link))
                        .customFont(.body3)
                        .foregroundColor(.textColor)
                        .underline()
                        .disabled(viewModel.viewState.isDisabled)
                }
                Spacer()
                Toggle(isOn: $viewModel.policyAccepted) {}
                    .tint(.primaryColor)
                    .frame(width: 64, height: 44)
                    .disabled(viewModel.viewState.isDisabled)
        }
    }
    
    private func getSchemeIcon(for scheme: CardScheme) -> Image {
        switch scheme {
        case .amex: Image("amex", bundle: Bundle.module)
        case .ausbc: Image("ausbc", bundle: Bundle.module)
        case .diners: Image("diners", bundle: Bundle.module)
        case .discover: Image("discover", bundle: Bundle.module)
        case .japcb: Image("jcb", bundle: Bundle.module)
        case .mastercard: Image("mastercard", bundle: Bundle.module)
        case .solo: Image("solo", bundle: Bundle.module)
        case .visa: Image("visa", bundle: Bundle.module)
        }
    }
    
    private func shouldAlignVertically() -> Bool {
        switch sizeCategory {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge: return false
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: return true
        @unknown default: return false
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidget(config: CardDetailsWidgetConfig(gatewayId: "", accessToken: ""), completion: { _ in })
            .previewLayout(.sizeThatFits)
    }
}
