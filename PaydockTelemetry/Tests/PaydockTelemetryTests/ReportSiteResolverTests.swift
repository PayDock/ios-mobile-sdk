//
//  ReportSiteResolverTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_03: a fixed resolver, image and classifier stand in for the loader and the saved ranges.
final class ReportSiteResolverTests: XCTestCase {

    private static let uuid = "C95ED3C1-F639-3822-BC5C-B2D03AFDD182"
    private static let appBase: UInt = 0x1_0000_0000
    private static let foundationBase: UInt = 0x1_8000_0000
    private static let otherBase: UInt = 0x1_9000_0000
    private static let symbolAddress: UInt = foundationBase + 0x5000
    /// Inside the SDK's saved range of the app image.
    private static let sdkAddress: UInt = appBase + 0x1b5058
    /// The app's own code, outside the SDK's range.
    private static let appAddress: UInt = appBase + 0x225100
    private static let image = SdkImage(name: "ExampleApp", uuid: uuid, loadAddress: appBase)
    private static let classifier = FrameClassifier(builds: [
        FramePoints(imageName: "ExampleApp", uuid: uuid, sdkRanges: [0x1b4000...0x1b6000])
    ])
    private static let resolver = FixedAddressResolver([
        .init(path: "/private/var/containers/Bundle/Application/X/ExampleApp.app/ExampleApp", loadAddress: appBase),
        .init(path: "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", loadAddress: foundationBase,
              symbols: [symbolAddress: "__exceptionPreprocess"]),
        .init(path: "/private/var/containers/Bundle/Application/X/ExampleApp.app/Frameworks/Other.framework/Other",
              loadAddress: otherBase)
    ])

    private let cause = TelemetryEvent.ErrorInfo(type: "NSError NSURLErrorDomain -1001", frames: [])

    func testSdkAddresses_GiveOffsetFrames_AndInSdkTrue() {
        let site = ReportSite(returnAddresses: [Self.sdkAddress, Self.appAddress], threadName: "main")

        let event = resolve(.sdkError(error: info(), errorCode: "SAMPLE_CODE", widget: "CardDetailsWidget"), site)

        XCTAssertEqual(event, .sdkError(
            error: TelemetryEvent.ErrorInfo(type: "MobileSDK.SampleError",
                                            frames: ["ExampleApp 0x1b5058", "ExampleApp 0x225100"], cause: cause),
            errorCode: "SAMPLE_CODE", widget: "CardDetailsWidget", inSdk: true
        ))
    }

    func testForeignAddresses_GiveInSdkFalse() {
        let site = ReportSite(returnAddresses: [Self.appAddress, Self.otherBase + 0x40], threadName: nil)

        let event = resolve(.sdkError(error: info()), site)

        XCTAssertEqual(inSdk(event), false)
        XCTAssertEqual(frames(event), ["ExampleApp 0x225100", "Other 0x40"])
    }

    func testNoClassifier_GivesInSdkNil() {
        let site = ReportSite(returnAddresses: [Self.sdkAddress], threadName: nil)

        let sdkError = resolve(.sdkError(error: info()), site, classifier: nil)
        let uncaught = resolve(.uncaughtException(error: info()), site, classifier: nil)

        XCTAssertEqual(inSdk(sdkError), .some(nil))
        XCTAssertEqual(inSdk(uncaught), .some(nil))
        XCTAssertEqual(frames(sdkError), ["ExampleApp 0x1b5058"], "frames are still described")
    }

    func testASystemSymbol_IsKept() {
        let site = ReportSite(returnAddresses: [Self.symbolAddress + 164], threadName: nil)

        XCTAssertEqual(frames(resolve(.sdkError(error: info()), site)), ["CoreFoundation __exceptionPreprocess + 164"])
    }

    func testAnUnresolvedAddress_GivesQuestionMarksAndTheAddress() {
        let site = ReportSite(returnAddresses: [0x42_0000, Self.sdkAddress], threadName: nil)

        let event = resolve(.sdkError(error: info()), site)

        XCTAssertEqual(frames(event), ["??? 0x420000", "ExampleApp 0x1b5058"])
        XCTAssertEqual(inSdk(event), true, "an unresolved address is not classified")
    }

    func testTheTypeAndCause_AreKept_AndTheEventsOwnFramesReplaced() {
        let original = TelemetryEvent.ErrorInfo(type: "MobileSDK.SampleError", frames: ["Stale 0x1"], cause: cause)
        let site = ReportSite(returnAddresses: [Self.sdkAddress], threadName: nil)

        guard case let .sdkError(error, _, _, _, _) = resolve(.sdkError(error: original), site) else {
            return XCTFail("not an SDK error")
        }

        XCTAssertEqual(error.type, "MobileSDK.SampleError")
        XCTAssertEqual(error.cause, cause)
        XCTAssertEqual(error.frames, ["ExampleApp 0x1b5058"])
    }

    func testUncaught_TakesTheSitesThreadName_WhenItHasNone() {
        let site = ReportSite(returnAddresses: [Self.sdkAddress], threadName: "main")

        let unnamed = resolve(.uncaughtException(error: info(), widget: "ZipWidget"), site)
        let named = resolve(.uncaughtException(error: info(), threadName: "worker"), site)

        XCTAssertEqual(unnamed, .uncaughtException(
            error: TelemetryEvent.ErrorInfo(type: "MobileSDK.SampleError", frames: ["ExampleApp 0x1b5058"], cause: cause),
            threadName: "main", widget: "ZipWidget", inSdk: true
        ))
        guard case let .uncaughtException(_, threadName, _, _) = named else {
            return XCTFail("not an uncaught error")
        }
        XCTAssertEqual(threadName, "worker")
    }

    func testOtherEvents_ComeBackUnchanged() {
        let site = ReportSite(returnAddresses: [Self.sdkAddress], threadName: "main")
        let events: [TelemetryEvent] = [
            TelemetryFixtures.crash(),
            TelemetryFixtures.networkFailure(),
            .widgetOpened(widget: "CardDetailsWidget"),
            .dropped(reason: .rateLimit, count: 2)
        ]

        for event in events {
            XCTAssertEqual(resolve(event, site), event)
        }
    }

    func testAtMost64Frames() {
        let site = ReportSite(returnAddresses: Array(repeating: Self.sdkAddress, count: 80), threadName: nil)

        XCTAssertEqual(frames(resolve(.sdkError(error: info()), site))?.count, 64)
    }

    // MARK: - Helpers

    private func info() -> TelemetryEvent.ErrorInfo {
        TelemetryEvent.ErrorInfo(type: "MobileSDK.SampleError", frames: [], cause: cause)
    }

    private func resolve(_ event: TelemetryEvent, _ site: ReportSite,
                         classifier: FrameClassifier? = ReportSiteResolverTests.classifier) -> TelemetryEvent {
        ReportSiteResolver.resolve(event, site: site, resolver: Self.resolver, image: Self.image, classifier: classifier)
    }

    /// `.some(inSdk)` of an SDK or uncaught error, nil for any other event.
    private func inSdk(_ event: TelemetryEvent) -> Bool?? {
        switch event {
        case let .sdkError(_, _, _, _, inSdk), let .uncaughtException(_, _, _, inSdk):
            return .some(inSdk)
        default:
            return nil
        }
    }

    private func frames(_ event: TelemetryEvent) -> [String]? {
        switch event {
        case let .sdkError(error, _, _, _, _), let .uncaughtException(error, _, _, _):
            return error.frames
        default:
            return nil
        }
    }
}
