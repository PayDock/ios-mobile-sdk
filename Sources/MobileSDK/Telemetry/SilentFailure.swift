//
//  SilentFailure.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// A failure the SDK swallows today (R_06): reported, never delivered.
enum SilentFailure: Error, TelemetryErrorFacts {
    case cardExpiryUnreadable                      // CARD_EXPIRY_UNREADABLE
    case afterpayConfigurationFailed               // AFTERPAY_CONFIGURATION_FAILED
    case afterpayNoPresenter                       // AFTERPAY_NO_PRESENTER
    case afterpayCancelWithoutChargeId             // AFTERPAY_CANCEL_WITHOUT_CHARGE_ID
    case colesPayMessageUnreadable                 // COLES_PAY_MESSAGE_UNREADABLE
    case clickToPayMessageUnreadable               // CLICK_TO_PAY_MESSAGE_UNREADABLE
    case clickToPayTokenMissing                    // CLICK_TO_PAY_TOKEN_MISSING
    case clickToPayCheckoutError                   // CLICK_TO_PAY_CHECKOUT_ERROR
    case clickToPayMetaEncodingFailed(any Error)   // CLICK_TO_PAY_META_ENCODING_FAILED
    case addressSearchFailed(any Error)            // ADDRESS_SEARCH_FAILED
    case addressReverseGeocodeFailed(any Error)    // ADDRESS_REVERSE_GEOCODE_FAILED
    case addressCompleterFailed(any Error)         // ADDRESS_COMPLETER_FAILED

    var telemetryCode: String? {
        switch self {
        case .cardExpiryUnreadable: return "CARD_EXPIRY_UNREADABLE"
        case .afterpayConfigurationFailed: return "AFTERPAY_CONFIGURATION_FAILED"
        case .afterpayNoPresenter: return "AFTERPAY_NO_PRESENTER"
        case .afterpayCancelWithoutChargeId: return "AFTERPAY_CANCEL_WITHOUT_CHARGE_ID"
        case .colesPayMessageUnreadable: return "COLES_PAY_MESSAGE_UNREADABLE"
        case .clickToPayMessageUnreadable: return "CLICK_TO_PAY_MESSAGE_UNREADABLE"
        case .clickToPayTokenMissing: return "CLICK_TO_PAY_TOKEN_MISSING"
        case .clickToPayCheckoutError: return "CLICK_TO_PAY_CHECKOUT_ERROR"
        case .clickToPayMetaEncodingFailed: return "CLICK_TO_PAY_META_ENCODING_FAILED"
        case .addressSearchFailed: return "ADDRESS_SEARCH_FAILED"
        case .addressReverseGeocodeFailed: return "ADDRESS_REVERSE_GEOCODE_FAILED"
        case .addressCompleterFailed: return "ADDRESS_COMPLETER_FAILED"
        }
    }

    var telemetryCause: (any Error)? {
        switch self {
        case .cardExpiryUnreadable, .afterpayConfigurationFailed, .afterpayNoPresenter, .afterpayCancelWithoutChargeId,
             .colesPayMessageUnreadable, .clickToPayMessageUnreadable, .clickToPayTokenMissing, .clickToPayCheckoutError:
            return nil
        case let .clickToPayMetaEncodingFailed(error), let .addressSearchFailed(error),
             let .addressReverseGeocodeFailed(error), let .addressCompleterFailed(error):
            return error
        }
    }

    var isRequestCaused: Bool { false }

    var isOutcome: Bool { false }
}
