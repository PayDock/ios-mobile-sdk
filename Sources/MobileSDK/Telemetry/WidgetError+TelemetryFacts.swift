//
//  WidgetError+TelemetryFacts.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

// Each widget error type's facts, one exhaustive switch per fact (no `default`), so a new case is a compile error
// until it is classified. A case holding an `ErrorRes` is request-caused and has no cause; `unknownError` is
// request-caused when it holds a `RequestError`, which is then its cause.

extension CardDetailsError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .errorTokenisingCard: return nil
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .errorTokenisingCard: return true
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .errorTokenisingCard, .unknownError: return false
        }
    }
}

extension GiftCardError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .errorTokenisingCard: return nil
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .errorTokenisingCard: return true
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .errorTokenisingCard, .unknownError: return false
        }
    }
}

extension AfterpayError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .errorFetchingAfterpayUrl, .errorCapturingCharge, .errorCancelingTransaction, .transactionCanceled,
             .initialisingWalletToken:
            return nil
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .errorFetchingAfterpayUrl, .errorCapturingCharge, .errorCancelingTransaction: return true
        case .transactionCanceled, .initialisingWalletToken: return false
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .transactionCanceled: return true
        case .errorFetchingAfterpayUrl, .errorCapturingCharge, .errorCancelingTransaction, .initialisingWalletToken,
             .unknownError:
            return false
        }
    }
}

extension ApplePayError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .notSupported, .noSupportedCardsInWallet, .errorCreatingToken, .userCanceledPayment,
             .unableToPresentPaymentSheet, .payloadEncodingFailed:
            return nil
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .errorCreatingToken: return true
        case .notSupported, .noSupportedCardsInWallet, .userCanceledPayment, .unableToPresentPaymentSheet,
             .payloadEncodingFailed:
            return false
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .userCanceledPayment: return true
        case .notSupported, .noSupportedCardsInWallet, .errorCreatingToken, .unableToPresentPaymentSheet,
             .payloadEncodingFailed, .unknownError:
            return false
        }
    }
}

extension ClickToPayError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case let .webViewFailed(nsError): return nsError
        case .unknownError: return nil
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .webViewFailed, .unknownError: return false
        }
    }

    var isOutcome: Bool {
        switch self {
        case .webViewFailed, .unknownError: return false
        }
    }
}

extension ColesPayError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .errorFetchingColesPayOrder, .colesPayUrlError, .transactionCanceled, .initialisingWalletToken: return nil
        case let .webViewFailed(nsError): return nsError
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .errorFetchingColesPayOrder: return true
        case .colesPayUrlError, .webViewFailed, .transactionCanceled, .initialisingWalletToken: return false
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .transactionCanceled: return true
        case .errorFetchingColesPayOrder, .colesPayUrlError, .webViewFailed, .initialisingWalletToken, .unknownError:
            return false
        }
    }
}

extension MPGS3dsError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case let .webViewFailed(nsError): return nsError
        case .invalidToken, .mappingFailed: return nil
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .webViewFailed, .invalidToken, .mappingFailed: return false
        }
    }

    var isOutcome: Bool {
        switch self {
        case .webViewFailed, .invalidToken, .mappingFailed: return false
        }
    }
}

extension Standalone3DSError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case let .webViewFailed(nsError): return nsError
        case .invalidToken, .mappingFailed: return nil
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .webViewFailed, .invalidToken, .mappingFailed: return false
        }
    }

    var isOutcome: Bool {
        switch self {
        case .webViewFailed, .invalidToken, .mappingFailed: return false
        }
    }
}

extension PayPalError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .getPayPalClientId, .errorFetchingOrderId, .errorCapturingCharge, .userCancelled, .initialisingWalletToken,
             .sdkException:
            return nil
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .getPayPalClientId, .errorFetchingOrderId, .errorCapturingCharge: return true
        case .userCancelled, .initialisingWalletToken, .sdkException: return false
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .userCancelled: return true
        case .getPayPalClientId, .errorFetchingOrderId, .errorCapturingCharge, .initialisingWalletToken, .sdkException,
             .unknownError:
            return false
        }
    }
}

extension PayPalVaultError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .createSetupToken, .getPayPalClientId, .createPaymentToken, .sdkException, .userCancelled: return nil
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .createSetupToken, .getPayPalClientId, .createPaymentToken: return true
        case .sdkException, .userCancelled: return false
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .userCancelled: return true
        case .createSetupToken, .getPayPalClientId, .createPaymentToken, .sdkException, .unknownError: return false
        }
    }
}

extension ZipError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .errorFetchingZipUrl, .errorCapturingCharge, .invalidCheckoutUrl, .transactionCanceled,
             .transactionDeclined, .transactionReferred, .unexpectedStatus, .initialisingWalletToken:
            return nil
        case let .webViewFailed(nsError): return nsError
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .errorFetchingZipUrl, .errorCapturingCharge: return true
        case .invalidCheckoutUrl, .webViewFailed, .transactionCanceled, .transactionDeclined, .transactionReferred,
             .unexpectedStatus, .initialisingWalletToken:
            return false
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .transactionCanceled, .transactionDeclined, .transactionReferred: return true
        case .errorFetchingZipUrl, .errorCapturingCharge, .invalidCheckoutUrl, .webViewFailed, .unexpectedStatus,
             .initialisingWalletToken, .unknownError:
            return false
        }
    }
}

extension PayPalDataCollectorError: TelemetryErrorFacts {
    var telemetryCause: (any Error)? {
        switch self {
        case .initialisationClientId, .parsingError: return nil
        case let .unknownError(requestError): return requestError
        }
    }

    var isRequestCaused: Bool {
        switch self {
        case .initialisationClientId: return true
        case .parsingError: return false
        case let .unknownError(requestError): return requestError != nil
        }
    }

    var isOutcome: Bool {
        switch self {
        case .initialisationClientId, .parsingError, .unknownError: return false
        }
    }
}
