//
//  InstallationIdStoreTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// MD-13: one random ID per install, the same across launches.
final class InstallationIdStoreTests: XCTestCase {

    func testKey_IsTheDocumentedOne() {
        XCTAssertEqual(InstallationIdStore.key, "paydock_telemetry_installation_id")
    }

    func testGetOrCreate_SameBackingStore_GivesTheSameIdAcrossNewInstances() {
        let backing = InMemoryKeyValueStore()

        let first = InstallationIdStore(store: backing, idGenerator: RandomIdGenerator()).getOrCreate()
        let relaunched = InstallationIdStore(store: backing, idGenerator: RandomIdGenerator()).getOrCreate()

        XCTAssertEqual(first, relaunched)
        XCTAssertEqual(backing.writeCount, 1)
        XCTAssertEqual(backing.contents, [InstallationIdStore.key: first])
    }

    func testGetOrCreate_FreshBackingStore_GivesADifferentId() {
        let first = InstallationIdStore(store: InMemoryKeyValueStore(), idGenerator: RandomIdGenerator()).getOrCreate()
        let reinstalled = InstallationIdStore(store: InMemoryKeyValueStore(), idGenerator: RandomIdGenerator()).getOrCreate()

        XCTAssertNotEqual(first, reinstalled)
    }

    func testGetOrCreate_ExistingId_IsReturnedWithoutWriting() {
        let backing = InMemoryKeyValueStore([InstallationIdStore.key: "existing-id"])

        let id = InstallationIdStore(store: backing, idGenerator: SequentialIdGenerator()).getOrCreate()

        XCTAssertEqual(id, "existing-id")
        XCTAssertEqual(backing.writeCount, 0)
    }

    func testInit_WritesNothingBeforeGetOrCreate() {
        let backing = InMemoryKeyValueStore()

        _ = InstallationIdStore(store: backing, idGenerator: RandomIdGenerator())

        XCTAssertEqual(backing.readCount, 0)
        XCTAssertEqual(backing.writeCount, 0)
        XCTAssertTrue(backing.contents.isEmpty)
    }

    #if DEBUG
    func testUserDefaultsStore_RoundTripsThroughAThrowawaySuite() throws {
        let suiteName = "com.paydock.telemetry.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let first = InstallationIdStore(store: UserDefaultsKeyValueStore(defaults: defaults), idGenerator: RandomIdGenerator())
            .getOrCreate()
        let relaunched = InstallationIdStore(store: UserDefaultsKeyValueStore(defaults: defaults), idGenerator: RandomIdGenerator())
            .getOrCreate()

        XCTAssertEqual(first, relaunched)
        XCTAssertEqual(defaults.string(forKey: InstallationIdStore.key), first)
        XCTAssertNotNil(UUID(uuidString: first))
    }
    #endif
}
