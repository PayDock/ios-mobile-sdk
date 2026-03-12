//
//  BinDataCacheManagerTests.swift
//  BinProcessingTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import BinProcessing

// MARK: - Mock URL Protocol

/// URLProtocol subclass that intercepts all requests and delegates to a static handler.
final class MockURLProtocol: URLProtocol {

    /// Set this before each test to control the response for any outgoing request.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override static func canInit(with request: URLRequest) -> Bool { true }
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Test Constants

/// Mirrors Android's `BinDataTestConstants` object in `MockNetworkModule.kt`.
enum BinDataTestConstants {
    static let mockLastModified = "Wed, 18 Feb 2026 10:00:00 GMT"
    static let mockLastModifiedOld = "Wed, 17 Feb 2026 10:00:00 GMT"
    static let mockEtag = "\"abc123\""
    static let mockEtagOld = "\"old-etag\""
    // Valid iOS card-schemes.json format (matches CardSchemeData CodingKeys).
    static let mockBinDataContent = #"{"s":{"v":"visa"},"2":{"41":"v"},"4":{},"6":{},"r":{"2":[],"4":[],"6":[],"8":[]}}"#
    static var mockBinDataContentData: Data { Data(mockBinDataContent.utf8) }
}

// MARK: - BinDataCacheManagerTests

/// Unit tests for `BinDataCacheManager`.
///
/// Tests verify the caching logic for BIN data including:
/// - Cache file read / absent / empty behaviour
/// - HEAD request comparison for cache freshness (Last-Modified preferred, ETag fallback)
/// - Download and persistence on success, error propagation on failure
/// - Foreground refresh timing logic (1-hour threshold)
final class BinDataCacheManagerTests: XCTestCase {

    private var sut: BinDataCacheManager!
    private var tempDirectory: URL!
    private var testDefaults: UserDefaults!
    private var mockSession: URLSession!

    override func setUp() {
        super.setUp()

        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        testDefaults = UserDefaults(suiteName: UUID().uuidString)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)

        sut = BinDataCacheManager(
            session: mockSession,
            defaults: testDefaults,
            cacheDirectory: tempDirectory
        )

