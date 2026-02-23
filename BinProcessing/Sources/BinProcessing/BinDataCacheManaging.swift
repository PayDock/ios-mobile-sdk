//
//  BinDataCacheManaging.swift
//  BinProcessing
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Abstraction over BIN data cache operations consumed by `BinDataRefreshCoordinator`.
/// Allows substitution of a test double in unit tests without touching production code.
protocol BinDataCacheManaging: AnyObject {
    /// Returns true if a refresh check should be run (no cached file, or last fetch > 1 hour ago).
    func shouldRefreshOnForeground() -> Bool
    /// Performs a HEAD-then-conditional-GET refresh, downloading only when the remote file has changed.
    func refreshBinDataIfNeeded() async
}
