//
//  Standalone3DSError.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//  Created by Domagoj Grizelj on 24.02.2025..
//

import Foundation

public enum Standalone3DSError: Error {
    case webViewFailed(error: NSError)
    case invalidToken
    case unknownError
    
    public var customMessage: String {
        switch self {
        case .webViewFailed: return "3DS WebView widget has failed"
        case .invalidToken: return "Provided 3DS token is not valid"
        case .unknownError: return "Unknown error"
        }
    }
}
