//
//  ZipWebView.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

@preconcurrency import WebKit
import SwiftUI

struct ZipWebView: UIViewRepresentable {

    typealias OnApprove = (_ callbackData: ZipCallbackData) -> Void
    typealias OnFailure = (_ zipError: ZipError) -> Void

    static private let callbackHost = Constants.zipCallbackHost
    static private let responsePath = "/zip/response"

    /// When true, target="_blank" links load in the current WebView instead of opening a new window.
    static private let openInSameWindowScript = """
    (function() {
        var origOpen = window.open;
        window.open = function(url, target, features) {
            if (!target || String(target) === '_blank') {
                if (url) window.location.href = url;
                return null;
            }
            return origOpen ? origOpen.call(window, url, target, features) : null;
        };
        document.addEventListener('click', function(e) {
            var findA = function(n) { while (n && n !== document) { if (n.tagName === 'A') return n; n = n.parentNode; } return null; };
            var a = e.target && (e.target.closest ? e.target.closest('a') : findA(e.target));
            if (a && (a.target === '_blank' || a.getAttribute('target') === '_blank')) {
                e.preventDefault();
                e.stopPropagation();
                if (a.href) window.location.href = a.href;
            }
        }, true);
    })();
    """

    private let url: URL
    private let openTargetBlankInSameWebView: Bool
    private let onApprove: OnApprove
    private let onFailure: OnFailure

    init(
        url: URL,
        openTargetBlankInSameWebView: Bool = true,
        onApprove: @escaping OnApprove,
        onFailure: @escaping OnFailure
    ) {
        self.url = url
        self.openTargetBlankInSameWebView = openTargetBlankInSameWebView
        self.onApprove = onApprove
        self.onFailure = onFailure
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        if openTargetBlankInSameWebView {
            webView.uiDelegate = context.coordinator
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            // Load the Zip checkout URL directly - no need to modify it
            webView.load(.init(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        .init(
            openTargetBlankInSameWebView: openTargetBlankInSameWebView,
            onApprove: onApprove,
            onFailure: onFailure
        )
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var openTargetBlankInSameWebView: Bool
        var onApprove: OnApprove
        var onFailure: OnFailure
        var isLoaded = false

        init(
            openTargetBlankInSameWebView: Bool,
            onApprove: @escaping OnApprove,
            onFailure: @escaping OnFailure
        ) {
            self.openTargetBlankInSameWebView = openTargetBlankInSameWebView
            self.onApprove = onApprove
            self.onFailure = onFailure
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                isLoaded = true
                if openTargetBlankInSameWebView {
                    webView.evaluateJavaScript(ZipWebView.openInSameWindowScript, completionHandler: nil)
                }
            }
        }

        /// When `openTargetBlankInSameWebView` is true, load target="_blank" / window.open
        /// requests in the current WebView instead of opening a new window.
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard openTargetBlankInSameWebView,
                  let url = navigationAction.request.url else {
                return nil
            }
            webView.load(URLRequest(url: url))
            return nil
        }

        /**
         This method handles errors that are reported that happen while loading the resource.
         These are usually errors caused by the content of the page, like invalid code in the page itself that the parser can't handle.
         **/
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.isWebViewNavigationCancellation { return }
            Task { @MainActor in
                onFailure(.webViewFailed(error: nsError))
            }
        }

        /**
         This method handles errors that happen before the resource of the url can even be reached.
         These errors are mostly related to connectivity, the formatting of the url, or if using urls which are not supported.
         
         @see https://developer.apple.com/documentation/cfnetwork/cfnetworkerrors
         */
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.isWebViewNavigationCancellation { return }
            Task { @MainActor in
                onFailure(.webViewFailed(error: nsError))
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in
                guard let webUrl = webView.url else { return }

                let path = webUrl.path()

                // Check if this is a callback URL by looking for /merchant/callback path
                // Zip uses this path on their domain with result and checkoutId in query params
                if path.contains("/merchant/callback") {
                    let params = parseQueryParameters(from: webUrl)
                    // Only process if we have a result parameter (indicates this is the callback with status)
                    if params["result"] != nil {
                        handleResponse(params: params)
                    }
                }
            }
        }

        /// Parse URL query parameters into a dictionary
        private func parseQueryParameters(from url: URL) -> [String: String] {
            guard let query = url.query() else { return [:] }

            return query
                .split(separator: "&")
                .reduce(into: [:]) { result, queryParam in
                    let parts = String(queryParam).split(separator: "=", maxSplits: 1)
                    if parts.count == 2 {
                        let key = String(parts[0])
                        let value = String(parts[1]).removingPercentEncoding ?? String(parts[1])
                        result[key] = value
                    }
                }
        }

        func webView(
            _ webView: WKWebView,
            authenticationChallenge challenge: URLAuthenticationChallenge,
            shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void
        ) {
            // Reject deprecated TLS versions for PCI DSS compliance
            decisionHandler(false)
        }

        func webView(
            _ webView: WKWebView,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            // Use default system SSL certificate validation for PCI DSS compliance
            // This ensures proper certificate chain validation against system trust store
            completionHandler(.performDefaultHandling, nil)
        }

        // MARK: - Helpers

        /// Handle response callback with 'result' status parameter
        private func handleResponse(params: [String: String]) {
            Task { @MainActor in
                // Extract status and checkoutId from query parameters
                guard let resultString = params["result"] else {
                    onFailure(.unexpectedStatus(status: nil, checkoutId: params["checkoutId"]))
                    return
                }

                guard let status = ZipStatus(rawValue: resultString) else {
                    onFailure(.unexpectedStatus(status: resultString, checkoutId: params["checkoutId"]))
                    return
                }

                let checkoutId = params["checkoutId"]
                let orderId = params["order_id"] ?? params["id"]

                // Handle based on status (matching web implementation logic)
                switch status {
                case .approved:
                    // Success flow
                    let callbackData = ZipCallbackData(
                        status: status,
                        checkoutId: checkoutId,
                        orderId: orderId
                    )
                    onApprove(callbackData)

                case .declined:
                    onFailure(.transactionDeclined(checkoutId: checkoutId))

                case .cancelled:
                    onFailure(.transactionCanceled(checkoutId: checkoutId))

                case .referred:
                    onFailure(.transactionReferred(checkoutId: checkoutId))

                case .unexpected, .unexpectedError:
                    onFailure(.unexpectedStatus(status: resultString, checkoutId: checkoutId))
                }
            }
        }
    }
}
