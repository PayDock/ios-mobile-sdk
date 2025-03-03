//
//  File.swift
//  
//
//  Created by Ricardo Da Silva on 2024/08/20.
//

import Foundation

public enum ClickToPayError: Error {
    case webViewFailed(error: NSError)
    case unknownError
    
    public var customMessage: String {
        switch self {
        case .webViewFailed: return "ClickToPay WebView widget has failed"
        case .unknownError: return "Unknown error"
        }
    }
}
