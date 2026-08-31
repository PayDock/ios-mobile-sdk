//
//  ApplePayAvailabilityChecking.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import PassKit

/// Abstraction over the Apple Pay availability checks so `ApplePayVM`'s gating/setup logic can be
/// unit-tested with a fake. The default implementation wraps the same PassKit / `MobileSDK` calls
/// used previously, so behaviour is unchanged in production.
protocol ApplePayAvailabilityChecking {
    /// Hardware supports Apple Pay (regardless of enrolled cards).
    func deviceSupportsApplePay() -> Bool
    /// A card for a default supported network is already enrolled (networks only, no capability filter).
    func canMakePaymentsWithDefaultNetworks() -> Bool
    /// Enrolled cards satisfy the request's networks and capabilities.
    func canMakePayments(for request: PKPaymentRequest) -> Bool
}

/// Production availability checker — delegates to PassKit / `MobileSDK` statics.
struct DefaultApplePayAvailabilityChecker: ApplePayAvailabilityChecking {
    func deviceSupportsApplePay() -> Bool {
        MobileSDK.deviceSupportsApplePay()
    }

    func canMakePaymentsWithDefaultNetworks() -> Bool {
        PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: [.visa, .masterCard, .amex, .discover, .JCB, .chinaUnionPay]
        )
    }

    func canMakePayments(for request: PKPaymentRequest) -> Bool {
        MobileSDK.canMakeApplePayPayments(for: request)
    }
}
