//
//  FramePointsTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_01: one build's SDK ranges from the type points of its image (spec § 7.2).
final class FramePointsTests: XCTestCase {

    private static let imageName = "ExampleApp"
    private static let uuid = "C95ED3C1-F639-3822-BC5C-B2D03AFDD182"

    func testRunsOfConsecutivePaydockPoints_BecomeRanges() throws {
        let points = [
            TypePoint(offset: 0x100, module: "ExampleApp"),
            TypePoint(offset: 0x200, module: "MobileSDK"),
            TypePoint(offset: 0x280, module: "DataCharges"),
            TypePoint(offset: 0x300, module: "PaydockTelemetry"),
            TypePoint(offset: 0x400, module: "SwiftUI"),
            TypePoint(offset: 0x500, module: "NetworkingLib"),
            TypePoint(offset: 0x580, module: "CommonModels"),
            TypePoint(offset: 0x600, module: "ExampleApp")
        ]

        let build = try XCTUnwrap(FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: points))

        XCTAssertEqual(build.sdkRanges, [0x200...0x300, 0x500...0x580])
        XCTAssertEqual(build.imageName, Self.imageName)
        XCTAssertEqual(build.uuid, Self.uuid)
    }

    func testPointsAreSortedByOffset_BeforeTheRunsAreBuilt() throws {
        let points = [
            TypePoint(offset: 0x300, module: "MobileSDK"),
            TypePoint(offset: 0x100, module: "ExampleApp"),
            TypePoint(offset: 0x200, module: "BinProcessing"),
            TypePoint(offset: 0x400, module: "ExampleApp")
        ]

        let build = try XCTUnwrap(FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: points))

        XCTAssertEqual(build.sdkRanges, [0x200...0x300])
    }

    func testALonePaydockPoint_IsAOneOffsetRange() throws {
        let points = [
            TypePoint(offset: 0x100, module: "ExampleApp"),
            TypePoint(offset: 0x200, module: "DataVault"),
            TypePoint(offset: 0x300, module: "ExampleApp")
        ]

        let build = try XCTUnwrap(FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: points))

        XCTAssertEqual(build.sdkRanges, [0x200...0x200])
        XCTAssertTrue(build.contains(0x200))
        XCTAssertFalse(build.contains(0x201))
    }

    func testForeignPoints_SplitRuns() throws {
        let points = [
            TypePoint(offset: 0x100, module: "MobileSDK"),
            TypePoint(offset: 0x200, module: "ExampleApp"),
            TypePoint(offset: 0x300, module: "MobileSDK"),
            TypePoint(offset: 0x400, module: "Afterpay"),
            TypePoint(offset: 0x500, module: "MobileSDK")
        ]

        let build = try XCTUnwrap(FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: points))

        XCTAssertEqual(build.sdkRanges, [0x100...0x100, 0x300...0x300, 0x500...0x500])
    }

    func testTies_SortPaydockFirst() throws {
        let points = [
            TypePoint(offset: 0x100, module: "MobileSDK"),
            TypePoint(offset: 0x200, module: "ExampleApp"),
            TypePoint(offset: 0x200, module: "MobileSDK"),
            TypePoint(offset: 0x300, module: "MobileSDK")
        ]

        let build = try XCTUnwrap(FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: points))

        XCTAssertEqual(build.sdkRanges, [0x100...0x200, 0x300...0x300])
    }

    func testNoPaydockPoint_GivesNil() {
        let points = [TypePoint(offset: 0x100, module: "ExampleApp"), TypePoint(offset: 0x200, module: "SwiftUI")]

        XCTAssertNil(FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: points))
        XCTAssertNil(FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: []))
    }

    func testEverySdkModule_IsPaydock() {
        for module in FramePoints.sdkModules {
            let build = FramePoints(imageName: Self.imageName, uuid: Self.uuid, points: [TypePoint(offset: 1, module: module)])
            XCTAssertEqual(build?.sdkRanges, [1...1], module)
        }
        XCTAssertEqual(FramePoints.sdkModules.count, 12)
    }

    func testContains_AtBothEnds_AndOutside() {
        let build = FramePoints(imageName: Self.imageName, uuid: Self.uuid, sdkRanges: [0x200...0x300, 0x500...0x580])

        XCTAssertTrue(build.contains(0x200))
        XCTAssertTrue(build.contains(0x250))
        XCTAssertTrue(build.contains(0x300))
        XCTAssertTrue(build.contains(0x500))
        XCTAssertTrue(build.contains(0x580))
        XCTAssertFalse(build.contains(0x1ff))
        XCTAssertFalse(build.contains(0x301))
        XCTAssertFalse(build.contains(0x400))
        XCTAssertFalse(build.contains(0x581))
        XCTAssertFalse(build.contains(0))
        XCTAssertFalse(FramePoints(imageName: Self.imageName, uuid: Self.uuid, sdkRanges: []).contains(0x200))
    }

    func testCodable_RoundTrips() throws {
        let build = FramePoints(imageName: Self.imageName, uuid: Self.uuid, sdkRanges: [0x200...0x300, 0x500...0x500])

        let decoded = try JSONDecoder().decode(FramePoints.self, from: JSONEncoder().encode(build))

        XCTAssertEqual(decoded, build)
        XCTAssertEqual(try JSONDecoder().decode([FramePoints].self, from: JSONEncoder().encode([build, build])), [build, build])
    }
}
