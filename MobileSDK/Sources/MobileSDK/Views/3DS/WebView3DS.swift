//
//  WebView3DS.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 27.11.2023..
//

import SwiftUI
import WebKit
import AuthenticationServices

enum Event: String {
    case afterLoad
    case submit
    case finish
    case validation
    case validationError
    case systemError
    case metaChange
    case resize
}

public protocol PayDockDelegate: AnyObject {
    func didLoad()
    func didSubmit()
    func didFinish()
    func onValidation()
    func onValidationFail()
    func onSystemError()
    func metaDidChange()
    func onResize()
}

enum Status: String {
    case pending
    case authenticated
    case failed
}

public struct WebView3DS: UIViewRepresentable {
    private weak var delegate: PayDockDelegate?
    private let token: String
    private let baseUrl: URL?

    public init(delegate: PayDockDelegate? = nil, token: String, baseURL: URL?) {
        self.delegate = delegate
        self.token = token
        self.baseUrl = baseURL
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
            let html = WebView3DS.html(token)
            webView.loadHTMLString(html, baseURL: baseUrl)
        }
    }

    public func makeCoordinator() -> Coordinator {
        .init(delegate: delegate)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        weak var delegate: PayDockDelegate?
        var isLoaded = false

        init(delegate: PayDockDelegate? = nil) {
            self.delegate = delegate
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard
                let data = message.body as? [String: Any],
                let statusRaw = data["status"] as? String,
                let status = Status(rawValue: statusRaw),
                let token = data["charge_3ds_id"]
            else {
                print("No status found")
                return
            }
            switch status {
            case .pending:
                print("---3DS Pending: \(token)")
                delegate?.didLoad()
            case .authenticated:
                print("---3DS Success: \(token)")
                delegate?.didFinish()
            case .failed:
                print("---3DS Failed: \(token)")
                delegate?.onValidationFail()
            }
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
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
                <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
                <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
                <link rel="manifest" href="/site.webmanifest">
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

            <script src="https://widget.paydock.com/sdk/latest/widget.umd.min.js" ></script>

            <script>
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                var head = document.getElementsByTagName('head')[0];
                head.appendChild(meta);

                const token = "\(token)"
                var canvas3ds = new paydock.Canvas3ds('#widget', token)
                canvas3ds.setEnv('sandbox');
                canvas3ds.on("chargeAuthSuccess", function (data) {
                    console.log(data);
                    window.webkit.messageHandlers.PayDockMobileSDK.postMessage(data);
                });
                canvas3ds.on("chargeAuthReject", function (data) {
                    console.log(data);
                    window.webkit.messageHandlers.PayDockMobileSDK.postMessage(data);
                });
                canvas3ds.on("chargeAuthChallenge", function (data) {
                    console.log(data);
                    window.webkit.messageHandlers.PayDockMobileSDK.postMessage(data);
                });
                canvas3ds.on("chargeAuthDecoupled", function (data) {
                    console.log(data.result.description);
                    window.webkit.messageHandlers.PayDockMobileSDK.postMessage(data);
                });
                canvas3ds.on("chargeAuthInfo", function (data) {
                    console.log(data.info);
                    window.webkit.messageHandlers.PayDockMobileSDK.postMessage(data);
                });
                canvas3ds.on("error", function ({ charge_3ds_id, error }) {
                    console.log(error);
                    window.webkit.messageHandlers.PayDockMobileSDK.postMessage(error);
                });
                canvas3ds.load();
            </script>
            </body>
            </html>
        """
    }
}
