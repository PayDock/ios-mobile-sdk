//
//  EnhancedCheckoutView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct EnhancedCheckoutView: View {
    @StateObject private var cartManager = CartManager.shared
    @StateObject private var profileManager = UserProfileManager.shared
    @StateObject private var viewModel = EnhancedCheckoutVM()
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: CheckoutStep = .information
    @State private var showingAddressWidget = false
    @State private var addressWidgetType: AddressWidgetType = .shipping
    @State private var isEditingExistingAddress = false

    /// Optional closure to dismiss parent view (like CartView) after successful checkout
    let onDismissParent: (() -> Void)?

    init(onDismissParent: (() -> Void)? = nil) {
        self.onDismissParent = onDismissParent
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    CheckoutProgressIndicator(currentStep: currentStep)

                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            switch currentStep {
                            case .information:
                                CheckoutInformationStepView(
                                    viewModel: viewModel,
                                    profileManager: profileManager,
                                    onLoadProfileData: loadProfileData,
                                    onSelectSavedAddress: selectSavedAddress,
                                    onClearShippingAddress: clearShippingAddress,
                                    onClearBillingAddress: clearBillingAddress,
                                    onEnterNewAddress: enterNewAddress,
                                    onEditExistingAddress: editExistingAddress
                                )
                            case .paymentAndReview:
                                CheckoutPaymentAndReviewStepView(
                                    viewModel: viewModel,
                                    cartManager: cartManager,
                                    currentStep: $currentStep
                                )
                            }

                            // Add bottom padding to account for fixed buttons
                            Spacer()
                                .frame(height: 100)
                        }
                        .padding()
                    }
                    .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
                }

                // Fixed Action Buttons at bottom
                VStack {
                    Spacer()
                    CheckoutActionButtons(
                        currentStep: currentStep,
                        canProceed: canProceed,
                        onBack: {
                            withAnimation {
                                goToPreviousStep()
                            }
                        },
                        onAction: {
                            withAnimation {
                                handleActionButton()
                            }
                        }
                    )
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("Cancel Checkout")
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {
                Button("OK") {
                    if viewModel.orderCompleted {
                        cartManager.clearCart()
                        dismiss()
                        // Also dismiss parent view (CartView) after successful checkout
                        onDismissParent?()
                    }
                }
            }, message: {
                Text(viewModel.alertMessage)
            })
            .sheet(isPresented: $showingAddressWidget) {
                CheckoutAddressWidgetView(
                    type: addressWidgetType,
                    existingAddress: isEditingExistingAddress ? getExistingAddress(for: addressWidgetType) : nil,
                    onAddressSelected: { result in
                        handleAddressResult(result, for: addressWidgetType)
                        showingAddressWidget = false
                    },
                    onCancel: {
                        showingAddressWidget = false
                    }
                )
            }
            .sheet(isPresented: $viewModel.showMPGS3dsWebView, onDismiss: { }, content: {
                NavigationStack {
                    VStack {
                        MPGS3DSWidget(
                            config: .init(token: viewModel.token3DS),
                            completion: { result in
                                switch result {
                                case .success(let result):
                                    viewModel.handleMPGS3dsEvent(result)
                                case .failure(let error):
                                    Task {
                                        viewModel.alertMessage = error.localizedDescription
                                        viewModel.showAlert = true
                                    }
                                }
                            })
                        .navigationTitle("3DS Check")
                        .navigationBarTitleDisplayMode(.inline)

                    }
                }
            })
            .sheet(isPresented: $viewModel.showStandalone3dsWebView, onDismiss: { }, content: {
                NavigationStack {
                    VStack {
                        Standalone3DSWidget(
                            config: .init(token: viewModel.token3DS)) { result in
                                switch result {
                                case let .success(result):
                                    viewModel.handleStandalone3dsEvent(result)
                                case let .failure(error):
                                    viewModel.alertMessage = error.customMessage
                                    viewModel.showAlert = true
                                }
                            }
                        .navigationTitle("3DS Check")
                        .navigationBarTitleDisplayMode(.inline)

                    }
                }
            })
            .onAppear {
                loadProfileData()
            }
        }
        .overlay(
            // Result Overlay
            Group {
                if viewModel.showResultOverlay {
                    CheckoutResultOverlay(
                        isSuccess: viewModel.resultIsSuccess,
                        message: viewModel.resultMessage,
                        onDismiss: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.showResultOverlay = false
                            }
                            if viewModel.resultIsSuccess {
                                cartManager.clearCart()
                                dismiss()
                                // Also dismiss parent view (CartView) after successful checkout
                                onDismissParent?()
                            } else {
                                currentStep = .information
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showResultOverlay)
                    .zIndex(1000)
                }
            }
        )
    }
    // MARK: - Computed Properties

    private var canProceed: Bool {
        switch currentStep {
        case .information:
            return viewModel.isInformationComplete
        case .paymentAndReview:
            return viewModel.selectedPaymentMethod != nil
        }
    }

    // MARK: - Helper Methods

    private func loadProfileData() {
        let profileData = profileManager.populateCheckoutFromProfile()
        viewModel.firstName = profileData.firstName
        viewModel.lastName = profileData.lastName
        viewModel.email = profileData.email
        viewModel.phone = profileData.phone

        if let defaultAddress = profileData.address {
            selectSavedAddress(defaultAddress, for: .shipping)
        }
    }

    private func selectSavedAddress(_ address: SavedAddress, for type: AddressWidgetType) {
        switch type {
        case .shipping:
            viewModel.selectedShippingAddressId = address.id
            viewModel.address = address.addressLine1
            viewModel.addressLine2 = address.addressLine2
            viewModel.city = address.city
            viewModel.state = address.state
            viewModel.postalCode = address.postalCode
            viewModel.country = address.country
        case .billing:
            viewModel.selectedBillingAddressId = address.id
            viewModel.billingAddress = address.addressLine1
            viewModel.billingAddressLine2 = address.addressLine2
            viewModel.billingCity = address.city
            viewModel.billingState = address.state
            viewModel.billingPostalCode = address.postalCode
            viewModel.billingCountry = address.country
        }
    }

    private func clearShippingAddress() {
        viewModel.address = ""
        viewModel.addressLine2 = ""
        viewModel.city = ""
        viewModel.state = ""
        viewModel.postalCode = ""
        viewModel.country = ""
    }

    private func clearBillingAddress() {
        viewModel.billingAddress = ""
        viewModel.billingAddressLine2 = ""
        viewModel.billingCity = ""
        viewModel.billingState = ""
        viewModel.billingPostalCode = ""
        viewModel.billingCountry = ""
    }

    private func getExistingAddress(for type: AddressWidgetType) -> Address? {
        switch type {
        case .shipping:
            return viewModel.getCurrentShippingAddress()
        case .billing:
            return viewModel.getCurrentBillingAddress()
        }
    }

    private func enterNewAddress(_ type: AddressWidgetType) {
        addressWidgetType = type
        isEditingExistingAddress = false
        showingAddressWidget = true
    }

    private func editExistingAddress(_ type: AddressWidgetType) {
        addressWidgetType = type
        isEditingExistingAddress = true
        showingAddressWidget = true
    }

    private func handleAddressResult(_ result: Address, for type: AddressWidgetType) {
        switch type {
        case .shipping:
            viewModel.shippingFirstName = result.firstName
            viewModel.shippingLastName = result.lastName
            viewModel.address = result.addressLine1
            viewModel.addressLine2 = result.addressLine2
            viewModel.city = result.city
            viewModel.state = result.state
            viewModel.postalCode = result.postcode
            viewModel.country = result.country
            // Only deselect the saved address after new address is successfully set
            viewModel.selectedShippingAddressId = nil
        case .billing:
            viewModel.billingFirstName = result.firstName
            viewModel.billingLastName = result.lastName
            viewModel.billingAddress = result.addressLine1
            viewModel.billingAddressLine2 = result.addressLine2
            viewModel.billingCity = result.city
            viewModel.billingState = result.state
            viewModel.billingPostalCode = result.postcode
            viewModel.billingCountry = result.country
            // Only deselect the saved address after new address is successfully set
            viewModel.selectedBillingAddressId = nil
        }
    }

    private func goToPreviousStep() {
        let allCases = CheckoutStep.allCases
        if let currentIndex = allCases.firstIndex(of: currentStep), currentIndex > 0 {
            currentStep = allCases[currentIndex - 1]
        }
    }

    private func handleActionButton() {
        switch currentStep {
        case .information:
            // Save profile data if user wants
            profileManager.saveCheckoutDataToProfile(
                firstName: viewModel.firstName,
                lastName: viewModel.lastName,
                email: viewModel.email,
                phone: viewModel.phone
            )
            currentStep = .paymentAndReview

        case .paymentAndReview: break
        }
    }
}

struct EnhancedCheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedCheckoutView(onDismissParent: nil)
    }
}
