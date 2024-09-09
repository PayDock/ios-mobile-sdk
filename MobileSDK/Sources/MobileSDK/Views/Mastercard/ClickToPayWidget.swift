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

public struct ClickToPayWidget: UIViewRepresentable {

    // MARK: - Dependencies

    private let serviceId: String
    private let accessToken: String
    private let meta: ClickToPayMeta?
    private let clientSdkUrl = Constants.clientSdkUrlString
    
    // MARK: - Handlers

    private let completion: (Result<ClickToPayResult, ClickToPayError>) -> Void

    // MARK: - Initialization

    public init(serviceId: String,
                accessToken: String,
                meta: ClickToPayMeta?,
                completion: @escaping (Result<ClickToPayResult, ClickToPayError>) -> Void) {
        self.serviceId = serviceId
        self.accessToken = accessToken
        self.meta = meta
        self.completion = completion
    }

    public func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let cookie = HTTPCookie(properties: [
            .domain: "sandbox.src.mastercard.com",
            .path: "/",
            .name: "MyCookieName",
            .value: "MyCookieValue",
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 31556926)
        ])!
        configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.contentMode = .scaleToFill
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor(Color.primaryColor)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        activityIndicator.startAnimating()  // Start animating initially
        context.coordinator.activityIndicator = activityIndicator
        
        containerView.addSubview(webView)
        containerView.addSubview(activityIndicator)
        
        // Set up constraints for webView
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Set up constraints for activityIndicator to be centered
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }

    public func updateUIView(_ view: UIView, context: Context) {
        guard let webView = view.subviews.first(where: { $0 is WKWebView }) as? WKWebView else {
            return
        }
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
        private let completion: (Result<ClickToPayResult, ClickToPayError>) -> Void
        var isLoaded = false
        var activityIndicator: UIActivityIndicatorView?  // Store a reference to the activity indicator

        init(completion: @escaping (Result<ClickToPayResult, ClickToPayError>) -> Void) {
            self.completion = completion
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let data = message.body as? [String: Any],
                  let eventRaw = data["event"] as? String,
                  let event = ClickToPayResult.EventType(rawValue: eventRaw) else {
                completion(.success(ClickToPayResult(event: .checkoutError, mastercardToken: "")))
                return
            }

            guard let outerData = data["data"] as? [String: Any],
                  let innerData = outerData["data"] as? [String: Any],
                  let token = innerData["token"] as? String else { return }

            completion(.success(ClickToPayResult(event: event, mastercardToken: token)))
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
            activityIndicator?.stopAnimating()
        }
        
        /**
         This method handles errors that are reported that happen while loading the resource.
         These are usually errors caused by the content of the page, like invalid code in the page itself that the parser can't handle.
         **/
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            activityIndicator?.stopAnimating()
            completion(.failure(.webViewFailed(error: error as NSError)))
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            activityIndicator?.startAnimating()
        }
        
        /**
         This method handles errors that happen before the resource of the url can even be reached.
         These errors are mostly related to connectivity, the formatting of the url, or if using urls which are not supported.
         
         @see https://developer.apple.com/documentation/cfnetwork/cfnetworkerrors
         */
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            activityIndicator?.stopAnimating()
            completion(.failure(.webViewFailed(error: error as NSError)))
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
        }
    }

    func html(serviceId: String, accessToken: String, meta: ClickToPayMeta?) -> String {
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
            <title>Click To Pay</title>

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

