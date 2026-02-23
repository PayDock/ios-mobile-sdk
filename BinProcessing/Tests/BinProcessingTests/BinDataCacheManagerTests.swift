//
//  BinDataCacheManagerTests.swift
//  BinProcessingTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import BinProcessing

// MARK: - Mock URL Protocol

/// URLProtocol subclass that intercepts all requests and delegates to a static handler.
/// Mirrors Android's Ktor `MockEngine` used in `BinDataCacheManagerTest`.
final class MockURLProtocol: URLProtocol {

    /// Set this before each test to control the response for any outgoing request.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

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
    /// Valid iOS card-schemes.json format (matches CardSchemeData CodingKeys).
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
///
/// Mirrors Android's `BinDataCacheManagerTest`.
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

    /// Mirrors Android's `mockBinDataSuccessModule` — responds with both Last-Modified and ETag by default.
    private func setupSuccessHandler(
        lastModified: String? = BinDataTestConstants.mockLastModified,
        etag: String? = BinDataTestConstants.mockEtag
    ) {
        MockURLProtocol.requestHandler = { request in
            if request.httpMethod == "HEAD" {
                var headers: [String: String] = [:]
                if let lm = lastModified { headers["Last-Modified"] = lm }
                if let e = etag { headers["ETag"] = e }
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: headers
                )!
                return (response, Data())
            } else {
                var headers: [String: String] = ["Content-Type": "application/json"]
                if let lm = lastModified { headers["Last-Modified"] = lm }
                if let e = etag { headers["ETag"] = e }
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

    /// Mirrors Android's `mockBinDataEtagOnlyModule` — HEAD/GET return ETag only, no Last-Modified.
    private func setupEtagOnlyHandler() {
        setupSuccessHandler(lastModified: nil, etag: BinDataTestConstants.mockEtag)
    }

    /// Mirrors Android's `mockBinDataFailureModule` — all requests throw a network error.
    private func setupFailureHandler() {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
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
        XCTAssertTrue(result)
    }

    func testShouldDownloadFullFileReturnsTrueWhenLastModifiedHeaderDiffersFromStored() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModifiedOld, forKey: sut.prefsKeyLastModified)
        // Mock returns MOCK_LAST_MODIFIED (different from stored OLD value)
        setupSuccessHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertTrue(result)
    }

    func testShouldDownloadFullFileReturnsTrueWhenETagDiffersFromStoredAndNoLastModified() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockEtagOld, forKey: sut.prefsKeyEtag)
        // Mock returns MOCK_ETAG (different from stored OLD), no Last-Modified (ETag-only path)
        setupEtagOnlyHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertTrue(result)
    }

    func testShouldDownloadFullFileReturnsFalseWhenLastModifiedHeaderMatchesStored() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModified, forKey: sut.prefsKeyLastModified)
        // Mock returns same MOCK_LAST_MODIFIED
        setupSuccessHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertFalse(result)
    }

    func testShouldDownloadFullFileReturnsFalseWhenETagMatchesStoredAndNoLastModified() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockEtag, forKey: sut.prefsKeyEtag)
        // Mock returns same MOCK_ETAG, no Last-Modified
        setupEtagOnlyHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertFalse(result)
    }

    func testShouldDownloadFullFileReturnsFalseWhenHEADRequestFailsGracefulDegradationWithExistingCache() async throws {
        try writeCacheFile()
        setupFailureHandler()
        let result = await sut.shouldDownloadFullFile()
        XCTAssertFalse(result)
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

    // MARK: - refreshBinDataIfNeeded Tests

    func testRefreshBinDataIfNeededSkipsDownloadWhenLastModifiedMatches() async throws {
        try writeCacheFile()
        testDefaults.set(BinDataTestConstants.mockLastModified, forKey: sut.prefsKeyLastModified)
        // Mock returns same Last-Modified → shouldDownloadFullFile returns false → no download
        setupSuccessHandler()

        await sut.refreshBinDataIfNeeded()

        // Fetch time should not have been updated since no download occurred
        XCTAssertEqual(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), 0)
    }

    func testRefreshBinDataIfNeededDownloadsAndCachesWhenNoCacheExists() async throws {
        setupSuccessHandler()

        await sut.refreshBinDataIfNeeded()

        let cachedFileURL = tempDirectory.appendingPathComponent("card-schemes-cached.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: cachedFileURL.path))
        XCTAssertGreaterThan(testDefaults.double(forKey: sut.prefsKeyLastFetchTime), 0)
    }
}
