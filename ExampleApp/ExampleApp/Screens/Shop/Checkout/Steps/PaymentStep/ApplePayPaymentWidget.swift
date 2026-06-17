//
//  ApplePayPaymentWidget.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import SwiftUI
import MobileSDK

struct ApplePayPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    /// Check Apple Pay availability up front, before initialising the widget.
    ///
    /// `MobileSDK.deviceSupportsApplePay()` confirms the hardware supports Apple Pay, and
    /// `MobileSDK.canMakeApplePayPayments(for:)` confirms there's an enrolled card matching the
    /// payment request's networks and capabilities. Because we've done these checks here, the
    /// widget's config sets `performAvailabilityChecks: false` so it doesn't repeat them.
    private var isApplePayAvailable: Bool {
        MobileSDK.deviceSupportsApplePay()
            && MobileSDK.canMakeApplePayPayments(for: viewModel.applePayConfig.pkPaymentRequest)
    }

    var body: some View {
        // Only offer Apple Pay when it's actually available on this device/wallet.
        if isApplePayAvailable {
            ApplePayWidget(
                config: viewModel.applePayConfig,
                onShippingContactSelected: { contact in
                    viewModel.handleApplePayShippingContactSelected(contact)
                },
                onShippingMethodSelected: { method in
                    viewModel.handleApplePayShippingMethodSelected(method)
                },
                completion: { result in
                    viewModel.handleApplePayResult(result)
                }
            )
            .frame(height: 50)
        }
    }
}
