//
//  MPGS3DSWidget.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
@preconcurrency import WebKit
import AuthenticationServices

@MainActor
public struct MPGS3DSWidget: UIViewRepresentable {

    private let config: ThreeDSConfig
    private let appearance: MPG3dsWidgetAppearance
    private let completion: (Result<MPGS3dsResult, MPGS3dsError>) -> Void
    private let base64Decoder: Base64Decoder = Base64Decoder()
    /// Whether the token decodes as an MPGS 3DS token; `makeUIView` starts no payment attempt otherwise (D24).
    private let hasValidToken: Bool

    public init(config: ThreeDSConfig,
                appearance: MPG3dsWidgetAppearance = MPG3dsWidgetAppearance(),
                completion: @escaping (Result<MPGS3dsResult, MPGS3dsError>) -> Void) {
        self.config = config
        self.appearance = appearance
        self.completion = completion
        self.hasValidToken = Self.isValidToken(config.token, decoder: base64Decoder)

        validateToken()
    }

    /// The invalid tokens already reported in this process.
    private static let invalidTokenReports = ReportOnce()
    /// The invalid tokens already recorded as failed payment attempts in this process (D24).
    static let invalidTokenPayments = ReportOnce()

    private static func isValidToken(_ token: String, decoder: Base64Decoder) -> Bool {
        guard let decodedToken = decoder.decodeBase64(token, to: Decoded3DSToken.self) else {
            return false
        }
        return decodedToken.format == .html || decodedToken.format == .url
    }

    /// D25: the token's 3DS charge id, decoded with the same decoder as `isValidToken`.
    private static func charge3dsId(_ token: String, _ decoder: Base64Decoder) -> String? {
        decoder.decodeBase64(token, to: Decoded3DSToken.self)?.resolvedCharge3dsId
    }

    private func validateToken() {
        guard hasValidToken else {
            let failure = MPGS3dsError.invalidToken
            // `init` runs again on every redraw of the parent view: the same token is reported once per process.
            SdkTelemetry.reportSdkError(failure, widget: .mpgs3ds, once: (Self.invalidTokenReports, config.token))
            SdkTelemetry.recordFailedPayment(.mpgs3ds, error: failure, once: (Self.invalidTokenPayments, config.token))
            completion(.failure(failure))
            return
        }
    }

