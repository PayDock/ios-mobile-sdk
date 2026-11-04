//
//  ActiveTelemetry.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// Bound when activation passes. `report` hands the event to the dispatcher and returns; the reducer and the effect
/// handler run only on the dispatcher's queue.
package final class ActiveTelemetry: Telemetry, TelemetryRuntime, @unchecked Sendable {
    package struct Ports: Sendable {
        package let queue: any RecordQueue
        package let store: any DurableStore
        package let exporter: any Exporter

        package init(queue: any RecordQueue = NoOpRecordQueue(), store: any DurableStore = NoOpDurableStore(),
                     exporter: any Exporter = NoOpExporter()) {
            self.queue = queue
            self.store = store
            self.exporter = exporter
        }
    }

    package let credentials: TelemetryCredentials
    package let level: TelemetryLevel
    /// `idGenerator.newId()`, once, at init.
    package let sessionId: String
    package var isActive: Bool { true }

    /// Nil until `start()` has run on the queue.
    package var resourceAttributes: ResourceAttributes? {
        lock.lock()
        defer { lock.unlock() }
        return storedResourceAttributes
    }

    private let deviceContextProvider: any DeviceContextProvider
    private let clock: any Clock
    private let dispatcher: any TelemetryDispatcher
    private let lock = NSLock()
    private var state: TelemetryState
    private var started = false
    private var storedResourceAttributes: ResourceAttributes?
    private var handler: TelemetryEffectHandler?

    package init(
        credentials: TelemetryCredentials,
        level: TelemetryLevel,
        deviceContextProvider: any DeviceContextProvider,
        clock: any Clock = SystemClock(),
        idGenerator: any IdGenerator = RandomIdGenerator(),
        dispatcher: any TelemetryDispatcher = SerialTelemetryDispatcher(),
        ports: Ports = Ports()
    ) {
        self.credentials = credentials
        self.level = level
        self.deviceContextProvider = deviceContextProvider
        self.clock = clock
        self.dispatcher = dispatcher
        let sessionId = idGenerator.newId()
        self.sessionId = sessionId
        self.state = TelemetryState(level: level, enabled: true, sessionId: sessionId)
        self.handler = TelemetryEffectHandler(
            queue: ports.queue,
            store: ports.store,
            exporter: ports.exporter,
            deviceContext: deviceContextProvider,
            scheduleFlush: { [weak self] delay in
                self?.dispatcher.postDelayed(milliseconds: delay) { [weak self] in self?.dispatch(.flush) }
            }
        )
    }

    package func report(_ event: TelemetryEvent) {
        dispatcher.post { [self] in dispatch(.reported(event)) }
    }

    package func start() {
        lock.lock()
        let isFirst = !started
        started = true
        lock.unlock()
        guard isFirst else {
            return
        }
        dispatcher.post { [self] in
            let attributes = deviceContextProvider.current()
            lock.lock()
            storedResourceAttributes = attributes
            lock.unlock()
        }
    }

    /// For tests.
    package func currentState() -> TelemetryState {
        lock.lock()
        defer { lock.unlock() }
        return state
    }

    /// Runs only on the dispatcher's queue: reduce, store the new state, hand the effects to the handler.
    private func dispatch(_ intent: TelemetryIntent) {
        let now = clock.now()
        lock.lock()
        let result = TelemetryReducer.reduce(state, intent, now: now)
        state = result.state
        lock.unlock()
        handler?.run(result.effects)
    }
}
#endif
