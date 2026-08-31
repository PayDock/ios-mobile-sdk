//
//  CardDetailsAccessibilityTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
import SwiftUI
@testable import MobileSDK
@testable import DataPaymentSources

/// Covers the pure accessibility helpers extracted from `CardDetailsWidget` so the VoiceOver /
/// Dynamic-Type logic is unit-tested rather than only manually verified.
@MainActor
final class CardDetailsAccessibilityTests: XCTestCase {

    private func makeVM() -> CardDetailsVM {
        CardDetailsVM(
            paymentSourcesService: PaymentSourcesMockService(),
            viewState: ViewState(),
            config: CardDetailsWidgetConfig(accessToken: "token"),
            appearance: CardDetailsWidgetAppearance(),
            loadingDelegate: nil,
            eventDelegate: nil) { _ in }
    }

    // MARK: - shouldAlignVertically(for:)

    func testShouldAlignVertically_StandardSizes_LayOutHorizontally() {
        let vm = makeVM()
        let standard: [DynamicTypeSize] = [.xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge]
        for size in standard {
            XCTAssertFalse(vm.shouldAlignVertically(for: size), "\(size) should be horizontal")
        }
    }

    func testShouldAlignVertically_AccessibilitySizes_StackVertically() {
        let vm = makeVM()
        let ax: [DynamicTypeSize] = [.accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5]
        for size in ax {
            XCTAssertTrue(vm.shouldAlignVertically(for: size), "\(size) should stack vertically")
        }
    }

    // MARK: - errorCountAnnouncement(_:)

    func testErrorCountAnnouncement() {
        let vm = makeVM()
        XCTAssertNil(vm.errorCountAnnouncement(0), "no announcement for zero errors")
        XCTAssertNil(vm.errorCountAnnouncement(-1), "no announcement for negative counts")
        XCTAssertEqual(vm.errorCountAnnouncement(1), "There is 1 error in form")
        XCTAssertEqual(vm.errorCountAnnouncement(3), "There are 3 errors in form")
    }

    // MARK: - supportedSchemesAccessibilityLabel(for:)

    func testSupportedSchemesAccessibilityLabel_OrderedByPreferredOrder() {
        let vm = makeVM()
        let schemes: Set<CardScheme> = [.amex, .visa, .mastercard]
        XCTAssertEqual(
            vm.supportedSchemesAccessibilityLabel(for: schemes),
            "Supported card schemes: Visa, Mastercard, American Express")
    }

    // MARK: - CardScheme.sortedArray(from:)

    func testCardSchemeSortedArray_FollowsPreferredOrder() {
        let sorted = CardScheme.sortedArray(from: Set(CardScheme.allCases))
        XCTAssertEqual(sorted, [.visa, .mastercard, .amex, .diners, .discover, .japcb, .unionpay])
    }
}
