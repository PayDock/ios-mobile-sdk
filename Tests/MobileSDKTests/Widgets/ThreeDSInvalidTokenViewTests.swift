//
//  ThreeDSInvalidTokenViewTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import WebKit
import XCTest
@testable import MobileSDK

@MainActor
final class ThreeDSInvalidTokenViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        MobileSDK.shared.configureMobileSDK(config: .init(environment: .sandbox))
    }

    func testStandalone_InvalidToken_ShowsNoLoaderAndLoadsNoPage() {
        let delegate = LoadingDelegateSpy()
        let widget = Standalone3DSWidget(config: ThreeDSConfig(token: "invalidBase64Token"), loadingDelegate: delegate) { _ in }

        let window = host(widget)

        XCTAssertTrue(views(in: window, of: WKWebView.self).isEmpty)
        XCTAssertTrue(views(in: window, of: DynamicProgressView.self).isEmpty)
        XCTAssertEqual(delegate.starts, 0)
    }

    func testStandalone_ValidToken_ShowsLoaderAndPage() throws {
        let widget = Standalone3DSWidget(config: ThreeDSConfig(token: try Self.token(format: .standalone3ds))) { _ in }

        let window = host(widget)

        XCTAssertEqual(views(in: window, of: WKWebView.self).count, 1)
        XCTAssertEqual(views(in: window, of: DynamicProgressView.self).count, 1)
    }

    func testMPGS_InvalidToken_ShowsNoLoaderAndLoadsNoPage() {
        let widget = MPGS3DSWidget(config: ThreeDSConfig(token: "invalidBase64Token")) { _ in }

        let window = host(widget)

        XCTAssertTrue(views(in: window, of: WKWebView.self).isEmpty)
        XCTAssertTrue(views(in: window, of: UIActivityIndicatorView.self).isEmpty)
    }

    func testMPGS_ValidToken_ShowsLoaderAndPage() throws {
        let widget = MPGS3DSWidget(config: ThreeDSConfig(token: try Self.token(format: .html))) { _ in }

        let window = host(widget)

        XCTAssertEqual(views(in: window, of: WKWebView.self).count, 1)
        XCTAssertEqual(views(in: window, of: UIActivityIndicatorView.self).count, 1)
    }

    private func host<V: View>(_ view: V) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = UIHostingController(rootView: view)
        window.isHidden = false
        window.layoutIfNeeded()
        window.rootViewController?.view.layoutIfNeeded()
        return window
    }

    private func views<T: UIView>(in root: UIView, of type: T.Type) -> [T] {
        root.subviews.flatMap { subview in
            (subview as? T).map { [$0] } ?? views(in: subview, of: type)
        }
    }

    private static func token(format: Decoded3DSToken.ThreeDsFormat) throws -> String {
        let decoded = Decoded3DSToken(content: "<div></div>", format: format, charge3dsId: "id_1")
        return try JSONEncoder().encode(decoded).base64EncodedString()
    }
}

private final class LoadingDelegateSpy: WidgetLoadingDelegate {
    private(set) var starts = 0

    func loadingDidStart() { starts += 1 }
    func loadingDidFinish() {}
}
