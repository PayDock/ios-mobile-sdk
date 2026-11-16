//
//  ClientSdkPage.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
@preconcurrency import WebKit

/// Pieces shared by the widget pages that run the Client SDK (Click to Pay, MPGS 3DS, standalone 3DS): the load guard
/// that reports a missing Client SDK over the `PayDockMobileSDK` bridge, and the error each widget ends with.
enum ClientSdkPage {

    /// Posted by the page itself (not the Client SDK) when the Client SDK script fails to load, or loads without
    /// providing the Client SDK global (e.g. the address answers with an HTML page).
    static let loadFailedEvent = "clientSdkLoadFailed"

    /// Error domain of ``loadFailedError(host:)``.
    static let errorDomain = "com.paydock.mobilesdk.ClientSdk"

    /// Code of ``loadFailedError(host:)`` in ``errorDomain``.
    static let loadFailedCode = 1

    /// The guard function, the Client SDK script tag whose `onerror` calls it, then `inlineScript`, which runs only
    /// when the Client SDK global exists and calls the guard otherwise. The guard reports at most once per page and
    /// never throws.
    static func scripts(clientSdkUrl: String, inlineScript: String) -> String {
        """
        <script>
            var clientSdkLoadFailedReported = false;
            function onClientSdkLoadFailed() {
                if (clientSdkLoadFailedReported) {
                    return;
                }
                clientSdkLoadFailedReported = true;
                try {
                    window.webkit.messageHandlers.PayDockMobileSDK.postMessage({ event: "\(loadFailedEvent)" });
                } catch (e) {
                    console.error(e);
                }
            }
        </script>
        <script src="\(clientSdkUrl)" onerror="onClientSdkLoadFailed()"></script>
        <script>
            if (typeof window.\(Constants.clientSdkType) === "undefined") {
                onClientSdkLoadFailed();
            } else {
        \(inlineScript)
            }
        </script>
        """
    }

    /// Whether a bridge message is the page's ``loadFailedEvent`` report.
    static func isLoadFailed(_ body: Any) -> Bool {
        (body as? [String: Any])?["event"] as? String == loadFailedEvent
    }

    /// The error a widget ends with when its page reports ``loadFailedEvent``.
    static func loadFailedError(host: String?) -> NSError {
        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: "Failed to load the payment page. Please try again later."
        ]
        if let host { userInfo["PaydockClientSdkHost"] = host }
        return NSError(domain: errorDomain, code: loadFailedCode, userInfo: userInfo)
    }
}

/// Reads the Client SDK version a widget page loaded. Widgets load an alias of the supported line (or a pinned
/// release), so the version is known only once the script has run: the Client SDK reports it on its global.
enum ClientSdkVersionReader {

    /// The Client SDK's version accessor; `null` or `undefined` when the global is missing or has no accessor.
    static let versionScript = "window.paydock && window.paydock.version"

    /// Evaluates ``versionScript`` in `webView` and records a reported version on ``MobileSDK/loadedClientSdkVersion``.
    /// Call it once the page has finished loading.
    @MainActor
    static func read(_ webView: WKWebView) {
        webView.evaluateJavaScript(versionScript) { result, _ in
            MobileSDK.shared.recordLoadedClientSdkVersion(parse(result))
        }
    }

    /// Only a non-empty string is a version; anything else gives `nil`.
    static func parse(_ result: Any?) -> String? {
        guard let version = result as? String, !version.isEmpty else { return nil }
        return version
    }
}
