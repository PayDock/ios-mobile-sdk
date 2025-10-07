//
//  ColesPayError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 17.01.2024..
//

import Foundation
import NetworkingLib

public enum ColesPayError: Error {

    case errorFetchingColesPayOrder(error: ErrorRes)
    case colesPayUrlError
    case webViewFailed(error: NSError)
    case transactionCanceled
    case initialisingWalletToken(reason: String)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .errorFetchingColesPayOrder: return "Unable to fetch Coles Pay widget order ID"
        case .colesPayUrlError: return "Failure trying to generate Coles Pay URL"
        case .webViewFailed: return "Coles Pay WebView widget has failed"
        case .transactionCanceled: return "Coles Pay transaction was canceled."
        case .initialisingWalletToken(let reason): return reason
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