    public func makeUIView(context: Context) -> UIView {
        SdkTelemetry.reportWidgetOpened(.mpgs3ds)
        if hasValidToken {
            context.coordinator.payment = SdkTelemetry.startPayment(.mpgs3ds, charge3dsId: Self.charge3dsId(config.token, base64Decoder))
        }
        let containerView = UIView()

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor(appearance.loader.color)
        activityIndicator.backgroundColor = UIColor(appearance.loader.overlayColor)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        activityIndicator.startAnimating()  // Start animating initially
        activityIndicator.backgroundColor = UIColor(appearance.loader.overlayColor)

        activityIndicator.isAccessibilityElement = true
        activityIndicator.accessibilityLabel = "3DS Check Loading"

        context.coordinator.activityIndicator = activityIndicator

        containerView.addSubview(webView)
        containerView.addSubview(activityIndicator)

        // Set up constraints for activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

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
            let html = MPGS3DSWidget.html(config.token)
            webView.loadHTMLString(html, baseURL: URL(string: "https://paydock.com"))
        }
    }

    public func makeCoordinator() -> Coordinator {
        .init(completion: completion, clientSdkHost: URL(string: Constants.clientSdkUrlString)?.host)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        private let completion: (Result<MPGS3dsResult, MPGS3dsError>) -> Void
        var isLoaded = false
        var activityIndicator: UIActivityIndicatorView?  // Store a reference to the activity indicator
        private let clientSdkHost: String?
        private var clientSdkLoadFailureReported = false
        /// The open payment attempt (D24), from `makeUIView` until the flow's final outcome or failure.
        var payment: PaymentAttempt?

        init(completion: @escaping (Result<MPGS3dsResult, MPGS3dsError>) -> Void,
             clientSdkHost: String? = nil) {
            self.completion = completion
            self.clientSdkHost = clientSdkHost
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            handleMessage(message.body)
        }

        /// Maps a message posted by the page to `completion`. The page's `clientSdkLoadFailed` report ends the widget
        /// with `webViewFailed`, at most once.
        func handleMessage(_ body: Any) {
            if ClientSdkPage.isLoadFailed(body) {
                guard !clientSdkLoadFailureReported else { return }
                clientSdkLoadFailureReported = true
                activityIndicator?.stopAnimating()
                let failure = MPGS3dsError.webViewFailed(error: ClientSdkPage.loadFailedError(host: clientSdkHost))
                SdkTelemetry.reportSdkError(failure, widget: .mpgs3ds)
                SdkTelemetry.finishPayment(&payment, .failed(failure))
                completion(.failure(failure))
                return
            }
            SdkTelemetry.notePaymentCharge3dsId((body as? [String: Any])?["charge3dsId"] as? String, on: &payment)
            guard let data = body as? [String: Any],
                  let eventRaw = data["event"] as? String,
                  let event = MPGS3dsResult.EventType(rawValue: eventRaw),
                  let token = data["charge3dsId"] as? String
            else {
                let failure = MPGS3dsError.mappingFailed
                SdkTelemetry.reportSdkError(failure, widget: .mpgs3ds)
                SdkTelemetry.finishPayment(&payment, .failed(failure))
                completion(.failure(failure))
                return
            }
            let statusRaw = data["status"] as? String
            _ = MPGS3dsStatus(rawValue: statusRaw ?? "") // Not used currently

            if let end = Self.paymentEnd(of: event) { SdkTelemetry.finishPayment(&payment, end) }
            completion(.success(MPGS3dsResult(event: event, charge3dsId: token)))
        }

        /// The payment attempt's end for a final event (D24); nil for `chargeAuth` and `additionalDataCollectSuccess`,
        /// after which the flow goes on.
        private static func paymentEnd(of event: MPGS3dsResult.EventType) -> PaymentEnd? {
            switch event {
            case .chargeAuthSuccess: return .success
            case .chargeAuthReject, .additionalDataCollectReject: return .declined
            case .chargeAuthCancelled: return .cancelled
            case .chargeAuth, .additionalDataCollectSuccess: return nil
            }
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
            activityIndicator?.stopAnimating()
            ClientSdkVersionReader.read(webView)
        }

        /**
         This method handles errors that are reported that happen while loading the resource.
         These are usually errors caused by the content of the page, like invalid code in the page itself that the parser can't handle.
         **/
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            activityIndicator?.stopAnimating()
            let nsError = error as NSError
            if nsError.isWebViewNavigationCancellation { return }
            let failure = MPGS3dsError.webViewFailed(error: nsError)
            SdkTelemetry.reportSdkError(failure, widget: .mpgs3ds)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            completion(.failure(failure))
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            activityIndicator?.startAnimating()
            DispatchQueue.main.async {
                UIAccessibility.post(notification: .announcement, argument: "3DS Check Loading")
            }
        }

        /**
         This method handles errors that happen before the resource of the url can even be reached.
         These errors are mostly related to connectivity, the formatting of the url, or if using urls which are not supported.

         @see https://developer.apple.com/documentation/cfnetwork/cfnetworkerrors
         */
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            activityIndicator?.stopAnimating()
            let nsError = error as NSError
            if nsError.isWebViewNavigationCancellation { return }
            let failure = MPGS3dsError.webViewFailed(error: nsError)
            SdkTelemetry.reportSdkError(failure, widget: .mpgs3ds)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            completion(.failure(failure))
        }

        public func webView(_ webView: WKWebView,
                            authenticationChallenge challenge: URLAuthenticationChallenge,
                            shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
            // Reject deprecated TLS versions for PCI DSS compliance
            decisionHandler(false)
        }

        public func webView(_ webView: WKWebView,
                            didReceive challenge: URLAuthenticationChallenge,
                            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            // Use default system SSL certificate validation for PCI DSS compliance
            // This ensures proper certificate chain validation against system trust store
            completionHandler(.performDefaultHandling, nil)
        }
    }

    // swiftlint:disable:next function_body_length
    static func html(_ token: String) -> String {
        let clientSdkUrl = Constants.clientSdkUrlString
        let clientSdkEnvironment = Constants.clientSdkEnvironment
        let clientSdkType = Constants.clientSdkType
        let inlineScript = """
                    var meta = document.createElement("meta");
                    meta.name = "viewport";
                    meta.content = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no";
                    var head = document.getElementsByTagName("head")[0];
                    head.appendChild(meta);

                    const token = "\(token)";
                    var canvas3ds = new \(clientSdkType).Canvas3ds("#widget", token);
                    canvas3ds.setEnv('\(clientSdkEnvironment)');

                    const watchEvent = (event) => {
                        canvas3ds.on(event, function (data) {
                            if (typeof window.webkit.messageHandlers.PayDockMobileSDK !== "undefined") {
                                window.webkit.messageHandlers.PayDockMobileSDK.postMessage({
                                    event,
                                    charge3dsId: data.charge_3ds_id,
                                    status: data.status,
                                });
                            }
                        });
                    };

                    watchEvent("chargeAuthSuccess");
                    watchEvent("chargeAuthReject");
                    watchEvent("chargeAuthCancelled");
                    watchEvent("additionalDataCollectSuccess");
                    watchEvent("additionalDataCollectReject");
                    watchEvent("chargeAuth");
                    watchEvent("error");

                    canvas3ds.load();
        """
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
                \(ClientSdkPage.scripts(clientSdkUrl: clientSdkUrl, inlineScript: inlineScript))
            </body>
        </html>
        """
    }
}
