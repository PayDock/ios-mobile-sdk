//
//  SdkImageReading.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Reads the SDK's image and the type points of its build (spec § 7.2).
package protocol SdkImageReading: Sendable {
    /// The image holding the SDK's code and its type points; nil when it can't be read.
    func read() -> (image: SdkImage, points: [TypePoint])?
}
