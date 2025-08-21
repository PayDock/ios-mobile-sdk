//
//  Standalone3DSError.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//  Created by Domagoj Grizelj on 24.02.2025..
//

import Foundation

public enum Standalone3DSError: Error, Equatable {
    case webViewFailed(error: NSError)
    case invalidToken
    case mappingFailed

    public var customMessage: String {
        switch self {
        case .webViewFailed: return "3DS WebView widget has failed"
        case .invalidToken: return "Provided 3DS token is not valid"
        case .mappingFailed: return "3DS response mapping failed"
        }
    }
}
