//
//  NoOpSdkImageReader.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Reads nothing: `read()` returns nil.
package struct NoOpSdkImageReader: SdkImageReading {
    package init() {}
    package func read() -> (image: SdkImage, points: [TypePoint])? { nil }
}
