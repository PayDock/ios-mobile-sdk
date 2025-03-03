//
//  FlyPayWebView.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI
import WebKit
import AuthenticationServices

struct FlyPayWebView: UIViewRepresentable {

    typealias OnApprove = () -> Void
    typealias OnFailure = (FlyPayError) -> Void

    private let clientId: String
    private let flyPayOrderId: String
    private let onApprove: OnApprove
    private let onFailure: OnFailure

    init(clientId: String, flyPayOrderId: String, onApprove: @escaping OnApprove, onFailure: @escaping OnFailure) {
        self.clientId = clientId
        self.flyPayOrderId = flyPayOrderId
        self.onApprove = onApprove
        self.onFailure = onFailure
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")

        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            guard let urlRequest = getFlyPayUrlRequest() else {
                onFailure(.flyPayUrlError)
                return
            }
            webView.load(urlRequest)
        }
    }

    private func getFlyPayUrlRequest() -> URLRequest? {
        let urlString: String = {
            switch MobileSDK.shared.config?.environment {
            case .production: return "https://checkout.flypay.com.au/?orderId=\(flyPayOrderId)&redirectUrl=https://paydock.com&mode=default&clientId=\(clientId)"
            case .staging, .sandbox: return "https://checkout.sandbox.cxbflypay.com.au/?orderId=\(flyPayOrderId)&redirectUrl=https://paydock.com&mode=default&clientId=\(clientId)"
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
        private let redirectUrlString = "https://paydock.com/"

        init(onApprove: @escaping OnApprove,
             onFailure: @escaping OnFailure) {
            self.onApprove = onApprove
            self.onFailure = onFailure
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
        }
        
        /**
         This method handles errors that are reported that happen while loading the resource.
         These are usually errors caused by the content of the page, like invalid code in the page itself that the parser can't handle.
         **/
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
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
            if webView.url?.host() == URL(string: redirectUrlString)?.host() {
                onApprove()
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }

        func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
            decisionHandler(true)
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
