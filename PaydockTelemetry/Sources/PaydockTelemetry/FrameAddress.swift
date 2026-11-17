//
//  FrameAddress.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// A frame to classify: its image's name, its UUID when known, and its offset in that image.
package struct FrameAddress: Sendable, Equatable {
    package let imageName: String
    package let uuid: String?
    package let offset: UInt64

    package init(imageName: String, uuid: String?, offset: UInt64) {
        self.imageName = imageName
        self.uuid = uuid
        self.offset = offset
    }
}
