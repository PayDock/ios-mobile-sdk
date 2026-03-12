//
//  BinDataCacheManager.swift
//  BinProcessing
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Manages fetching and caching of the BIN validation file from CloudFront so the app
/// always checks against the latest list of BIN files.
///
/// Fresh fetch is performed at:
/// - SDK initialisation
/// - App foregrounding when there is no cached file
/// - App foregrounding when the cached file exists and last successful fetch was more than 1 hour ago
///
/// Uses a HEAD request (Last-Modified / ETag) to avoid full download when the remote file is unchanged.
/// The latest file is saved in Cache Directory; all requests use the injected `URLSession`.
final class BinDataCacheManager: BinDataCacheManaging {

    static let shared = BinDataCacheManager()

    // MARK: - Constants

    private let cloudFrontURL = URL(string: "https://d25lng5khxpk7i.cloudfront.net/bin-data-au-v1.json")!
    private let cachedFilename = "card-schemes-cached.json"

    // Internal so tests can reference them directly when asserting UserDefaults state.
    let prefsKeyLastModified = "paydock_bin_last_modified"
    let prefsKeyEtag = "paydock_bin_etag"
    let prefsKeyLastFetchTime = "paydock_bin_last_fetch_time"

    private let cacheRefreshInterval: TimeInterval = 3600 // 1 hour

    // MARK: - Injected dependencies

    private let session: URLSession
    private let defaults: UserDefaults
    /// Explicit cache directory used when non-nil; falls back to Application Support when nil.
    private let directory: URL?

    // MARK: - Initialisation

    /// Production singleton — uses `URLSession.shared`, `UserDefaults.standard`, and Application Support.
    private init() {
        self.session = .shared
        self.defaults = .standard
        self.directory = nil
    }

    /// Testable initialiser — allows injecting a mock `URLSession`, an isolated `UserDefaults`
    /// suite, and a temporary directory so tests never touch the real file system or preferences.
    init(session: URLSession, defaults: UserDefaults, cacheDirectory: URL) {
        self.session = session
        self.defaults = defaults
        self.directory = cacheDirectory
    }

    // MARK: - Cached file

    /// URL to the cached BIN data file, or nil if the directory cannot be resolved.
    var cachedFileURL: URL? {
        let base = directory
            ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return base?.appendingPathComponent(cachedFilename)
    }

    /// Reads the cached BIN data file and returns its contents, or nil if it does not exist or is empty.
    func getCachedBinData() -> Data? {
        guard let url = cachedFileURL,
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              !data.isEmpty else {
            return nil
        }
        return data
    }

    // MARK: - Refresh decisions

    /// Returns true if a refresh check should run: no cached file exists, or last
    /// successful fetch was more than 1 hour ago.
    func shouldRefreshOnForeground() -> Bool {
        guard getCachedBinData() != nil else { return true }
        let lastFetchTime = defaults.double(forKey: prefsKeyLastFetchTime)
        guard lastFetchTime > 0 else { return true }
        return Date().timeIntervalSince1970 - lastFetchTime >= cacheRefreshInterval
    }

    /// Performs a HEAD request and returns whether the full file should be downloaded.
    ///
    /// - Returns:
    ///   - `true`: Download needed (no cache, or remote headers differ from stored)
    ///   - `false`: Cache verified fresh (headers match, no download needed)
    ///   - `nil`: HEAD request failed (couldn't verify; existing cache preserved but freshness unknown)
    ///
    /// Last-Modified is preferred; ETag is the fallback.
    func shouldDownloadFullFile() async -> Bool? {
        guard getCachedBinData() != nil else { return true }
        guard let remote = await fetchRemoteCacheHeaders() else { return nil }

        let storedLastModified = defaults.string(forKey: prefsKeyLastModified)
        let storedEtag = defaults.string(forKey: prefsKeyEtag)

        if let remoteLastModified = remote.lastModified {
            return remoteLastModified != storedLastModified
        } else if let remoteEtag = remote.etag {
            return remoteEtag != storedEtag
        } else {
            return storedLastModified == nil && storedEtag == nil
        }
    }

    // MARK: - Refresh orchestration

    /// Refreshes BIN data if needed: HEAD first, then GET only when remote is newer or no cache.
    /// Updates the fetch timestamp only after a successful verification (HEAD confirmed fresh or full
    /// download succeeded). If HEAD fails, the timestamp is left unchanged so the next foreground retries.
    func refreshBinDataIfNeeded() async {
        let downloadResult = await shouldDownloadFullFile()

        switch downloadResult {
        case true:
            try? await downloadAndCacheBinData()
        case false:
            // HEAD check succeeded and cache is verified fresh — update timestamp to reset the 1-hour window
            defaults.set(Date().timeIntervalSince1970, forKey: prefsKeyLastFetchTime)
        case nil:
            // HEAD request failed — don't update timestamp so next foreground can retry
            break
        }
    }

    // MARK: - Download

    /// Downloads the latest BIN data from CloudFront and caches it.
    /// Persists Last-Modified and ETag from the response and updates the last fetch timestamp.
    /// Throws if the response is not a successful 2xx status code.
    func downloadAndCacheBinData() async throws {
        let (data, response) = try await session.data(from: cloudFrontURL)

        guard let httpResponse = response as? HTTPURLResponse else { return }

        // Validate status code — reject non-2xx responses to avoid caching error pages
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else { return }

        let lastModified = httpResponse.value(forHTTPHeaderField: "Last-Modified")
        let etag = httpResponse.value(forHTTPHeaderField: "ETag")

        guard let fileURL = cachedFileURL else { return }

        let parentDir = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        try data.write(to: fileURL, options: .atomic)

        defaults.set(lastModified, forKey: prefsKeyLastModified)
        defaults.set(etag, forKey: prefsKeyEtag)
        defaults.set(Date().timeIntervalSince1970, forKey: prefsKeyLastFetchTime)
    }

    // MARK: - Private

    /// Performs a HEAD request and returns the cache-relevant headers.
    /// Returns nil if the request fails or neither header is present.
    private func fetchRemoteCacheHeaders() async -> (lastModified: String?, etag: String?)? {
        var request = URLRequest(url: cloudFrontURL)
        request.httpMethod = "HEAD"
        guard let (_, response) = try? await session.data(for: request),
              let httpResponse = response as? HTTPURLResponse else {
            return nil
        }
        let lastModified = httpResponse.value(forHTTPHeaderField: "Last-Modified")
        let etag = httpResponse.value(forHTTPHeaderField: "ETag")
        guard lastModified != nil || etag != nil else { return nil }
        return (lastModified, etag)
    }
}
