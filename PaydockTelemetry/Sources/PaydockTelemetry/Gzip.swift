//
//  Gzip.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Compression
import Foundation

/// RFC 1952 gzip with Apple's Compression framework, no dependency (R_02): the header `1f 8b 08 00 00 00 00 00 00 ff`,
/// raw DEFLATE from `compression_stream` (`COMPRESSION_STREAM_ENCODE`, `COMPRESSION_ZLIB`), then the trailer: the
/// CRC32 and the input size mod 2^32, both little-endian.
package enum Gzip {
    private static let header: [UInt8] = [0x1F, 0x8B, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF]
    private static let bufferSize = 65_536

    /// Nil when compression fails.
    package static func compress(_ data: Data) -> Data? {
        guard let deflated = deflate(data) else {
            return nil
        }
        var output = Data(header)
        output.append(deflated)
        appendLittleEndian(Crc32.checksum(data), to: &output)
        appendLittleEndian(UInt32(truncatingIfNeeded: data.count), to: &output)
        return output
    }

    private static func deflate(_ data: Data) -> Data? {
        let stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer { stream.deallocate() }
        guard compression_stream_init(stream, COMPRESSION_STREAM_ENCODE, COMPRESSION_ZLIB) == COMPRESSION_STATUS_OK else {
            return nil
        }
        defer { compression_stream_destroy(stream) }
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        return data.withUnsafeBytes { (input: UnsafeRawBufferPointer) -> Data? in
            stream.pointee.src_ptr = input.bindMemory(to: UInt8.self).baseAddress ?? UnsafePointer(buffer)
            stream.pointee.src_size = input.count
            var output = Data()
            while true {
                stream.pointee.dst_ptr = buffer
                stream.pointee.dst_size = bufferSize
                let status = compression_stream_process(stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
                guard status == COMPRESSION_STATUS_OK || status == COMPRESSION_STATUS_END else {
                    return nil
                }
                output.append(buffer, count: bufferSize - stream.pointee.dst_size)
                if status == COMPRESSION_STATUS_END {
                    return output
                }
            }
        }
    }

    private static func appendLittleEndian(_ value: UInt32, to data: inout Data) {
        data.append(contentsOf: [0, 8, 16, 24].map { UInt8(truncatingIfNeeded: value >> $0) })
    }
}
