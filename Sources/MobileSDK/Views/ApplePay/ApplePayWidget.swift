//
//  ApplePayWidget.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import PassKit

public struct ApplePayWidget: View {
    @StateObject private var viewModel: ApplePayVM
    let appearance: ApplePayWidgetAppearance

    /// Initializes the Apple Pay widget
    /// - Parameters:
    ///   - config: Configuration containing payment request, service ID, and access token
    ///   - appearance: Optional appearance configuration for the button
    ///   - eventDelegate: Optional delegate for widget events
    ///   - onShippingContactSelected: Optional delegate used to handle update shipping contact information
    ///   - onShippingMethodSelected: Optional delegate used to handle user selection of different shipping methods
    ///   - completion: Completion handler returning the Paydock OTT token on success
    public init(config: ApplePayWidgetConfig,
                appearance: ApplePayWidgetAppearance = ApplePayWidgetAppearance(),
                eventDelegate: WidgetEventDelegate? = nil,
                onShippingContactSelected: ((PKContact) -> PKPaymentRequestShippingContactUpdate)? = nil,
                onShippingMethodSelected: ((PKShippingMethod) -> PKPaymentRequestShippingMethodUpdate)? = nil,
                completion: @escaping (Result<ApplePayResult, ApplePayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            onShippingContactSelected: onShippingContactSelected,
            onShippingMethodSelected: onShippingMethodSelected,
            completion: completion)
        )
        self.appearance = appearance
    }

    public var body: some View {
        // When availability checks are disabled the integrator has already verified support
        // (e.g. via MobileSDK.canMakeApplePayPayments(...)), so render the pay button directly
        // and skip the internal gating/setup-button/error path.
        if !viewModel.availabilityChecksEnabled || viewModel.canMakePaymentsWithConfiguredNetworksAndCapabilities() {
            ApplePayButton(
                appearance: appearance,
                isDisabled: viewModel.isProcessing
            ) {
                viewModel.startPayment()
                viewModel.handleApplePayTapAnalytics()
            }
        } else if viewModel.shouldShowSetupButton() {
            // Open Wallet for card enrollment — do NOT run the payment flow
            ApplePaySetupWidget(appearance: appearance)
        }
    }
}

struct ApplePayWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidget(
            config: ApplePayWidgetConfig(
                serviceId: "test-service-id",
                accessToken: "test-token",
                pkPaymentRequest: .init(),
                showSetUpButtonWhenNoCardsEnrolled: false
            ),
            completion: { _ in }
        )
    }
}
