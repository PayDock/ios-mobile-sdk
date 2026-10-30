//
//  Standalone3DSError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public enum Standalone3DSError: Error, Equatable, WidgetError {
    case webViewFailed(error: NSError)
    case invalidToken
    case mappingFailed

    public var customMessage: String {
        switch self {
        case .webViewFailed(let nsError):
            return nsError.webViewFailureMessage(fallback: "3DS WebView widget has failed")
        case .invalidToken: return "Provided 3DS token is not valid"
        case .mappingFailed: return "3DS response mapping failed"
        }
    }

    public var code: String {
        switch self {
        case .webViewFailed: return "STANDALONE_3DS_WEBVIEW_FAILED"
        case .invalidToken: return "STANDALONE_3DS_INVALID_TOKEN"
        case .mappingFailed: return "STANDALONE_3DS_RESPONSE_MAPPING_FAILED"
        }
    }

    public var debugDescription: String {
        switch self {
        case .webViewFailed(let nsError):
            return "\(code): \(customMessage) [\(nsError.domain) code \(nsError.code)]"
        default:
            return "\(code): \(customMessage)"
        }
    }
}

// MARK: - WebView failure context

public extension Standalone3DSError {

    /// Domain of the `NSError` carried by ``webViewFailed(error:)`` when the widget itself detected the failure
    /// rather than WebKit reporting it.
    static let errorDomain = "com.paydock.mobilesdk.Standalone3DS"

    /// Codes of ``errorDomain``.
    enum ErrorCode: Int {
        /// The Client SDK script the 3DS page runs on failed to load (network error or HTTP error response).
        case clientSdkLoadFailed = 1
    }

    /// `userInfo` keys the widget adds to the `NSError` carried by ``webViewFailed(error:)``.
    enum ContextKey {
        /// The 3DS charge ID of the session (`String`), to look the session up in Paydock.
        public static let charge3dsId = "PaydockStandalone3DSCharge3dsId"
        /// Whether the app was in the background when the failure happened (`Bool`).
        public static let inBackground = "PaydockStandalone3DSInBackground"
        /// Host of the failing request, without path or query (`String`).
        public static let failingHost = "PaydockStandalone3DSFailingHost"
    }

    /// The 3DS charge ID of the failed session, when known.
    var charge3dsId: String? {
        contextError?.userInfo[ContextKey.charge3dsId] as? String
    }

    /// Whether the app was in the background when the WebView failed, when known.
    var inBackground: Bool? {
        contextError?.userInfo[ContextKey.inBackground] as? Bool
    }

    /// Host of the failing request (no path or query), when known.
    var failingHost: String? {
        guard let error = contextError else { return nil }
        if let host = error.userInfo[ContextKey.failingHost] as? String { return host }
        return (error.userInfo[NSURLErrorFailingURLErrorKey] as? URL)?.host
    }

    private var contextError: NSError? {
        guard case .webViewFailed(let error) = self else { return nil }
        return error
    }
}
