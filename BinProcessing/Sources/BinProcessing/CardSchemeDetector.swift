//
//  CardSchemeDetector.swift
//  BinProcessing
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Result of BIN-based card scheme detection (no visuals).
public struct CardSchemeDetectionResult {
    /// Resolved scheme name (e.g. "visa", "mastercard") for use with MobileSDK's CardScheme.
    public let scheme: String
    /// Prefix length at which the scheme was determined (2, 4, 6, or 8).
    public let detectedAt: Int
    /// Current length of the cleaned PAN.
    public let length: Int
}

/// Detects card scheme from PAN using card-schemes.json (2/4/6/8-digit prefix and ranges).
public final class CardSchemeDetector {

    private let data: CardSchemeData

    init(data: CardSchemeData) {
        self.data = data
    }

    /// Loads detector using card-schemes.json from the given bundle (e.g. `Bundle.module`).
    /// - Parameter bundle: Bundle containing `Resources/JSON/card-schemes.json`.
    /// - Returns: A detector instance, or nil if the resource is missing or invalid.
    public static func load(from bundle: Bundle) -> CardSchemeDetector? {
        let url = bundle.url(forResource: "card-schemes", withExtension: "json", subdirectory: "Resources/JSON")
            ?? bundle.url(forResource: "card-schemes", withExtension: "json")
        guard let url = url,
              let json = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(CardSchemeData.self, from: json) else {
            return nil
        }
        return CardSchemeDetector(data: decoded)
    }

    /// Loads detector from raw JSON data (e.g. a cached file downloaded from CloudFront).
    /// - Parameter data: Raw JSON data conforming to the card-schemes.json format.
    /// - Returns: A detector instance, or nil if the data is invalid or cannot be decoded.
    public static func load(from data: Data) -> CardSchemeDetector? {
        guard let decoded = try? JSONDecoder().decode(CardSchemeData.self, from: data) else {
            return nil
        }
        return CardSchemeDetector(data: decoded)
    }

    /// Detects card scheme from a PAN string (digits only; non-digits are stripped).
    /// - Parameter pan: Full or partial card number (may contain spaces or other non-digits).
    /// - Returns: Detection result with scheme name and metadata, or nil if PAN has fewer than 2 digits or no match.
    public func detectScheme(pan: String) -> CardSchemeDetectionResult? {
        let cleanedPan = pan.filter(\.isNumber)
        if cleanedPan.count < 2 { return nil }

        let length = cleanedPan.count
        var detectedScheme: String?
        var detectedAt: Int?

        if length >= 2 {
            let prefix2 = String(cleanedPan.prefix(2))
            let prefix1 = String(cleanedPan.prefix(1))
            detectedScheme = schemeName(forPrefix: prefix2, exact: data.prefix2, ranges: data.ranges["2"])
            detectedAt = detectedScheme != nil ? 2 : nil
            if detectedScheme == nil, let name = schemeName(forPrefix: prefix1, exact: data.prefix2, ranges: nil) {
                detectedScheme = name
                detectedAt = 1
            }
        }
        if length >= 4 {
            let prefix4 = String(cleanedPan.prefix(4))
            if let name = schemeName(forPrefix: prefix4, exact: data.prefix4, ranges: data.ranges["4"]) {
                detectedScheme = name
                detectedAt = 4
            }
        }
        if length >= 6 {
            let prefix6 = String(cleanedPan.prefix(6))
            if let name = schemeName(forPrefix: prefix6, exact: data.prefix6, ranges: data.ranges["6"]) {
                detectedScheme = name
                detectedAt = 6
            }
        }
        if length >= 8, data.prefix8 != nil || data.ranges["8"] != nil {
            let prefix8 = String(cleanedPan.prefix(8))
            if let name = schemeName(forPrefix: prefix8, exact: data.prefix8, ranges: data.ranges["8"]) {
                detectedScheme = name
                detectedAt = 8
            }
        }

        guard let scheme = detectedScheme, let detectedAtIdx = detectedAt else { return nil }
        return CardSchemeDetectionResult(scheme: scheme, detectedAt: detectedAtIdx, length: length)
    }

    private func schemeName(forPrefix prefix: String, exact: [String: String]?, ranges: [[String]]?) -> String? {
        if let code = exact?[prefix], let name = data.schemeNames[code] { return name }
        if let code = checkRanges(prefix: prefix, ranges: ranges), let name = data.schemeNames[code] { return name }
        return nil
    }

    private func checkRanges(prefix: String, ranges: [[String]]?) -> String? {
        guard let ranges = ranges, !ranges.isEmpty,
              let prefixNum = Int(prefix) else { return nil }
        for range in ranges {
            guard range.count >= 3,
                  let startNum = Int(range[0]),
                  let endNum = Int(range[1]) else { continue }
            if prefixNum >= startNum && prefixNum <= endNum {
                return range[2]
            }
        }
        return nil
    }
}
