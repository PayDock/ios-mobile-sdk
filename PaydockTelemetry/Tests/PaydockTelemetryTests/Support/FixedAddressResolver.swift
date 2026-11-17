//
//  FixedAddressResolver.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Resolves the addresses inside a set of images: each image's path, load address and size, and the symbols a test
/// gives it. Any other address resolves to nil.
struct FixedAddressResolver: AddressResolving {
    struct Image {
        let path: String
        let loadAddress: UInt
        let size: UInt
        /// Symbol name by its address.
        let symbols: [UInt: String]

        init(path: String, loadAddress: UInt, size: UInt = 0x100_0000, symbols: [UInt: String] = [:]) {
            self.path = path
            self.loadAddress = loadAddress
            self.size = size
            self.symbols = symbols
        }
    }

    let images: [Image]

    init(_ images: [Image] = []) {
        self.images = images
    }

    func resolve(_ address: UInt) -> ResolvedAddress? {
        guard let image = images.first(where: { address >= $0.loadAddress && address - $0.loadAddress < $0.size }) else {
            return nil
        }
        let symbol = image.symbols.filter { $0.key <= address }.max { $0.key < $1.key }
        return ResolvedAddress(imagePath: image.path, imageLoadAddress: image.loadAddress, symbol: symbol?.value,
                               symbolAddress: symbol?.key)
    }
}
