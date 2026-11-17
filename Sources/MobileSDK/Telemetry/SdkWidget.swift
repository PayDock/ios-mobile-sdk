//
//  SdkWidget.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// `paydock.widget` names (R_10); a widget both platforms have uses Android's name.
enum SdkWidget: String, CaseIterable {
    case cardDetails = "CardDetailsWidget"
    case giftCard = "GiftCardWidget"
    case address = "AddressDetailsWidget"
    case applePay = "ApplePayWidget"
    case applePaySetup = "ApplePaySetupWidget"
    case afterpay = "AfterpayWidget"
    case payPal = "PayPalWidget"
    case payPalSavePaymentSource = "PayPalSavePaymentSourceWidget"
    case zip = "ZipWidget"
    case colesPay = "ColesPayWidget"
    case clickToPay = "ClickToPayWidget"
    case mpgs3ds = "MPGS3dsWidget"
    case standalone3ds = "Standalone3DSWidget"
}
