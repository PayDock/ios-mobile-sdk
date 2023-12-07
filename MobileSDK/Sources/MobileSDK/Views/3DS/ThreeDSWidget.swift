//
//  ThreeDSWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 27.11.2023..
//

import SwiftUI
import WebKit
import AuthenticationServices

public struct ThreeDSWidget: UIViewRepresentable {
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
        webView.navigationDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            let html = ThreeDSWidget.html(token)
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
            guard let data = message.body as? [String: Any],
                  let eventRaw = data["event"] as? String,
                  let event = ThreeDSResult.EventType(rawValue: eventRaw),
                  let token = data["charge3dsId"] as? String
            else {
                completion(ThreeDSResult(event: .error, charge3dsId: ""))
                return
            }
            completion(ThreeDSResult(event: event, charge3dsId: token))
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Finish")
            isLoaded = true
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed")
            print(error)
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Prov start")
        }

        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Prov fail")
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

    static func html(_ token: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="UTF-8" />
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
                />
                <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
                <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
                <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
                <link rel="manifest" href="/site.webmanifest" />
                <title>3DS</title>
                <style>
                    iframe {
                        border: 0;
                        width: 100%;
                        height: 80vh;
                    }
                    #loader {
                        display: flex;
                        position: fixed;
                        width: 100%;
                        height: 80vh;
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
                <div id="widget"></div>
                <script src="https://widget.paydock.com/sdk/latest/widget.umd.min.js"></script>
                <script>
                    var meta = document.createElement("meta");
                    meta.name = "viewport";
                    meta.content = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no";
                    var head = document.getElementsByTagName("head")[0];
                    head.appendChild(meta);

                    const token = "\(token)";
                    var canvas3ds = new paydock.Canvas3ds("#widget", token);
                    canvas3ds.setEnv("sandbox");

                    const watchEvent = (event) => {
                        canvas3ds.on(event, function (data) {
                            if (typeof window.webkit.messageHandlers.PayDockMobileSDK !== "undefined") {
                                window.webkit.messageHandlers.PayDockMobileSDK.postMessage({
                                    event,
                                    charge3dsId: data.charge_3ds_id,
                                });
                            }
                        });
                    };

                    watchEvent("chargeAuthSuccess");
                    watchEvent("chargeAuthReject");
                    watchEvent("chargeAuthChallenge");
                    watchEvent("chargeAuthDecoupled");
                    watchEvent("chargeAuthInfo");
                    watchEvent("error");

                    canvas3ds.load();
                </script>
            </body>
        </html>
        """
    }
}
