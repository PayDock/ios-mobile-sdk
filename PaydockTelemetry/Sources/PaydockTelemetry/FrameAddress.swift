//
//  FrameAddress.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

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

extension FrameAddress {
    /// A frame in the SDK's image (same load address) carries the image's UUID; a frame in another image only its
    /// name; an unresolved address gives none.
    package static func of(_ address: UInt, _ resolved: ResolvedAddress?, sdkImage: SdkImage?) -> FrameAddress? {
        guard let resolved, address >= resolved.imageLoadAddress else {
            return nil
        }
        let offset = UInt64(address - resolved.imageLoadAddress)
        if let sdkImage, resolved.imageLoadAddress == sdkImage.loadAddress {
            return FrameAddress(imageName: sdkImage.name, uuid: sdkImage.uuid, offset: offset)
        }
        return FrameAddress(imageName: (resolved.imagePath as NSString).lastPathComponent, uuid: nil, offset: offset)
    }
}
