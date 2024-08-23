//
//  File.swift
//  
//
//  Created by Ricardo Da Silva on 2024/08/19.
//

import Foundation

public enum ThreeDSError: Error {
    case webViewFailed(error: NSError)
    case unknownError
    
    public var customMessage: String {
        switch self {
        case .webViewFailed: return "3DS WebView widget has failed"
        case .unknownError: return "Unknown error"
        }
    }
}
