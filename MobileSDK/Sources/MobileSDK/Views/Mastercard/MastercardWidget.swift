//
//  MastercardWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI
import WebKit
import AuthenticationServices

public struct MastercardWidget: UIViewRepresentable {
    private let completion: (MastercardResult) -> Void
    private let serviceId: String
    private let publicKey = Constants.publicKey

    public init(serviceId: String, completion: @escaping (MastercardResult) -> Void) {
        self.serviceId = serviceId
        self.completion = completion
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        //        add dummy cookie to webview to sync cookies
        let cookie = HTTPCookie(properties: [
            .domain: "sandbox.src.mastercard.com",
            .path: "/",
            .name: "MyCookieName",
            .value: "MyCookieValue",
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 31556926)
        ])!
        configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView.contentMode = .scaleToFill
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            // Replace test public key with passed in once everything is deployed to sandbox
            if let url = URL(string: "https://sandbox.src.mastercard.com") {
                let html = html(serviceId: serviceId, publicKey: Constants.publicKey)
                webView.loadHTMLString(html, baseURL: url)
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        .init(completion: completion)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        private let completion: (MastercardResult) -> Void
        var isLoaded = false

        init(completion: @escaping (MastercardResult) -> Void) {
            self.completion = completion
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message.body)
            guard let data = message.body as? [String: Any],
                  let eventRaw = data["event"] as? String,
                  let event = MastercardResult.EventType(rawValue: eventRaw) else {
                completion(MastercardResult(event: .checkoutError, mastercardToken: ""))
                return
            }

            guard let outerData = data["data"] as? [String: Any],
                  let innerData = outerData["data"] as? [String: Any],
                  let token = innerData["token"] as? String else { return }

            completion(MastercardResult(event: event, mastercardToken: token))
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

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
        }
    }

    func html(serviceId: String, publicKey: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <!-- Meta tags for character set and viewport settings -->
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

            <!-- Links to favicon and site manifest -->
            <link rel="apple-touch-icon" href="/apple-touch-icon.png">
            <link rel="icon" type="image/png" href="/favicon-32x32.png">
            <link rel="icon" type="image/png" href="/favicon-16x16.png">
            <link rel="manifest" href="/site.webmanifest">

            <!-- Title for the HTML document -->
            <title>Mastercard SRC</title>

            <!-- Style block for custom styles -->
            <style>
                /* Insert your custom styles here */
                iframe {
                    border: 0;
                    width: 100%;
                    height: 100vh;
                }
                #loader {
                    display: flex;
                    position: fixed;
                    width: 100%;
                    height: 100vh;
                    top: 0;
                    left: 0;
                    background: white;
                    align-items: center;
                    justify-content: center;
                    color: black;
                    font-size: 40px;
                }
            </style>
        </head>
        <body>
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
                const watchEvent = (event) => {
                    src.on(event, function (data) {
                        if (typeof window.webkit.messageHandlers.PayDockMobileSDK !== "undefined") {
                            window.webkit.messageHandlers.PayDockMobileSDK.postMessage({
                                event,
                                data: data
                            });
                        }
                    });
                };
                watchEvent("checkoutReady");
                watchEvent("checkoutCompleted");
                watchEvent("checkoutError");
                src.load();
            </script>
        </body>
        </html>
        """
    }
}

