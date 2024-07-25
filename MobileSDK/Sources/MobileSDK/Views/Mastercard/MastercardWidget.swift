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

    // MARK: - Dependencies

    private let serviceId: String
    private let accessToken: String
    private let meta: MastercardSrcMeta?
    private let clientSdkUrl = Constants.clientSdkUrlString

    // MARK: - Handlers

    private let completion: (MastercardResult) -> Void

    // MARK: - Initialization

    public init(serviceId: String,
                accessToken: String,
                meta: MastercardSrcMeta?,
                completion: @escaping (MastercardResult) -> Void) {
        self.serviceId = serviceId
        self.accessToken = accessToken
        self.meta = meta
        self.completion = completion
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        // adds dummy cookie to webview to sync cookies
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
            if let url = URL(string: "https://sandbox.src.mastercard.com") {
                let html = html(serviceId: serviceId, accessToken: accessToken, meta: meta)
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

    func html(serviceId: String, accessToken: String, meta: MastercardSrcMeta?) -> String {
        let clientSdkUrl = Constants.clientSdkUrlString
        let clientSdkEnvironment = Constants.clientSdkEnvironment
        let clientSdkType = Constants.clientSdkType
        let jsonString: String = {
            if meta == nil {
                return "{}"
            } else {
                do {
                    let jsonData = try JSONEncoder().encode(meta)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        return jsonString
                    } else {
                        print("Error converting SRC meta to JSON")
                        return ""
                    }
                } catch {
                    print("Error converting SRC meta to JSON")
                    return ""
                }
            }
        }()

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
            <script src="\(clientSdkUrl)"></script>
            <script>
                const serviceId = "\(serviceId)";
                const accessToken = "\(accessToken)";
                const meta = \(jsonString)
                var src = new \(clientSdkType).ClickToPay(
                        "#checkoutIframe",
                        serviceId,
                        accessToken,
                        meta,
                        {}
                    );
                src.setEnv('\(clientSdkEnvironment)');
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

