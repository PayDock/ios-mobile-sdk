//
//  PaymentAttempt.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// One payment attempt the widget holds from its start until it finishes it.
struct PaymentAttempt: Equatable {
    let widget: SdkWidget
    let id: String            // UUID().uuidString.lowercased()
    /// D25: the 3DS charge id, once known; never changed after.
    var charge3dsId: String?
}

/// How an attempt ended, as the widget sees it.
enum PaymentEnd {
    case success, declined, cancelled
    /// error; the code is SdkErrorFacts.code(error) (the merchant's WidgetError code, a SilentFailure's own code).
    case failed(any Error)
    /// error the merchant receives as a result, not as an error: a fixed code, Android's name for the same event
    /// (standalone 3DS chargeError → "CHARGE_ERROR").
    case failedWithCode(String)
}
