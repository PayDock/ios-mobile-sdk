//
//  BinProcessing.swift
//  BinProcessing
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// BinProcessing provides functionality for card BIN (Bank Identification Number) processing
/// for use by MobileSDK CardDetailsWidget (scheme detection from PAN; no UI).
public enum BinProcessing {

    /// Module version.
    public static let version = "1.0.0"

    /// Creates a card scheme detector loaded from the package's bundled card-schemes.json.
    /// Use this from MobileSDK to resolve scheme from partial or full PAN.
    /// - Returns: A detector instance, or nil if the bundled JSON is missing or invalid.
    public static func makeCardSchemeDetector() -> CardSchemeDetector? {
        CardSchemeDetector.load(from: .module)
    }

    /// Creates a card scheme detector using JSON from a custom bundle.
    /// - Parameter bundle: Bundle containing `Resources/JSON/card-schemes.json` (or `card-schemes.json` at root).
    /// - Returns: A detector instance, or nil if the resource is missing or invalid.
    public static func makeCardSchemeDetector(bundle: Bundle) -> CardSchemeDetector? {
        CardSchemeDetector.load(from: bundle)
    }
}
