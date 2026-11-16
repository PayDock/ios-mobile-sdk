//
//  Standalone3DSWidget.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
@preconcurrency import WebKit
import AuthenticationServices

/// Web event names that are not part of ``Standalone3DSResult/EventType``.
private enum Standalone3DSWebEvent {
    static let challengeLoaded = "chargeAuthChallengeLoaded"
    static let challengeCompleted = "chargeAuthChallengeCompleted"
    static let error = "error"
    /// Posted by the page itself (not the web SDK) when the Client SDK script fails to load, or loads without
    /// providing the Client SDK global.
    static let clientSdkLoadFailed = ClientSdkPage.loadFailedEvent
}

/// Optional informational fields carried by a final web event.
private struct Standalone3DSEventDetails {
    let status: String?
    let resultDescription: String?
    /// Unnormalised description, forwarded as-is to `onProgress(.decoupled)` (unchanged behaviour).
    let rawDescription: String?
}

@MainActor
public struct Standalone3DSWidget: UIViewRepresentable {
    private let config: ThreeDSConfig
    private let appearance: Standalone3dsWidgetAppearance
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private let base64Decoder: Base64Decoder = Base64Decoder()
    private let onProgress: ((Standalone3DSProgress) -> Void)?
    private let completion: (Result<Standalone3DSResult, Standalone3DSError>) -> Void

    /// Creates a Standalone 3DS widget.
    /// - Parameters:
    ///   - config: 3DS configuration holding the standalone 3DS token
    ///   - appearance: Appearance of the built-in loading overlay
    ///   - loadingDelegate: Optional delegate that takes over the loading UI. It is started when the widget appears,
    ///     finished once the challenge page has loaded (or on a decoupled authentication), started again while the
    ///     challenge result is confirmed, and finished on the final event. Calls are always balanced.
    ///   - onProgress: Optional callback for intermediate progress (challenge started/loaded/completed, decoupled).
    ///     Final outcomes are delivered only through `completion`.
    ///   - completion: Completion handler receiving 3DS events and failures
    public init(config: ThreeDSConfig,
                appearance: Standalone3dsWidgetAppearance = Standalone3dsWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                onProgress: ((Standalone3DSProgress) -> Void)? = nil,
                completion: @escaping (Result<Standalone3DSResult, Standalone3DSError>) -> Void) {
        self.config = config
        self.appearance = appearance
        self.loadingDelegate = loadingDelegate
        self.onProgress = onProgress
        self.completion = completion

        validateToken()
    }

    private func validateToken() {
        guard let decodedToken = base64Decoder.decodeBase64(config.token, to: Decoded3DSToken.self),
              decodedToken.format == .standalone3ds else {
            completion(.failure(.invalidToken))
            return
        }
    }

