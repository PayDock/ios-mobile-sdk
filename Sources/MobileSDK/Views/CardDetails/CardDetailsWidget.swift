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
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) var sizeCategory
    @StateObject var viewModel: CardDetailsVM
    @FocusState private var textFieldInFocus: CardDetailsFormManager.CardDetailsFocusable?
    @FocusState private var isViewFocused: Bool

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
                        .foregroundColor(.textColor)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }
                .padding(.bottom, 14)
            }
            
            if let supportedSchemes = viewModel.config.schemeSupport.supportedSchemes, !supportedSchemes.isEmpty {
                HStack(spacing: 7) {
                    ForEach(CardScheme.sortedArray(from: supportedSchemes), id: \.self) { scheme in
                        getSchemeIcon(for: scheme)
                            .resizable()
                            .frame(width: 26, height: 20)
                            .scaledToFit()
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("Supported card schemes: \(supportedSchemes.map(\.voiceoverName).joined(separator: ", "))")
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
                        textContentType: getCreditCardName(),
                        onTapGesture: {
                            if (!viewModel.viewState.isDisabled) {
                                self.textFieldInFocus = .cardholderName
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardholderName)
                            }
                        }
                    )
                    .submitLabel(.next)
                    .onSubmit {
                        textFieldInFocus = .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                    }
                    .onConditionalKeyPress(key: .tab, action: {
                        textFieldInFocus = .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                    })
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
                    textContentType: .creditCardNumber,
                    onTapGesture: {
                        if (!viewModel.viewState.isDisabled) {
                            self.textFieldInFocus = .cardNumber
                            viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .cardNumber)
                        }
                    }
                )
                .keyboardType(.numberPad)
                .toolbar {
                    if textFieldInFocus == .cardNumber {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                textFieldInFocus = .expiryDate
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                            } label: {
                                Text("Next")
                                    .customFont(.body)
                                    .foregroundColor(.primaryColor)
                            }
                        }
                    }
                }
                .onConditionalKeyPress(key: .tab, action: {
                    textFieldInFocus = .expiryDate
                    viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                })
                .focused($textFieldInFocus, equals: .cardNumber)
                .onChange(of: viewModel.cardDetailsFormManager.cardNumberText) { newValue in
                    viewModel.cardDetailsFormManager.formatCardNumber(updatedText: newValue)
                }

                let layout = shouldAlignVertically() ?
                    AnyLayout(VStackLayout(spacing: max(max(.spacing - 10, 0), 0))) :
                    AnyLayout(HStackLayout(alignment: .top, spacing: .spacing))
                layout {
                    OutlineTextField(
                        text: $viewModel.cardDetailsFormManager.expiryDateText,
                        title: viewModel.cardDetailsFormManager.expiryDateTitle,
                        placeholder: viewModel.cardDetailsFormManager.expiryDatePlaceholder,
                        errorMessage: $viewModel.cardDetailsFormManager.expiryDateError,
                        editing: $viewModel.cardDetailsFormManager.editingExpiryDate,
                        valid: $viewModel.cardDetailsFormManager.expiryDateValid,
                        disabled: $viewModel.viewState.isDisabled,
                        textContentType: getCreditCardExpiryDate(),
                        onTapGesture: {
                            if (!viewModel.viewState.isDisabled) {
                                self.textFieldInFocus = .expiryDate
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .expiryDate)
                            }
                        }
                    )
                    .keyboardType(.numberPad)
                    .toolbar {
                        if textFieldInFocus == .expiryDate {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button {
                                    textFieldInFocus = .securityCode
                                    viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                                } label: {
                                    Text("Next")
                                        .customFont(.body)
                                        .foregroundColor(.primaryColor)
                                }
                            }
                        }
                    }
                    .onConditionalKeyPress(key: .tab, action: {
                        textFieldInFocus = .securityCode
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                    })
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
                        textContentType: getCreditCardSecurityCode(),
                        onTapGesture: {
                            if (!viewModel.viewState.isDisabled) {
                                self.textFieldInFocus = .securityCode
                                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: .securityCode)
                            }
                        }
                    )
                    .keyboardType(.numberPad)
                    .toolbar {
                        if textFieldInFocus == .securityCode {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button {
                                    textFieldInFocus = nil
                                    viewModel.cardDetailsFormManager.endEditing()
                                } label: {
                                    Text("Done")
                                        .customFont(.body)
                                        .foregroundColor(.primaryColor)
                                }
                            }
                        }
                    }
                    .onConditionalKeyPress(key: .tab, action: {
                        let collectCardholderName = viewModel.config.collectCardholderName
                        textFieldInFocus = collectCardholderName ? .cardholderName : .cardNumber
                        viewModel.cardDetailsFormManager.setEditingTextField(focusedField: collectCardholderName ? .cardholderName : .cardNumber)
                    })
                    .focused($textFieldInFocus, equals: .securityCode)
                    .onChange(of: viewModel.cardDetailsFormManager.securityCodeText) { newValue in
                        viewModel.cardDetailsFormManager.formatSecurityCode(updatedText: newValue)
                    }
                }
                if viewModel.config.allowSaveCard != nil {
                    privacyView
                }
            }
            
            SDKButton(title: viewModel.config.actionText,
                      isLoading: viewModel.isLoading && viewModel.showLoaders,
                      style: .fill(FillButtonStyle(isDisabled: viewModel.isActionButtonDisabled()))
            ) {
                textFieldInFocus = nil
                viewModel.cardDetailsFormManager.endEditing()
                viewModel.tokeniseCardDetails()
            }
            .padding(.bottom, 16)
            .padding(.top, .spacing)
            .customFont(.body)
            
            emptyFocusView
        }
        .padding(.horizontal, max(16, .spacing))
        .background(Color.backgroundColor)

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
                    .underline()
                    .accentColor(.primaryColor)
                    .disabled(viewModel.viewState.isDisabled)
                    .frame(minHeight: 24.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard let url = URL(string: url) else { return }
                        openURL(url)
                    }
            }
            Spacer()
            Toggle(isOn: $viewModel.policyAccepted) {}
                .tint(.primaryColor)
                .frame(width: 64, height: 44)
                .disabled(viewModel.viewState.isDisabled)
                .accessibilityLabel(viewModel.config.allowSaveCard?.consentText ?? "")
        }
    }
    
    private var emptyFocusView: some View {
        VStack {}
            .conditionalFocusable()
            .focused($isViewFocused)
            .onConditionalKeyPress(key: .tab, action: {
                let collectCardholderName = viewModel.config.collectCardholderName
                textFieldInFocus = collectCardholderName ? .cardholderName : .cardNumber
                viewModel.cardDetailsFormManager.setEditingTextField(focusedField: collectCardholderName ? .cardholderName : .cardNumber)
            })
            .onAppear {
                isViewFocused = true
            }
    }
    
    private func getSchemeIcon(for scheme: CardScheme) -> Image {
        switch scheme {
        case .amex: Image("american-express", bundle: Bundle.module)
        case .ausbc: Image("australian-commonwealth-bank", bundle: Bundle.module)
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
    
    // MARK: - Autofill
    
    private func getCreditCardName() -> UITextContentType {
        if #available(iOS 17.0, *) {
            return .creditCardName
        } else {
            return .name
        }
    }
    
    private func getCreditCardExpiryDate() -> UITextContentType? {
        if #available(iOS 17.0, *) {
            return .creditCardExpiration
        } else {
            return .none
        }
    }
    
    private func getCreditCardSecurityCode() -> UITextContentType? {
        if #available(iOS 17.0, *) {
            return .creditCardSecurityCode
        } else {
            return .none
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidget(config: CardDetailsWidgetConfig(gatewayId: "", accessToken: ""), completion: { _ in })
            .previewLayout(.sizeThatFits)
    }
}
