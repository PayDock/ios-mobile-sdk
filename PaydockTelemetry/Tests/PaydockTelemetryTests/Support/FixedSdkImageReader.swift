//
//  FixedSdkImageReader.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Gives a set image and its points, or nothing, and counts its reads.
final class FixedSdkImageReader: SdkImageReading, @unchecked Sendable {
    private let lock = NSLock()
    private let result: (image: SdkImage, points: [TypePoint])?
    private var reads = 0

    init(image: SdkImage? = nil, points: [TypePoint] = []) {
        result = image.map { ($0, points) }
    }

    var readCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return reads
    }

    func read() -> (image: SdkImage, points: [TypePoint])? {
        lock.lock()
        reads += 1
        lock.unlock()
        return result
    }
}
