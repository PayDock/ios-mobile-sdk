//
//  PayPalWebView.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 26.10.2023..
//

import WebKit
import SwiftUI

struct PayPalWebView: UIViewRepresentable {

    typealias OnApprove = (_ paymentId: String, _ payerId: String) -> Void
    typealias OnFailure = (_ payPalError: PayPalError) -> Void

    static private let callbackHost = Constants.payPalCallbackHost
    static private let callbackPath = "/paypal/success"
    static private let callbackUrl = "https://\(callbackHost)\(callbackPath)"

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
            let redirectQueryItem = URLQueryItem(name: "redirect_uri", value: PayPalWebView.callbackUrl)
            let nativeXOQueryItem = URLQueryItem(name: "native_xo", value: "1")

            var checkoutURLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            checkoutURLComponents?.queryItems?.append(redirectQueryItem)
            checkoutURLComponents?.queryItems?.append(nativeXOQueryItem)

            if let finalUrl = checkoutURLComponents?.url {
                webView.load(.init(url: finalUrl))
            }
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
            guard let webUrl = webView.url,
                  webUrl.host() == PayPalWebView.callbackHost,
                  webUrl.path() == PayPalWebView.callbackPath,
                  let queries = webUrl.query() else { return }

            let params: [String: String] = queries
                .split(separator: "&")
                .reduce(into: [:], { partialResult, query in
                    let parts = String(query).split(separator: "=")
                    partialResult[String(parts[0])] = parts.count > 1 ? String(parts[1]) : ""
                })

            guard let paymentId = params["token"],
                  let payerId = params["PayerID"] else { return }

            onApprove(paymentId, payerId)
        }

        func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
            decisionHandler(false)
        }

        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            DispatchQueue.global(qos: .background).async {
                let trust = challenge.protectionSpace.serverTrust!
                let exceptions = SecTrustCopyExceptions(trust)
                SecTrustSetExceptions(trust, exceptions)
                completionHandler(.useCredential, URLCredential(trust: trust))
            }
        }
    }
}

