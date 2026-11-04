//
//  TelemetryEffectHandlerTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryEffectHandlerTests: XCTestCase {

    private final class DelayLog: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [Int64] = []

        var values: [Int64] {
            lock.lock()
            defer { lock.unlock() }
            return items
        }

        func append(_ value: Int64) {
            lock.lock()
            items.append(value)
            lock.unlock()
        }
    }

    private let queue = RecordingRecordQueue()
    private let store = RecordingDurableStore()
    private let exporter = RecordingExporter()
    private let provider = FakeDeviceContextProvider()
    private let delays = DelayLog()

    private lazy var handler = TelemetryEffectHandler(
        queue: queue,
        store: store,
        exporter: exporter,
        deviceContext: provider,
        scheduleFlush: { [delays] delay in delays.append(delay) }
    )

    private let record = PendingRecord(id: "session-0", sessionId: "session", event: TelemetryFixtures.crash(), firstSeenAt: 1)

    func testEnqueue_OffersToTheQueue() {
        handler.run([.enqueue(record)])

        XCTAssertEqual(queue.offered, [record])
        XCTAssertEqual(store.saved, [])
    }

    func testPersist_SavesToTheStore() {
        handler.run([.persist(record)])

        XCTAssertEqual(store.saved, [record])
        XCTAssertEqual(queue.offered, [])
    }

    func testScheduleFlush_CallsTheClosure() {
        handler.run([.scheduleFlush(delayMilliseconds: 10_000)])

        XCTAssertEqual(delays.values, [10_000])
    }

    func testExport_HandsTheExporterABatch_WithTheInstallationId() {
        let second = PendingRecord(id: "session-1", sessionId: "session", event: TelemetryFixtures.sdkError(), firstSeenAt: 2)
        let third = PendingRecord(id: "session-2", sessionId: "session", event: TelemetryFixtures.sdkError(), firstSeenAt: 3)

        handler.run([.enqueue(record), .enqueue(second), .enqueue(third), .export(maxRecords: 2)])

        XCTAssertEqual(queue.drainRequests, [2])
        XCTAssertEqual(exporter.batches, [ExportBatch(resource: FakeDeviceContextProvider.attributes, records: [record, second])])
        XCTAssertEqual(exporter.batches.first?.resource.appInstallationId, FakeDeviceContextProvider.installationId)
        XCTAssertEqual(queue.size(), 1)
    }

    func testExport_OfAnEmptyDrain_ExportsNothing() {
        handler.run([.export(maxRecords: 50)])

        XCTAssertEqual(queue.drainRequests, [50])
        XCTAssertEqual(exporter.batches, [])
        XCTAssertEqual(provider.callCount, 0)
    }

    func testDrop_DoesNothing() {
        handler.run([.drop(.disabled), .drop(.levelOff), .drop(.levelFiltered)])

        XCTAssertEqual(queue.offered, [])
        XCTAssertEqual(store.saved, [])
        XCTAssertEqual(exporter.batches, [])
        XCTAssertEqual(delays.values, [])
    }

    func testEffects_RunInOrder() {
        handler.run([.persist(record), .enqueue(record), .export(maxRecords: 50), .scheduleFlush(delayMilliseconds: 5)])

        XCTAssertEqual(store.saved, [record])
        XCTAssertEqual(exporter.batches.map(\.records), [[record]])
        XCTAssertEqual(delays.values, [5])
    }

    func testNoOpPorts() {
        NoOpRecordQueue().offer(record)
        NoOpDurableStore().save(record)

        XCTAssertEqual(NoOpRecordQueue().drain(max: 50), [])
        XCTAssertEqual(NoOpRecordQueue().size(), 0)
        XCTAssertEqual(NoOpDurableStore().loadAll(), [])
        XCTAssertEqual(NoOpExporter().export(ExportBatch(resource: FakeDeviceContextProvider.attributes, records: [record])), .success)
    }

    func testResourceAttributes_AsMap_HoldsTheFourteenKeys() {
        let map = FakeDeviceContextProvider.attributes.asMap()

        XCTAssertEqual(map, [
            "service.name": .string("paydock-mobile-sdk"),
            "service.namespace": .string("paydock"),
            "service.version": .string("0.0.0-test"),
            "paydock.sdk.platform": .string("ios"),
            "paydock.telemetry.spec_version": .int(1),
            "deployment.environment.name": .string("sandbox"),
            "os.name": .string("iOS"),
            "os.version": .string("17.0"),
            "device.manufacturer": .string("Apple"),
            "device.model.identifier": .string("iPhone15,2"),
            "app.installation.id": .string(FakeDeviceContextProvider.installationId),
            "paydock.app.id": .string("com.paydock.sample"),
            "paydock.app.version": .string("1.0.0"),
            "paydock.app.debuggable": .bool(true)
        ])
        XCTAssertEqual(map.count, 14)
    }
}
