//
//  BinDataRefreshCoordinator.swift
//  BinProcessing
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// App-scoped coordinator that triggers BIN data refresh so the merchant always checks
/// against the latest BIN list. Refresh runs:
/// - At SDK initialisation
/// - On app foregrounding when there is no cached file
/// - On app foregrounding when cached file exists and last fetch was more than 1 hour ago
///
/// All BIN network requests (HEAD/GET) go through the `URLSession` injected into
/// `BinDataCacheManager`.
final class BinDataRefreshCoordinator {

    static let shared = BinDataRefreshCoordinator()

    private let cacheManager: any BinDataCacheManaging
    private var isObserving = false

    // MARK: - Initialisation

    /// Production singleton — uses `BinDataCacheManager.shared`.
    private init() {
        self.cacheManager = BinDataCacheManager.shared
    }

    /// Testable initialiser — injects any `BinDataCacheManaging` conformer (e.g. a spy).
    init(cacheManager: any BinDataCacheManaging) {
        self.cacheManager = cacheManager
    }

    // MARK: - Lifecycle observation

    /// Registers a foreground notification observer`willEnterForeground`
    func start() {
        guard !isObserving else { return }
        isObserving = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleForeground),
            name: .init("UIApplicationWillEnterForegroundNotification"),
            object: nil
        )
    }

    // MARK: - SDK init trigger

    /// Triggers a one-off BIN refresh at SDK initialisation (non-blocking).
    /// Uses the same HEAD-then-conditional-GET flow as foreground refresh.
    func refreshAtSDKInit() {
        Task {
            await cacheManager.refreshBinDataIfNeeded()
        }
    }

    // MARK: - Foreground event

    /// Checks whether a refresh is needed and fires one if so.
    /// Internal so tests can drive it directly without posting a notification.
    @objc func handleForegroundEvent() {
        guard cacheManager.shouldRefreshOnForeground() else { return }
        Task {
            await cacheManager.refreshBinDataIfNeeded()
        }
    }

    @objc private func handleForeground() {
        handleForegroundEvent()
    }
}
