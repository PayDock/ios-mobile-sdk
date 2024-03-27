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
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

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
            let html = html(serviceId: serviceId, publicKey: "6d93da51d3c9201063cdd95387eb9244500ab743")
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    public func makeCoordinator() -> Coordinator {
        .init(completion: completion)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        private let completion: (MastercardResult) -> Void
        var isLoaded = false

        init(completion: @escaping (MastercardResult) -> Void) {
            self.completion = completion
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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

        public func webViewDidClose(_ webView: WKWebView) {
            webView.removeFromSuperview()
        }

        public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                let popupWebView = WKWebView(frame: .zero, configuration: configuration)
                popupWebView.navigationDelegate = self
                popupWebView.uiDelegate = self

                webView.addSubview(popupWebView)
                popupWebView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    popupWebView.topAnchor.constraint(equalTo: webView.topAnchor),
                    popupWebView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
                    popupWebView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
                    popupWebView.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
                ])
                return popupWebView
            }

            return nil
        }
    }

    func html(serviceId: String, publicKey: String) -> String {
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
                    height: 1500px;
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

