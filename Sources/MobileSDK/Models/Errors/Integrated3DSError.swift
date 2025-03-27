//
//  Integrated3DSError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Ricardo Da Silva on 2024/08/19.
//

import Foundation

public enum Integrated3DSError: Error, Equatable {
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
