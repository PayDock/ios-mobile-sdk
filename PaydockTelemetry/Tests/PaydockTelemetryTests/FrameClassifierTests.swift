//
//  FrameClassifierTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

/// R_02, R_16: frames classified by the saved ranges of the last builds, never by symbols (spec § 7.2).
final class FrameClassifierTests: XCTestCase {

    private static let current = FramePoints(imageName: "ExampleApp", uuid: "C95ED3C1-F639-3822-BC5C-B2D03AFDD182",
                                             sdkRanges: [0x1b4000...0x1b6000])
    private static let previous = FramePoints(imageName: "ExampleApp", uuid: "0A1B2C3D-4E5F-6071-8293-A4B5C6D7E8F9",
                                              sdkRanges: [0x1a0000...0x1a2000])
    private let classifier = FrameClassifier(builds: [current, previous])

    // MARK: - classify

    func testAKnownUUID_ClassifiesByItsRanges() {
        XCTAssertEqual(classifier.classify(frame(Self.current.uuid, 0x1b5058)), .sdk)
        XCTAssertEqual(classifier.classify(frame(Self.current.uuid, 0x1b4000)), .sdk)
        XCTAssertEqual(classifier.classify(frame(Self.current.uuid, 0x1b6000)), .sdk)
        XCTAssertEqual(classifier.classify(frame(Self.current.uuid, 0x1a1000)), .notSdk)
        XCTAssertEqual(classifier.classify(frame(Self.previous.uuid, 0x1a1000)), .sdk)
        XCTAssertEqual(classifier.classify(frame(Self.previous.uuid, 0x1b5058)), .notSdk)
    }

    func testTheSdkImagesName_WithAnUnsavedUUID_IsUnknown() {
        XCTAssertEqual(classifier.classify(frame("FFFFFFFF-0000-0000-0000-000000000000", 0x1b5058)), .unknown)
        XCTAssertEqual(classifier.classify(FrameAddress(imageName: "ExampleApp", uuid: nil, offset: 0x1b5058)), .unknown)
    }

    func testAnotherImage_IsNotSdk() {
        XCTAssertEqual(classifier.classify(FrameAddress(imageName: "UIKitCore", uuid: nil, offset: 0x1b5058)), .notSdk)
        XCTAssertEqual(classifier.classify(FrameAddress(imageName: "UIKitCore", uuid: "11111111-2222-3333-4444-555555555555",
                                                        offset: 0x58f740)), .notSdk)
    }

    func testNoBuilds_ClassifiesEveryFrameNotSdk() {
        XCTAssertEqual(FrameClassifier(builds: []).classify(frame(Self.current.uuid, 0x1b5058)), .notSdk)
    }

    // MARK: - inSdk

    func testInSdk_TrueWithAnySdkFrame() {
        let frames = [other(), frame("FFFFFFFF-0000-0000-0000-000000000000", 1), frame(Self.current.uuid, 0x1b5058)]

        XCTAssertEqual(classifier.inSdk(frames), true)
    }

    func testInSdk_NilWithAnUnknownAndNoSdk() {
        XCTAssertNil(classifier.inSdk([other(), frame("FFFFFFFF-0000-0000-0000-000000000000", 0x1b5058)]))
    }

    func testInSdk_NilForNoFrames() {
        XCTAssertNil(classifier.inSdk([]))
    }

    func testInSdk_FalseOtherwise() {
        XCTAssertEqual(classifier.inSdk([other(), frame(Self.current.uuid, 0x10)]), false)
    }

    // MARK: - merging

    func testMerging_KeepsTheCurrentFirst() {
        let merged = FrameClassifier.merging(current: Self.current, saved: [Self.previous])

        XCTAssertEqual(merged, [Self.current, Self.previous])
    }

    func testMerging_DropsARepeatUUID() {
        let stale = FramePoints(imageName: "ExampleApp", uuid: Self.current.uuid, sdkRanges: [0x10...0x20])

        let merged = FrameClassifier.merging(current: Self.current, saved: [stale, Self.previous])

        XCTAssertEqual(merged, [Self.current, Self.previous])
    }

    func testMerging_KeepsAtMostThree() {
        let saved = (1...4).map { index in
            FramePoints(imageName: "ExampleApp", uuid: "0000000\(index)-0000-0000-0000-000000000000", sdkRanges: [1...2])
        }

        let merged = FrameClassifier.merging(current: Self.current, saved: saved)

        XCTAssertEqual(TelemetryLimits.frameBuildsKept, 3)
        XCTAssertEqual(merged, [Self.current, saved[0], saved[1]])
    }

    func testMerging_WithNothingSaved_GivesTheCurrent() {
        XCTAssertEqual(FrameClassifier.merging(current: Self.current, saved: []), [Self.current])
    }

    // MARK: - Helpers

    private func frame(_ uuid: String, _ offset: UInt64) -> FrameAddress {
        FrameAddress(imageName: "ExampleApp", uuid: uuid, offset: offset)
    }

    private func other() -> FrameAddress {
        FrameAddress(imageName: "CoreFoundation", uuid: nil, offset: 0x2a4)
    }
}