    public func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "PayDockMobileSDK")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        containerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        // WebView fills entire container.
        var layoutConstraints: [NSLayoutConstraint] = [
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]

        // Only embed the internal progress overlay when the host hasn't supplied a loading delegate.
        // When a delegate is provided, the host app drives its own loading UI (same pattern as
        // CardDetailsWidget's `showLoaders` suppression).
        if loadingDelegate == nil {
            let progressView = DynamicProgressView(frame: .zero, appearance: appearance.overlayLoader)
            context.coordinator.loader = progressView
            containerView.addSubview(progressView)
            progressView.translatesAutoresizingMaskIntoConstraints = false

            layoutConstraints.append(contentsOf: [
                progressView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
                progressView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
                progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        }

        NSLayoutConstraint.activate(layoutConstraints)

        // Loading is in progress from the moment the widget is shown — webView starts loading
        // its HTML shell on the next `updateUIView` pass.
        context.coordinator.notifyLoadingStart()

        return containerView
    }

    public func updateUIView(_ view: UIView, context: Context) {
        guard let webView = view.subviews.first(where: { $0 is WKWebView }) as? WKWebView else {
            return
        }
        // Once the session has ended (e.g. the page's process was terminated) the page must not be loaded again:
        // that would restart the 3DS flow on the same token.
        if !context.coordinator.isLoaded && !context.coordinator.hasEnded {
            let html = Standalone3DSWidget.html(config.token)
            webView.loadHTMLString(html, baseURL: URL(string: "https://paydock.com"))
        }
    }

    public func makeCoordinator() -> Coordinator {
        .init(completion: completion,
              loadingDelegate: loadingDelegate,
              onProgress: onProgress,
              charge3dsId: base64Decoder.decodeBase64(config.token, to: Decoded3DSToken.self)?.resolvedCharge3dsId,
              clientSdkHost: URL(string: Constants.clientSdkUrlString)?.host)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        private let completion: (Result<Standalone3DSResult, Standalone3DSError>) -> Void
        private let onProgress: ((Standalone3DSProgress) -> Void)?
        private weak var loadingDelegate: WidgetLoadingDelegate?
        var isLoaded = false
        var loader: DynamicProgressView?  // Store a reference to the activity indicator
        /// Whether loading is currently shown — keeps start/finish notifications balanced.
        private(set) var isLoading = false
        /// Last non-empty charge 3DS id received, used when an event arrives without one (e.g. `error`).
        private var lastCharge3dsId: String?
        /// Charge 3DS id read from the token, used to label failures that happen before any event.
        private let tokenCharge3dsId: String?
        /// Host of the Client SDK script, reported when it fails to load.
        private let clientSdkHost: String?
        /// Test seam for the app's background state; `nil` reads `UIApplication`.
        private let isAppInBackground: (() -> Bool)?
        /// Set once the page can no longer progress (its process was terminated or the Client SDK script failed):
        /// the failure is reported once and the page is never loaded again.
        private(set) var hasEnded = false

        init(completion: @escaping (Result<Standalone3DSResult, Standalone3DSError>) -> Void,
             loadingDelegate: WidgetLoadingDelegate? = nil,
             onProgress: ((Standalone3DSProgress) -> Void)? = nil,
             charge3dsId: String? = nil,
             clientSdkHost: String? = nil,
             isAppInBackground: (() -> Bool)? = nil) {
            self.completion = completion
            self.loadingDelegate = loadingDelegate
            self.onProgress = onProgress
            self.tokenCharge3dsId = charge3dsId
            self.clientSdkHost = clientSdkHost
            self.isAppInBackground = isAppInBackground
        }

        /// Notify whichever owner is driving the loading UI that a load just started.
        /// When a `WidgetLoadingDelegate` was supplied to the widget the host app takes over;
        /// otherwise the internal `DynamicProgressView` is used. No-op while already loading.
        func notifyLoadingStart() {
            guard !isLoading else { return }
            isLoading = true
            if let loadingDelegate = loadingDelegate {
                loadingDelegate.loadingDidStart()
            } else {
                loader?.startAnimating()
            }
        }

        /// Counterpart to ``notifyLoadingStart()``. No-op while not loading.
        func notifyLoadingFinish() {
            guard isLoading else { return }
            isLoading = false
            if let loadingDelegate = loadingDelegate {
                loadingDelegate.loadingDidFinish()
            } else {
                loader?.stopAnimating()
            }
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            handleMessage(message.body)
        }

        /// Maps a message posted by the web bridge to `completion` / `onProgress` and drives the loading state.
        func handleMessage(_ body: Any) {
            guard let data = body as? [String: Any],
                  let eventRaw = data["event"] as? String
            else {
                notifyLoadingFinish()
                completion(.failure(.mappingFailed))
                return
            }

            let charge3dsId = data["charge3dsId"] as? String
            if let charge3dsId, !charge3dsId.isEmpty {
                lastCharge3dsId = charge3dsId
            }
            let details = Standalone3DSEventDetails(status: Self.nonEmptyString(data["status"]),
                                                  resultDescription: Self.nonEmptyString(data["description"]),
                                                  rawDescription: data["description"] as? String)

            switch eventRaw {
            case Standalone3DSWebEvent.challengeLoaded:
                let reason = Standalone3DSProgress.ChallengeLoadedReason(rawValue: data["reason"] as? String ?? "") ?? .unknown
                notifyLoadingFinish()
                onProgress?(.challengeLoaded(charge3dsId: charge3dsId, reason: reason))
            case Standalone3DSWebEvent.challengeCompleted:
                let source = Standalone3DSProgress.ChallengeCompletedSource(rawValue: data["source"] as? String ?? "") ?? .unknown
                notifyLoadingStart()
                onProgress?(.challengeCompleted(charge3dsId: charge3dsId, source: source))
            case Standalone3DSWebEvent.error:
                handleEvent(.chargeError, charge3dsId: charge3dsId, details: details)
            case Standalone3DSWebEvent.clientSdkLoadFailed:
                var userInfo: [String: Any] = [
                    NSLocalizedDescriptionKey: "Failed to load the payment page. Please try again later."
                ]
                userInfo[Standalone3DSError.ContextKey.failingHost] = clientSdkHost
                endSession(with: NSError(domain: Standalone3DSError.errorDomain,
                                         code: Standalone3DSError.ErrorCode.clientSdkLoadFailed.rawValue,
                                         userInfo: userInfo))
            default:
                // Unknown events (e.g. from a newer web SDK) are ignored so they never fail the flow.
                guard let event = Standalone3DSResult.EventType(rawValue: eventRaw) else { return }
                handleEvent(event, charge3dsId: charge3dsId, details: details)
            }
        }

        /// Returns the value as a string, or `nil` when it is missing, not a string or empty.
        private static func nonEmptyString(_ value: Any?) -> String? {
            guard let string = value as? String, !string.isEmpty else { return nil }
            return string
        }

        private func handleEvent(_ event: Standalone3DSResult.EventType, charge3dsId: String?, details: Standalone3DSEventDetails) {
            func result(_ charge3dsId: String) -> Standalone3DSResult {
                Standalone3DSResult(event: event, charge3dsId: charge3dsId,
                                    status: details.status, resultDescription: details.resultDescription)
            }
            switch event {
            case .chargeAuthInfo:
                // Informational (its payload has no charge id) — loading state is unchanged.
                completion(.success(result(charge3dsId ?? lastCharge3dsId ?? "")))
            case .chargeError:
                notifyLoadingFinish()
                completion(.success(result(charge3dsId ?? lastCharge3dsId ?? "")))
            case .chargeAuthChallenge, .chargeAuthDecoupled, .chargeAuthSuccess, .chargeAuthReject:
                guard let charge3dsId else {
                    notifyLoadingFinish()
                    completion(.failure(.mappingFailed))
                    return
                }
                switch event {
                case .chargeAuthChallenge:
                    // Keep loading until the challenge page has loaded (`chargeAuthChallengeLoaded`).
                    notifyLoadingStart()
                    completion(.success(result(charge3dsId)))
                    onProgress?(.challengeStarted(charge3dsId: charge3dsId))
                case .chargeAuthDecoupled:
                    notifyLoadingFinish()
                    completion(.success(result(charge3dsId)))
                    onProgress?(.decoupled(charge3dsId: charge3dsId, description: details.rawDescription))
                default:
                    notifyLoadingFinish()
                    completion(.success(result(charge3dsId)))
                }
            }
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
            ClientSdkVersionReader.read(webView)
        }

        /**
         This method handles errors that are reported that happen while loading the resource.
         These are usually errors caused by the content of the page, like invalid code in the page itself that the parser can't handle.
         **/
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.isWebViewNavigationCancellation { return }
            notifyLoadingFinish()
            completion(.failure(.webViewFailed(error: withContext(nsError))))
        }

        /**
         iOS terminated the page's web content process — typically to reclaim memory while the app was in the
         background (e.g. the shopper approving in their banking app). The page is blank from then on and no event
         will ever arrive, so the session is ended with `webViewFailed` (`WKError.webContentProcessTerminated`)
         instead of waiting forever. The page is not reloaded: that would restart 3DS on the same token.
         **/
        public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            endSession(with: NSError(domain: WKError.errorDomain,
                                     code: WKError.Code.webContentProcessTerminated.rawValue))
        }

        /// Reports a failure the page can't recover from, once, and stops the page from being loaded again.
        private func endSession(with error: NSError) {
            guard !hasEnded else { return }
            hasEnded = true
            notifyLoadingFinish()
            completion(.failure(.webViewFailed(error: withContext(error))))
        }

        /// Adds the session context (charge 3DS id, background state) to a WebView failure, keeping its domain, code
        /// and existing `userInfo`.
        private func withContext(_ error: NSError) -> NSError {
            var userInfo = error.userInfo
            userInfo[Standalone3DSError.ContextKey.charge3dsId] = lastCharge3dsId ?? tokenCharge3dsId
            userInfo[Standalone3DSError.ContextKey.inBackground] = appInBackground()
            return NSError(domain: error.domain, code: error.code, userInfo: userInfo)
        }

        private func appInBackground() -> Bool {
            if let isAppInBackground { return isAppInBackground() }
            return UIApplication.shared.applicationState == .background
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            notifyLoadingStart()
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
            let nsError = error as NSError
            if nsError.isWebViewNavigationCancellation { return }
            notifyLoadingFinish()
            completion(.failure(.webViewFailed(error: withContext(nsError))))
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
                            try {
                                const handler = window.webkit && window.webkit.messageHandlers
                                    ? window.webkit.messageHandlers.PayDockMobileSDK
                                    : undefined;
                                if (typeof handler === "undefined") {
                                    return;
                                }
                                const payload = data || {};
                                const message = { event };
                                const addString = (key, value) => {
                                    if (typeof value === "string") {
                                        message[key] = value;
                                    }
                                };
                                addString("charge3dsId", payload.charge_3ds_id);
                                addString("status", payload.status);
                                addString("description", payload.result ? payload.result.description : undefined);
                                addString("reason", payload.reason);
                                addString("source", payload.source);
                                handler.postMessage(message);
                            } catch (e) {
                                console.error(e);
                            }
                        });
                    };

                    watchEvent("chargeAuthSuccess");
                    watchEvent("chargeAuthReject");
                    watchEvent("chargeAuthChallenge");
                    watchEvent("chargeAuthChallengeLoaded");
                    watchEvent("chargeAuthChallengeCompleted");
                    watchEvent("chargeAuthDecoupled");
                    watchEvent("chargeAuthInfo");
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
