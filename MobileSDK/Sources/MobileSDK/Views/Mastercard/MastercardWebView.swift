//
//  MastercardWebView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI
import WebKit
import AuthenticationServices

public struct MastercardWebView: UIViewRepresentable {
    private let token: String
    private let baseUrl: URL?
    private let completion: (ThreeDSResult) -> Void

    public init(token: String, baseURL: URL?, completion: @escaping (ThreeDSResult) -> Void) {
        self.token = token
        self.baseUrl = baseURL
        self.completion = completion
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")

        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.navigationDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            let html = MastercardWebView.html(serviceId: "65c9feb3acf4cf957b1b500d", publicKey: "6d93da51d3c9201063cdd95387eb9244500ab743")
            webView.loadHTMLString(html, baseURL: baseUrl)
        }
    }

    public func makeCoordinator() -> Coordinator {
        .init(completion: completion)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        private let completion: (ThreeDSResult) -> Void
        var isLoaded = false

        init(completion: @escaping (ThreeDSResult) -> Void) {
            self.completion = completion
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message)
//            guard let data = message.body as? [String: Any],
//                  let eventRaw = data["event"] as? String,
//                  let event = ThreeDSResult.EventType(rawValue: eventRaw),
//                  let token = data["charge3dsId"] as? String
//            else {
//                completion(ThreeDSResult(event: .error, charge3dsId: ""))
//                return
//            }
//            completion(ThreeDSResult(event: event, charge3dsId: token))
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("finished navigation")
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}

        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print(error)
        }

        public func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
            decisionHandler(true)
        }

        public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            DispatchQueue.global(qos: .background).async {
                let trust = challenge.protectionSpace.serverTrust!
                let exceptions = SecTrustCopyExceptions(trust)
                SecTrustSetExceptions(trust, exceptions)
                completionHandler(.useCredential, URLCredential(trust: trust))
            }
        }
    }

    static func html(serviceId: String, publicKey: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>Title</title>
            <style>
                iframe {
                    border: 0;
                    width: 100%;
                    height: 300px;
                }
            </style>
        </head>
        <body>
        <h1>Mastercard SRC test</h1>

        <div id="checkoutIframe"></div>

        <script src="https://widget.paydock.com/sdk/v1.99.9-beta/widget.umd.min.js"></script>

        <script>
            const serviceId = "\(serviceId)";
            const publicKey = "\(publicKey)";
            var src = new paydock.MastercardSRCClickToPay(
                    "#checkoutIframe",
                    serviceId,
                    publicKey,
                    {}
                );
            src.setEnv('staging_10');
            src.load();

            src.on('iframeLoaded', () => {
                console.log("Initial iframe loaded");
            });

            src.on('checkoutReady', () => {
                console.log("Checkout ready to be used");
            });

            src.on('checkoutCompleted', (token) => {
                console.log(token);
            });

            src.on('checkoutError', (error) => {
                console.log(error);
            });
        </script>
        </body>
        </html>
"""
    }
}