        setupSuccessHandler()
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        if let suiteName = testDefaults.persistentDomain(forName: testDefaults.description) {
            _ = suiteName
        }
        testDefaults.removePersistentDomain(forName: testDefaults.description)
        try? FileManager.default.removeItem(at: tempDirectory)
        sut = nil
        mockSession = nil
        testDefaults = nil
        tempDirectory = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Responds with both Last-Modified and ETag by default.
    private func setupSuccessHandler(
        lastModified: String? = BinDataTestConstants.mockLastModified,
        etag: String? = BinDataTestConstants.mockEtag
    ) {
        MockURLProtocol.requestHandler = { request in
            if request.httpMethod == "HEAD" {
                var headers: [String: String] = [:]
                if let lastMod = lastModified { headers["Last-Modified"] = lastMod }
                if let etagVal = etag { headers["ETag"] = etagVal }
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: headers
                )!
                return (response, Data())
            } else {
                var headers: [String: String] = ["Content-Type": "application/json"]
                if let lastMod = lastModified { headers["Last-Modified"] = lastMod }
                if let etagVal = etag { headers["ETag"] = etagVal }
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: headers
                )!
                return (response, BinDataTestConstants.mockBinDataContentData)
            }
        }
    }

    /// HEAD/GET return ETag only, no Last-Modified.
    private func setupEtagOnlyHandler() {
        setupSuccessHandler(lastModified: nil, etag: BinDataTestConstants.mockEtag)
    }

    /// All requests throw a network error.
    private func setupFailureHandler() {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }
    }

    /// Sets up a handler that returns a non-2xx status code with a body (e.g. HTML error page).
    private func setupNon2xxHandler(statusCode: Int, body: String) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: [
                    "Content-Type": "text/html",
                    "Last-Modified": "Wed, 01 Jan 2020 00:00:00 GMT",
                    "ETag": "\"error-etag\""
                ]
            )!
            return (response, Data(body.utf8))
        }
    }

    /// Writes mock BIN data to the cache file, simulating an existing cache.
    private func writeCacheFile() throws {
        let fileURL = tempDirectory.appendingPathComponent("card-schemes-cached.json")
        try BinDataTestConstants.mockBinDataContentData.write(to: fileURL)
    }

    // MARK: - getCachedBinData Tests

    func testGetCachedBinDataReturnsNilWhenNoCachedFileExists() {
        XCTAssertNil(sut.getCachedBinData())
    }

    func testGetCachedBinDataReturnsDataWhenCachedFileExistsWithContent() throws {
        try writeCacheFile()
        let result = sut.getCachedBinData()
        XCTAssertNotNil(result)
        XCTAssertEqual(result, BinDataTestConstants.mockBinDataContentData)
    }

    func testGetCachedBinDataReturnsNilWhenCachedFileIsEmpty() throws {
        let fileURL = tempDirectory.appendingPathComponent("card-schemes-cached.json")
        try Data().write(to: fileURL)
        XCTAssertNil(sut.getCachedBinData())
    }

    // MARK: - shouldRefreshOnForeground Tests

    func testShouldRefreshOnForegroundReturnsTrueWhenNoCacheExists() {
        XCTAssertTrue(sut.shouldRefreshOnForeground())
    }

    func testShouldRefreshOnForegroundReturnsTrueWhenLastFetchTimeIsZero() throws {
        try writeCacheFile()
        // testDefaults has no fetch time stored — defaults to 0
        XCTAssertTrue(sut.shouldRefreshOnForeground())
    }

    func testShouldRefreshOnForegroundReturnsTrueWhenLastFetchWasMoreThanOneHourAgo() throws {
        try writeCacheFile()
        let twoHoursAgo = Date().timeIntervalSince1970 - (2 * 3600)
        testDefaults.set(twoHoursAgo, forKey: sut.prefsKeyLastFetchTime)
        XCTAssertTrue(sut.shouldRefreshOnForeground())
    }

    func testShouldRefreshOnForegroundReturnsFalseWhenLastFetchWasLessThanOneHourAgo() throws {
        try writeCacheFile()
        let thirtyMinutesAgo = Date().timeIntervalSince1970 - (30 * 60)
        testDefaults.set(thirtyMinutesAgo, forKey: sut.prefsKeyLastFetchTime)
        XCTAssertFalse(sut.shouldRefreshOnForeground())
    }

    func testShouldRefreshOnForegroundReturnsTrueWhenCacheExistsAndExactlyOneHourHasPassed() throws {
        try writeCacheFile()
        let exactlyOneHourAgo = Date().timeIntervalSince1970 - 3600
        testDefaults.set(exactlyOneHourAgo, forKey: sut.prefsKeyLastFetchTime)
        XCTAssertTrue(sut.shouldRefreshOnForeground())
    }

    // MARK: - shouldDownloadFullFile Tests

    func testShouldDownloadFullFileReturnsTrueWhenNoCacheExists() async {
        let result = await sut.shouldDownloadFullFile()
        XCTAssertEqual(result, true)
    }

    func testShouldDownloadFullFileReturnsTrueWhenLastModifiedHeaderDiffersFromStored() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModifiedOld, forKey: sut.prefsKeyLastModified)
        // Mock returns MOCK_LAST_MODIFIED (different from stored OLD value)
        setupSuccessHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertEqual(result, true)
    }

    func testShouldDownloadFullFileReturnsTrueWhenETagDiffersFromStoredAndNoLastModified() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockEtagOld, forKey: sut.prefsKeyEtag)
        // Mock returns MOCK_ETAG (different from stored OLD), no Last-Modified (ETag-only path)
        setupEtagOnlyHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertEqual(result, true)
    }

    func testShouldDownloadFullFileReturnsFalseWhenLastModifiedHeaderMatchesStored() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModified, forKey: sut.prefsKeyLastModified)
        // Mock returns same MOCK_LAST_MODIFIED
        setupSuccessHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertEqual(result, false)
    }

    func testShouldDownloadFullFileReturnsFalseWhenETagMatchesStoredAndNoLastModified() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockEtag, forKey: sut.prefsKeyEtag)
        // Mock returns same MOCK_ETAG, no Last-Modified
        setupEtagOnlyHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertEqual(result, false)
    }

    func testShouldDownloadFullFileReturnsNilWhenHEADRequestFailsWithExistingCache() async throws {
        try writeCacheFile()
        setupFailureHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertNil(result, "Should return nil when HEAD fails so caller knows freshness wasn't verified")
    }

    // MARK: - downloadAndCacheBinData Tests

    func testDownloadAndCacheBinDataSavesFileAndUpdatesPersistenceOnSuccess() async throws {
        setupSuccessHandler()

        try await sut.downloadAndCacheBinData()

        let cachedFileURL = tempDirectory.appendingPathComponent("card-schemes-cached.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: cachedFileURL.path))

        let savedData = try Data(contentsOf: cachedFileURL)
        XCTAssertEqual(savedData, BinDataTestConstants.mockBinDataContentData)

        XCTAssertEqual(
            testDefaults.string(forKey: sut.prefsKeyLastModified),
            BinDataTestConstants.mockLastModified
        )
        XCTAssertEqual(
            testDefaults.string(forKey: sut.prefsKeyEtag),
            BinDataTestConstants.mockEtag
        )
        XCTAssertGreaterThan(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), 0)
    }

    func testDownloadAndCacheBinDataThrowsWhenNetworkRequestFails() async {
        setupFailureHandler()
        do {
            try await sut.downloadAndCacheBinData()
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testDownloadAndCacheBinDataThrowsOnNon2xxStatusAndDoesNotCorruptCache() async throws {
        // Pre-populate a valid cache so we can verify it's not overwritten
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModified, forKey: sut.prefsKeyLastModified)
        testDefaults.set(BinDataTestConstants.mockEtag, forKey: sut.prefsKeyEtag)
        let originalFetchTime = Date().timeIntervalSince1970 - 7200
        testDefaults.set(originalFetchTime, forKey: sut.prefsKeyLastFetchTime)

        // Setup handler that returns 404 with HTML error page body
        setupNon2xxHandler(statusCode: 404, body: "<html><body>Not Found</body></html>")

        do {
            try await sut.downloadAndCacheBinData()
            XCTFail("Expected an error to be thrown for non-2xx response")
        } catch {
            // Verify error is thrown
            XCTAssertNotNil(error)
        }

        // Verify cache file was NOT overwritten with error page
        let cachedData = sut.getCachedBinData()
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData, BinDataTestConstants.mockBinDataContentData)

        // Verify UserDefaults were NOT updated
        XCTAssertEqual(testDefaults.string(forKey: sut.prefsKeyLastModified), BinDataTestConstants.mockLastModified)
        XCTAssertEqual(testDefaults.string(forKey: sut.prefsKeyEtag), BinDataTestConstants.mockEtag)
        XCTAssertEqual(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), originalFetchTime)
    }

    func testDownloadAndCacheBinDataThrowsOn500ServerError() async {
        setupNon2xxHandler(statusCode: 500, body: "Internal Server Error")

        do {
            try await sut.downloadAndCacheBinData()
            XCTFail("Expected an error to be thrown for 500 response")
        } catch {
            XCTAssertNotNil(error)
        }

        // Verify no cache file was created
        XCTAssertNil(sut.getCachedBinData())
        XCTAssertEqual(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), 0)
    }

    // MARK: - refreshBinDataIfNeeded Tests

    func testRefreshBinDataIfNeededSkipsDownloadButUpdatesTimestampWhenLastModifiedMatches() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModified, forKey: sut.prefsKeyLastModified)
        // Mock returns same Last-Modified → shouldDownloadFullFile returns false → no download
        setupSuccessHandler()

        let originalData = sut.getCachedBinData()

        await sut.refreshBinDataIfNeeded()

        // Cache file should not have been re-downloaded (content unchanged)
        XCTAssertEqual(sut.getCachedBinData(), originalData)

        // But fetch time SHOULD be updated to reset the 1-hour window and prevent repeated HEAD requests
        XCTAssertGreaterThan(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), 0)
    }

    func testRefreshBinDataIfNeededDownloadsAndCachesWhenNoCacheExists() async throws {
        setupSuccessHandler()

        await sut.refreshBinDataIfNeeded()

        let cachedFileURL = tempDirectory.appendingPathComponent("card-schemes-cached.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: cachedFileURL.path))
        XCTAssertGreaterThan(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), 0)
    }

    func testRefreshBinDataIfNeededPreventsRepeatedHEADRequestsAfterSuccessfulCheck() async throws {
        // Scenario: Cache exists, headers match, 1-hour window has expired
        // Expected: HEAD check succeeds, no download, but timestamp updated so next foreground skips HEAD
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModified, forKey: sut.prefsKeyLastModified)
        let twoHoursAgo = Date().timeIntervalSince1970 - 7200
        testDefaults.set(twoHoursAgo, forKey: sut.prefsKeyLastFetchTime)
        setupSuccessHandler()

        // First check: shouldRefreshOnForeground returns true (2 hours > 1 hour threshold)
        XCTAssertTrue(sut.shouldRefreshOnForeground())

        await sut.refreshBinDataIfNeeded()

        // After refresh: timestamp should be updated to now, so shouldRefreshOnForeground returns false
        XCTAssertFalse(sut.shouldRefreshOnForeground())
    }

    func testRefreshBinDataIfNeededDoesNotUpdateTimestampWhenHEADFails() async throws {
        // Scenario: Cache exists, 1-hour window expired, but HEAD request fails (network error)
        // Expected: Timestamp should NOT be updated so the next foreground can retry
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModified, forKey: sut.prefsKeyLastModified)
        let twoHoursAgo = Date().timeIntervalSince1970 - 7200
        testDefaults.set(twoHoursAgo, forKey: sut.prefsKeyLastFetchTime)
        setupFailureHandler()

        // Precondition: shouldRefreshOnForeground returns true (2 hours > 1 hour threshold)
        XCTAssertTrue(sut.shouldRefreshOnForeground())

        await sut.refreshBinDataIfNeeded()

        // Timestamp should NOT be updated — HEAD failed, freshness wasn't verified
        XCTAssertEqual(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), twoHoursAgo)

        // Next foreground should still trigger a refresh attempt
        XCTAssertTrue(sut.shouldRefreshOnForeground())
    }
}
