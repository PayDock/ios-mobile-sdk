//
//  GzipTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Compression
import Foundation
import PaydockTelemetry
import XCTest

/// R_02: RFC 1952 gzip from Apple's Compression framework, which standard tools decompress.
final class GzipTests: XCTestCase {

    private static let header: [UInt8] = [0x1F, 0x8B, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF]
    private static let fixedInput = Data(#"{"resourceLogs":[{"scopeLogs":[{"scope":{"name":"paydock.telemetry"}}]}]}"#.utf8)

    func testCrc32_OfTheCheckString_IsCBF43926() {
        XCTAssertEqual(Crc32.checksum(Data("123456789".utf8)), 0xCBF4_3926)
        XCTAssertEqual(Crc32.checksum(Data()), 0)
    }

    func testOutput_StartsWithTheGzipHeader() throws {
        let output = try XCTUnwrap(Gzip.compress(Self.fixedInput))

        XCTAssertEqual(Array(output.prefix(3)), [0x1F, 0x8B, 0x08])
        XCTAssertEqual(Array(output.prefix(10)), Self.header)
    }

    func testTrailer_IsTheCrcThenTheSize_LittleEndian() throws {
        let output = try XCTUnwrap(Gzip.compress(Self.fixedInput))
        let trailer = Array(output.suffix(8))

        XCTAssertEqual(littleEndian(trailer[0..<4]), Crc32.checksum(Self.fixedInput))
        XCTAssertEqual(littleEndian(trailer[4..<8]), UInt32(Self.fixedInput.count))
    }

    func testFixedInput_RoundTrips() throws {
        let output = try XCTUnwrap(Gzip.compress(Self.fixedInput))

        XCTAssertEqual(try inflate(output), Self.fixedInput)
    }

    func testEmptyInput_GivesAValidGzip() throws {
        let output = try XCTUnwrap(Gzip.compress(Data()))

        XCTAssertEqual(Array(output.prefix(10)), Self.header)
        XCTAssertEqual(Array(output.suffix(8)), [0, 0, 0, 0, 0, 0, 0, 0])
        XCTAssertEqual(try inflate(output), Data())
    }

    func testA256KBInput_RoundTrips() throws {
        let input = Self.largeInput()
        let output = try XCTUnwrap(Gzip.compress(input))

        XCTAssertLessThan(output.count, input.count)
        XCTAssertEqual(littleEndian(Array(output.suffix(4))[0..<4]), UInt32(input.count))
        XCTAssertEqual(try inflate(output), input)
    }

    #if os(macOS)
    func testFixedInput_DecompressesWithTheSystemGzip() throws {
        let output = try XCTUnwrap(Gzip.compress(Self.fixedInput))

        XCTAssertEqual(try systemGunzip(output), Self.fixedInput)
    }

    func testEmptyInput_DecompressesWithTheSystemGzip() throws {
        let output = try XCTUnwrap(Gzip.compress(Data()))

        XCTAssertEqual(try systemGunzip(output), Data())
    }

    func testA256KBInput_DecompressesWithTheSystemGzip() throws {
        let input = Self.largeInput()
        let output = try XCTUnwrap(Gzip.compress(input))

        XCTAssertEqual(try systemGunzip(output), input)
    }
    #endif

    // MARK: - Helpers

    /// 256 KB of JSON-like text that is not a single repeated byte.
    private static func largeInput() -> Data {
        var text = ""
        var index = 0
        while text.utf8.count < 262_144 {
            text += #"{"key":"value-\#(index)","n":\#(index * 7919 % 104_729)},"#
            index += 1
        }
        return Data(text.utf8.prefix(262_144))
    }

    private func littleEndian(_ bytes: ArraySlice<UInt8>) -> UInt32 {
        bytes.enumerated().reduce(UInt32(0)) { value, element in value | UInt32(element.element) << (8 * element.offset) }
    }

    /// Strips the 10-byte header and the 8-byte trailer and inflates the raw DEFLATE with the Compression framework.
    private func inflate(_ gzip: Data) throws -> Data {
        let deflated = Data(gzip.dropFirst(10).dropLast(8))
        let capacity = 1_048_576
        var output = [UInt8](repeating: 0, count: capacity)
        let written = deflated.withUnsafeBytes { input -> Int in
            guard let source = input.bindMemory(to: UInt8.self).baseAddress else {
                return 0
            }
            return compression_decode_buffer(&output, capacity, source, deflated.count, nil, COMPRESSION_ZLIB)
        }
        return Data(output.prefix(written))
    }

    #if os(macOS)
    /// `/usr/bin/gzip -dc` on a temporary file, its output to another; fails rather than hangs after 20 s.
    private func systemGunzip(_ gzip: Data) throws -> Data {
        let temporary = try TemporaryDirectory()
        defer { temporary.remove() }
        let input = temporary.url.appendingPathComponent("payload.gz")
        let output = temporary.url.appendingPathComponent("payload.out")
        try gzip.write(to: input)
        XCTAssertTrue(FileManager.default.createFile(atPath: output.path, contents: nil))
        let outputHandle = try FileHandle(forWritingTo: output)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/gzip")
        process.arguments = ["-dc", input.path]
        process.standardOutput = outputHandle
        let finished = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in finished.signal() }
        try process.run()
        if finished.wait(timeout: .now() + 20) == .timedOut {
            process.terminate()
            XCTFail("gzip -dc did not finish within 20 s")
        }
        try outputHandle.close()
        XCTAssertEqual(process.terminationStatus, 0)
        return try Data(contentsOf: output)
    }
    #endif
}
