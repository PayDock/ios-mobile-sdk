//
//  TelemetryEffectHandler.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The only place with I/O. Runs each effect in turn.
package final class TelemetryEffectHandler: @unchecked Sendable {
    private let queue: any RecordQueue
    private let store: any DurableStore
    private let exporter: any Exporter
    private let deviceContext: any DeviceContextProvider
    private let scheduleFlush: @Sendable (Int64) -> Void

    package init(
        queue: any RecordQueue,
        store: any DurableStore,
        exporter: any Exporter,
        deviceContext: any DeviceContextProvider,
        scheduleFlush: @escaping @Sendable (Int64) -> Void
    ) {
        self.queue = queue
        self.store = store
        self.exporter = exporter
        self.deviceContext = deviceContext
        self.scheduleFlush = scheduleFlush
    }

    package func run(_ effects: [TelemetryEffect]) {
        for effect in effects {
            switch effect {
            case let .enqueue(record):
                queue.offer(record)
            case let .persist(record):
                store.save(record)
            case let .scheduleFlush(delayMilliseconds):
                scheduleFlush(delayMilliseconds)
            case let .export(maxRecords):
                let records = queue.drain(max: maxRecords)
                if !records.isEmpty {
                    _ = exporter.export(ExportBatch(resource: deviceContext.current(), records: records))
                }
            case .drop:
                break
            }
        }
    }
}
