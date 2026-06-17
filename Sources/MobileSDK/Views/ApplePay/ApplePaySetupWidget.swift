//
//  ApplePaySetupWidget.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import PassKit

/// A widget that renders an Apple Pay "Set Up" button.
///
/// Tapping it opens the Wallet via `PKPassLibrary().openPaymentSetup()` so the user can add a
/// card. Use this when you want to offer Apple Pay card enrollment yourself — for example when
/// `MobileSDK.deviceSupportsApplePay()` is `true` but `MobileSDK.canMakeApplePayPayments(...)`
/// is `false` (the device supports Apple Pay but has no eligible card enrolled).
///
/// This is the same button `ApplePayWidget` shows internally when
/// `showSetUpButtonWhenNoCardsEnrolled` is enabled, exposed here for standalone use.
public struct ApplePaySetupWidget: View {

    private let appearance: ApplePayWidgetAppearance

    /// Initializes the Apple Pay setup widget.
    /// - Parameter appearance: Optional appearance for the button. The button type is always
    ///   forced to `.setUp`; the `style` and `cornerRadius` are honoured.
    public init(appearance: ApplePayWidgetAppearance = ApplePayWidgetAppearance()) {
        var setUpAppearance = appearance
        setUpAppearance.type = .setUp
        self.appearance = setUpAppearance
    }

    public var body: some View {
        // Open Wallet for card enrollment — this does NOT run any payment flow.
        ApplePayButton(
            appearance: appearance,
            isDisabled: false
        ) {
            PKPassLibrary().openPaymentSetup()
        }
    }
}

struct ApplePaySetupWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApplePaySetupWidget()
            .previewLayout(.sizeThatFits)
    }
}
