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

    /// Creates a card scheme detector, preferring the cached CloudFront file over the bundled JSON.
    /// Call `startBinDataRefreshCoordinator()` and `triggerBinDataRefreshAtSDKInit()` at SDK
    /// initialisation so the cache is populated; subsequent calls to this method will use the
    /// freshly downloaded data automatically.
    /// - Returns: A detector instance, or nil if both the cache and the bundled JSON are invalid.
    public static func makeCardSchemeDetector() -> CardSchemeDetector? {
        if let cachedData = BinDataCacheManager.shared.getCachedBinData(),
           let detector = CardSchemeDetector.load(from: cachedData) {
            return detector
        }
        return CardSchemeDetector.load(from: .module)
    }

    /// Creates a card scheme detector using JSON from a custom bundle.
    /// - Parameter bundle: Bundle containing `Resources/JSON/card-schemes.json` (or `card-schemes.json` at root).
    /// - Returns: A detector instance, or nil if the resource is missing or invalid.
    public static func makeCardSchemeDetector(bundle: Bundle) -> CardSchemeDetector? {
        CardSchemeDetector.load(from: bundle)
    }

    // MARK: - Refresh coordinator

    /// Starts the BIN data refresh coordinator, registering the foreground notification observer
    /// so the cache is kept up-to-date whenever the app returns to the foreground.
    /// Call once at SDK initialisation (e.g. inside `configureMobileSDK`).
    public static func startBinDataRefreshCoordinator() {
        BinDataRefreshCoordinator.shared.start()
    }

    /// Triggers a one-off BIN data refresh in the background at SDK initialisation.
    /// Uses HEAD-then-conditional-GET so the full download only happens when the remote
    /// file has changed since the last fetch.
    /// Call once at SDK initialisation after `startBinDataRefreshCoordinator()`.
    public static func triggerBinDataRefreshAtSDKInit() {
        BinDataRefreshCoordinator.shared.refreshAtSDKInit()
    }
}
