//
//  DyldSdkImageReaderTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import MachO
import PaydockTelemetry
import XCTest

/// R_01: the dyld reader on the test bundle's own image, which links the telemetry target statically.
final class DyldSdkImageReaderTests: XCTestCase {

    func testReadsANonEmptyUUID_AndPoints() throws {
        let read = try XCTUnwrap(DyldSdkImageReader().read())

        XCTAssertFalse(read.image.name.isEmpty)
        XCTAssertFalse(read.image.name.contains("/"))
        XCTAssertNotNil(UUID(uuidString: read.image.uuid), read.image.uuid)
        XCTAssertEqual(read.image.uuid, read.image.uuid.uppercased())
        XCTAssertNotEqual(read.image.loadAddress, 0)
        XCTAssertFalse(read.points.isEmpty)
    }

    func testAtLeastOnePoint_IsInModulePaydockTelemetry() throws {
        let read = try XCTUnwrap(DyldSdkImageReader().read())

        XCTAssertTrue(read.points.contains { $0.module == "PaydockTelemetry" }, "\(Set(read.points.map(\.module)))")
    }

    func testTheImage_HoldsThisTargetsCode() throws {
        let read = try XCTUnwrap(DyldSdkImageReader().read())
        let own = UInt(bitPattern: UnsafeRawPointer(#dsohandle))

        XCTAssertEqual(read.image.loadAddress, own, "the telemetry target is linked into the test bundle's image")
    }

    func testEveryOffset_IsInsideText() throws {
        let read = try XCTUnwrap(DyldSdkImageReader().read())
        let header = try XCTUnwrap(UnsafeRawPointer(bitPattern: read.image.loadAddress))
        var size: UInt = 0
        let text = try XCTUnwrap(getsectiondata(header.assumingMemoryBound(to: mach_header_64.self), "__TEXT", "__text", &size))
        let start = UInt64(UInt(bitPattern: text) - read.image.loadAddress)

        for point in read.points {
            XCTAssertTrue(point.offset >= start && point.offset < start + UInt64(size), "\(point)")
        }
    }

    func testNoPoint_IsInModuleC() throws {
        let read = try XCTUnwrap(DyldSdkImageReader().read())

        XCTAssertFalse(read.points.contains { $0.module == "__C" || $0.module == "__C_Synthesized" })
    }

    func testThePoints_GiveFramePoints() throws {
        let read = try XCTUnwrap(DyldSdkImageReader().read())

        let build = try XCTUnwrap(FramePoints(imageName: read.image.name, uuid: read.image.uuid, points: read.points))

        XCTAssertFalse(build.sdkRanges.isEmpty)
    }

    func testDladdr_ResolvesThisCallStack_IntoTheSameImage() throws {
        let read = try XCTUnwrap(DyldSdkImageReader().read())
        let resolver = DladdrAddressResolver()
        let own = Thread.callStackReturnAddresses.map(\.uintValue).compactMap { address in
            resolver.resolve(address).map { (address: address, resolved: $0) }
        }.filter { $0.resolved.imageLoadAddress == read.image.loadAddress }

        let first = try XCTUnwrap(own.first)
        XCTAssertEqual((first.resolved.imagePath as NSString).lastPathComponent, read.image.name)
        XCTAssertEqual(StackFrame.describe(first.address, first.resolved),
                       "\(read.image.name) 0x\(String(first.address - read.image.loadAddress, radix: 16))")
        XCTAssertNil(resolver.resolve(0))
    }
}
#endif
