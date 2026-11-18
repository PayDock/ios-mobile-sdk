//
//  RouteTemplates.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Spec § 5.4's path templates and the rule that maps a real path to one (R_07), as Android's RouteTemplates.
package enum RouteTemplates {
    /// In this order, string for string.
    package static let templates: [String] = [
        "/v1/payment_sources/tokens",
        "/v1/payment_sources/external_checkout",
        "/v1/payment_sources/setup-tokens",
        "/v1/payment_sources/setup-tokens/{id}/tokens",
        "/v1/charges/wallet/capture",
        "/v1/charges/wallet/{id}/decline",
        "/v1/charges/wallet/callback",
        "/v1/gateways/{id}/wallet-config"
    ]

    private static let placeholder = "{id}"

    /// Each template's segments, in `templates` order.
    private static let templateSegments: [[String]] = templates.map { segments(of: $0) }

    /// Every segment of a template that is not the placeholder.
    private static let literals: Set<String> = Set(templateSegments.joined().filter { $0 != placeholder })

    /// Drops `?…` and `#…`; trims leading and trailing `/` and splits on `/`, keeping interior empty segments; no
    /// segment → "/". The first template with the same segment count where every position is `{id}` or the same
    /// literal; else each segment kept when it is a literal of some template or matches `v[0-9]+`, otherwise `{id}`.
    package static func template(_ path: String) -> String {
        let bare = String(path.prefix { $0 != "?" && $0 != "#" })
        let real = segments(of: bare)
        guard !real.isEmpty else {
            return "/"
        }
        if let index = templateSegments.firstIndex(where: { matches($0, real) }) {
            return templates[index]
        }
        return "/" + real.map { literals.contains($0) || isVersion($0) ? $0 : placeholder }.joined(separator: "/")
    }

    /// Empty when the path holds only slashes.
    private static func segments(of path: String) -> [String] {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.isEmpty ? [] : trimmed.components(separatedBy: "/")
    }

    private static func matches(_ template: [String], _ real: [String]) -> Bool {
        template.count == real.count && zip(template, real).allSatisfy { $0 == placeholder || $0 == $1 }
    }

    /// `v[0-9]+`.
    private static func isVersion(_ segment: String) -> Bool {
        segment.count > 1 && segment.first == "v" && segment.dropFirst().allSatisfy { $0.isASCII && $0.isNumber }
    }
}
