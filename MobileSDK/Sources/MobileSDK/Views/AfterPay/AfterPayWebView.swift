//
//  AfterPayWebView.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.01.2024..
//

import SwiftUI
import WebKit
import AuthenticationServices

struct AfterPayWebView: UIViewRepresentable {

    typealias OnApprove = () -> Void
    typealias OnFailure = (AfterPayError) -> Void

    private let afterPayOrderId: String
    private let onApprove: OnApprove
    private let onFailure: OnFailure

    init(afterPayOrderId: String, onApprove: @escaping OnApprove, onFailure: @escaping OnFailure) {
        self.afterPayOrderId = afterPayOrderId
        self.onApprove = onApprove
        self.onFailure = onFailure
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")

        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            guard let urlRequest = getAfterPayUrlRequest() else {
                onFailure(.webViewFailed)
                return
            }
            webView.load(urlRequest)
        }
    }

    private func getAfterPayUrlRequest() -> URLRequest? {
        let urlString: String = {
            switch MobileSDK.shared.config?.environment {
            case .production, .staging, .sandbox: return "https://portal.sandbox.afterpay.com/au/checkout/?token=\(afterPayOrderId)"
            case .none: return ""
            }
        }()
        guard let url = URL(string: urlString) else {
            return nil
        }
        return URLRequest(url: url)
    }

    func makeCoordinator() -> Coordinator {
        .init(onApprove: onApprove, onFailure: onFailure)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

        var onApprove: OnApprove
        var onFailure: OnFailure
        var isLoaded = false
        private let redirectUrlString = "https://paydock.sdk/"

        init(onApprove: @escaping OnApprove,
             onFailure: @escaping OnFailure) {
            self.onApprove = onApprove
            self.onFailure = onFailure
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print(webView.url)
            decisionHandler(.allow)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if webView.url?.host() == URL(string: redirectUrlString)?.host() {
                onApprove()
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        }

        func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
            decisionHandler(true)
        }

        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
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
