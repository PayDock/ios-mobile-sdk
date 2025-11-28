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

    private let url: URL
    private let onApprove: OnApprove
    private let onFailure: OnFailure

    init(url: URL, onApprove: @escaping OnApprove, onFailure: @escaping OnFailure) {
        self.url = url
        self.onApprove = onApprove
        self.onFailure = onFailure
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            // Load the Zip checkout URL directly - no need to modify it
            webView.load(.init(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        .init(onApprove: onApprove, onFailure: onFailure)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onApprove: OnApprove
        var onFailure: OnFailure
        var isLoaded = false

        init(onApprove: @escaping OnApprove,
             onFailure: @escaping OnFailure) {
            self.onApprove = onApprove
            self.onFailure = onFailure
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
        }

        /**
         This method handles errors that are reported that happen while loading the resource.
         These are usually errors caused by the content of the page, like invalid code in the page itself that the parser can't handle.
         **/
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onFailure(.webViewFailed(error: error as NSError))
        }

        /**
         This method handles errors that happen before the resource of the url can even be reached.
         These errors are mostly related to connectivity, the formatting of the url, or if using urls which are not supported.
         
         @see https://developer.apple.com/documentation/cfnetwork/cfnetworkerrors
         */
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onFailure(.webViewFailed(error: error as NSError))
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
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
            decisionHandler(false)
        }

        func webView(
            _ webView: WKWebView,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            DispatchQueue.global(qos: .background).async {
                let trust = challenge.protectionSpace.serverTrust!
                let exceptions = SecTrustCopyExceptions(trust)
                SecTrustSetExceptions(trust, exceptions)
                completionHandler(.useCredential, URLCredential(trust: trust))
            }
        }

        // MARK: - Helpers

        /// Handle response callback with 'result' status parameter
        private func handleResponse(params: [String: String]) {
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
