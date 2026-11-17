//
//  Crc32.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The gzip trailer's checksum (RFC 1952): IEEE 802.3, reflected polynomial `0xEDB88320`, table-driven.
/// `checksum("123456789") == 0xCBF43926`.
package enum Crc32 {
    private static let polynomial: UInt32 = 0xEDB8_8320

    private static let table: [UInt32] = (0..<256).map { index in
        var value = UInt32(index)
        for _ in 0..<8 {
            value = value & 1 == 1 ? (value >> 1) ^ polynomial : value >> 1
        }
        return value
    }

    package static func checksum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in data {
            crc = table[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
        }
        return crc ^ 0xFFFF_FFFF
    }
}
