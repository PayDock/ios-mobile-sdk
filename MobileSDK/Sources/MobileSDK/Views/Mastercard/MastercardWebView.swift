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

struct MastercardWebView: UIViewRepresentable {
    private let completion: (ThreeDSResult) -> Void

    init(completion: @escaping (ThreeDSResult) -> Void) {
        self.completion = completion
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")
        configuration.preferences.javaScriptEnabled = true
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

    func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            let html = html(serviceId: "65c9feb3acf4cf957b1b500d", publicKey: "6d93da51d3c9201063cdd95387eb9244500ab743")
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        .init(completion: completion)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        private let completion: (ThreeDSResult) -> Void
        var isLoaded = false

        init(completion: @escaping (ThreeDSResult) -> Void) {
            self.completion = completion
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message.body)
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

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("finished navigation")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Started Navigation:")
            print(webView.url)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Failed Navigation:")
            print(webView.url)
        }

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

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
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

//                self.webViews.append(popupWebView)
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

            watchEvent("iframeLoaded");
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
