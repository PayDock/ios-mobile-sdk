//
//  NSError+WebViewMessage.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

extension NSError {

    /// True when the error is a cancelled/interrupted navigation (e.g. user navigated away or a new load started).
    /// Callers should ignore in WKNavigationDelegate didFail / didFailProvisionalNavigation to avoid showing an error.
    public var isWebViewNavigationCancellation: Bool {
        if domain == NSURLErrorDomain && code == NSURLErrorCancelled { return true }
        // Frame load interrupted – load superseded by another navigation (WebKit)
        if domain == "WebKitErrorDomain" && code == 102 { return true }
        return false
    }

    /// Maps WebView NSError (e.g. from WKNavigationDelegate) to a specific user-facing description.
    /// Handles NSURLErrorDomain codes so timeout, connection lost, and offline show clear messages.
    /// Use for Zip, Coles Pay, ClickToPay, 3DS and other WebView-based widgets.
    ///
    /// - Parameter fallback: Message when error is not a known URL error (e.g. "Zip WebView widget has failed").
    /// - Returns: Specific message for known codes, or "\(fallback): \(localizedDescription)" when detail exists.
    public func webViewFailureMessage(fallback: String) -> String {
        if domain == NSURLErrorDomain {
            switch code {
            case NSURLErrorTimedOut:
                return "The request timed out. Please check your connection and try again."
            case NSURLErrorNetworkConnectionLost:
                return "The network connection was lost. Please try again."
            case NSURLErrorNotConnectedToInternet:
                return "The Internet connection appears to be offline. Please check your network."
            case NSURLErrorCannotFindHost:
                return "The server could not be found. Please check the address and try again."
            case NSURLErrorCannotConnectToHost:
                return "Could not connect to the server. Please try again."
            case NSURLErrorSecureConnectionFailed:
                return "A secure connection could not be established. Please try again."
            case NSURLErrorCancelled:
                return "The request was cancelled."
            case NSURLErrorInternationalRoamingOff:
                return "Data roaming is off. Please enable it or connect to Wi‑Fi."
            case NSURLErrorDataNotAllowed:
                return "Cellular data is not allowed for this app. Please use Wi‑Fi or enable data."
            default:
                break
            }
        }

        let detail = localizedDescription
        if detail.isEmpty { return fallback }
        return "\(fallback): \(detail)"
    }
}
