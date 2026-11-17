//
//  ResolvedAddress.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What the loader knows of a code address: its image and, when exported, the nearest symbol below it.
package struct ResolvedAddress: Sendable, Equatable {
    package let imagePath: String
    package let imageLoadAddress: UInt
    package let symbol: String?
    package let symbolAddress: UInt?

    package init(imagePath: String, imageLoadAddress: UInt, symbol: String?, symbolAddress: UInt?) {
        self.imagePath = imagePath
        self.imageLoadAddress = imageLoadAddress
        self.symbol = symbol
        self.symbolAddress = symbolAddress
    }
}
