//
//  RouteTemplatesTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_07: the § 5.4 templates and the mapping of a real path onto one, as Android's RouteTemplates.
final class RouteTemplatesTests: XCTestCase {

    func testTheEightTemplates_InOrder_StringForString() {
        XCTAssertEqual(RouteTemplates.templates, [
            "/v1/payment_sources/tokens",
            "/v1/payment_sources/external_checkout",
            "/v1/payment_sources/setup-tokens",
            "/v1/payment_sources/setup-tokens/{id}/tokens",
            "/v1/charges/wallet/capture",
            "/v1/charges/wallet/{id}/decline",
            "/v1/charges/wallet/callback",
            "/v1/gateways/{id}/wallet-config"
        ])
    }

    func testEveryTemplate_IsATemplateOfItself() {
        for template in RouteTemplates.templates {
            XCTAssertEqual(RouteTemplates.template(template), template)
        }
    }

    func testRealIds_MapToTheirTemplates() {
        XCTAssertEqual(RouteTemplates.template("/v1/payment_sources/setup-tokens/5f8a1c2e9b3d4a6f7e8c9d0a/tokens"),
                       "/v1/payment_sources/setup-tokens/{id}/tokens")
        XCTAssertEqual(RouteTemplates.template("/v1/charges/wallet/6a1b2c3d4e5f/decline"), "/v1/charges/wallet/{id}/decline")
        XCTAssertEqual(RouteTemplates.template("/v1/gateways/63f0c1d2e3a4b5c6d7e8f901/wallet-config"),
                       "/v1/gateways/{id}/wallet-config")
    }

    func testQueryAndFragment_AreDropped() {
        XCTAssertEqual(RouteTemplates.template("/v1/charges/wallet/capture?capture=true"), "/v1/charges/wallet/capture")
        XCTAssertEqual(RouteTemplates.template("/v1/charges/wallet/callback?mobile=true#top"), "/v1/charges/wallet/callback")
        XCTAssertEqual(RouteTemplates.template("/v1/payment_sources/tokens#section?x=1"), "/v1/payment_sources/tokens")
    }

    func testOnlySlashesOrNothing_IsTheRoot() {
        XCTAssertEqual(RouteTemplates.template(""), "/")
        XCTAssertEqual(RouteTemplates.template("/"), "/")
        XCTAssertEqual(RouteTemplates.template("//"), "/")
        XCTAssertEqual(RouteTemplates.template("?a=1"), "/")
    }

    /// A16 P1: an empty ID keeps its segment, so it still becomes `{id}`.
    func testAnEmptyIdSegment_BecomesThePlaceholder() {
        XCTAssertEqual(RouteTemplates.template("/v1/gateways//wallet-config"), "/v1/gateways/{id}/wallet-config")
        XCTAssertEqual(RouteTemplates.template("/v1/charges/wallet//decline"), "/v1/charges/wallet/{id}/decline")
    }

    func testTwoIds_FallBackToAPlaceholderEach() {
        XCTAssertEqual(RouteTemplates.template("/v1/charges/wallet/6a1b2c/7d8e9f/decline"), "/v1/charges/wallet/{id}/{id}/decline")
    }

    func testTheFallback_KeepsTemplateLiteralsAndVersions_AsAndroid() {
        XCTAssertEqual(RouteTemplates.template("/v2/charges/x"), "/v2/charges/{id}")
        XCTAssertEqual(RouteTemplates.template("/v1/customers/x/tokens"), "/v1/{id}/{id}/tokens")
        XCTAssertEqual(RouteTemplates.template("/v1/charges"), "/v1/charges")
        XCTAssertEqual(RouteTemplates.template("v1/payment_sources/tokens/"), "/v1/payment_sources/tokens")
    }

    func testAFallbackNeverKeepsARealValue() {
        let path = "/v1/vault/payment_sources/\(SensitiveSamples.cardNumber)/\(SensitiveSamples.email)"
        let template = RouteTemplates.template(path)

        XCTAssertEqual(template, "/v1/{id}/payment_sources/{id}/{id}")
    }

    /// Every template passes the allowlist's shape rule as `url.template` and inside `paydock.group.key`.
    func testEveryTemplate_PassesTheAllowlistShapeRules() {
        let paths = RouteTemplates.templates + ["/", "/v2/charges/x", "/v1/charges/wallet/a/b/decline"]
        for path in paths {
            let template = RouteTemplates.template(path)
            let event = TelemetryEvent.networkFailure(method: .post, urlTemplate: template,
                                                      serverAddress: "api-sandbox.paydock.com",
                                                      failure: .httpStatus(code: 400))
            let built = RecordFactory.create(PendingRecord(id: "\(SensitiveSamples.sessionId)-1",
                                                           sessionId: SensitiveSamples.sessionId, event: event,
                                                           createdAt: SensitiveSamples.builtAt), connection: .wifi)
            let kept = Allowlist.filter(built)

            XCTAssertEqual(kept.value("url.template"), .string(template), path)
            XCTAssertEqual(kept.value("paydock.group.key"), .string("http POST \(template) 400"), path)
        }
    }
}
