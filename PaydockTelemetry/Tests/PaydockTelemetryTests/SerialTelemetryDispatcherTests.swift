//
//  SerialTelemetryDispatcherTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import PaydockTelemetry
import XCTest

final class SerialTelemetryDispatcherTests: XCTestCase {

    private final class Log: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [Int] = []

        var values: [Int] {
            lock.lock()
            defer { lock.unlock() }
            return items
        }

        func append(_ value: Int) {
            lock.lock()
            items.append(value)
            lock.unlock()
        }
    }

    func testConstants() {
        XCTAssertEqual(SerialTelemetryDispatcher.defaultCapacity, 1_000)
        XCTAssertEqual(SerialTelemetryDispatcher.label, "com.paydock.telemetry")
    }

    func testPost_KeepsOrder() {
        let dispatcher = SerialTelemetryDispatcher()
        let log = Log()
        let done = expectation(description: "every task ran")

        for value in 0..<200 {
            XCTAssertTrue(dispatcher.post { log.append(value) })
        }
        dispatcher.post { done.fulfill() }

        wait(for: [done], timeout: 2)
        XCTAssertEqual(log.values, Array(0..<200))
    }

    func testFullQueue_ReturnsFalseAtOnce_AndAcceptsAgainOnceDrained() {
        let dispatcher = SerialTelemetryDispatcher(capacity: 2)
        let gate = DispatchSemaphore(value: 0)
        let log = Log()
        defer { gate.signal() }

        XCTAssertTrue(dispatcher.post { gate.wait() })
        XCTAssertTrue(dispatcher.post { log.append(1) })

        let started = Date()
        XCTAssertFalse(dispatcher.post { log.append(2) })
        XCTAssertFalse(dispatcher.postDelayed(milliseconds: 1) { log.append(3) })
        XCTAssertLessThan(Date().timeIntervalSince(started), 0.1)

        gate.signal()
        let drained = expectation(description: "accepted again")
        let deadline = Date().addingTimeInterval(1.5)
        while !dispatcher.post({ drained.fulfill() }) && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.005)
        }
        wait(for: [drained], timeout: 2)
        XCTAssertEqual(log.values, [1])
    }

    func testPostDelayed_RunsLater() {
        let dispatcher = SerialTelemetryDispatcher()
        let log = Log()
        let ran = expectation(description: "delayed task ran")
        let started = Date()

        XCTAssertTrue(dispatcher.postDelayed(milliseconds: 100) {
            log.append(1)
            ran.fulfill()
        })
        XCTAssertEqual(log.values, [])

        wait(for: [ran], timeout: 2)
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(started), 0.09)
        XCTAssertEqual(log.values, [1])
    }
}
#endif
