//
//  ApplePayVMPresentationHookTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.
//
//  Tap → `onShouldPresentPaymentSheet` → present, driven through a fake presenter.

import XCTest
import PassKit
@testable import MobileSDK
@testable import DataPaymentSources

// MARK: - Fakes

final class FakePaymentAuthorizationPresenter: PaymentAuthorizationPresenting {
    var delegate: PKPaymentAuthorizationControllerDelegate?
    var presentResult = true
    private(set) var presentCallCount = 0

    func present(completion: @escaping (Bool) -> Void) {
        presentCallCount += 1
        completion(presentResult)
    }
}

final class FakePaymentAuthorizationPresenterFactory: PaymentAuthorizationPresenterFactory {
    let presenter = FakePaymentAuthorizationPresenter()
    private(set) var makeCallCount = 0

    func makePresenter(for request: PKPaymentRequest) -> PaymentAuthorizationPresenting {
        makeCallCount += 1
        return presenter
    }
}

// MARK: - Tests

@MainActor
final class ApplePayVMPresentationHookTests: XCTestCase {

    private var factory: FakePaymentAuthorizationPresenterFactory!
    private var eventDelegate: WidgetEventDelegateUtil!
    private var completionResults: [Result<ApplePayResult, ApplePayError>] = []

    override func setUp() {
        super.setUp()
        factory = FakePaymentAuthorizationPresenterFactory()
        eventDelegate = WidgetEventDelegateUtil()
        completionResults = []
    }

    override func tearDown() {
        factory = nil
        eventDelegate = nil
        completionResults = []
        super.tearDown()
    }

    private func makeViewModel(hook: ApplePayPresentationDecision?) -> ApplePayVM {
        ApplePayVM(
            config: ApplePayWidgetConfig(
                serviceId: "test-service-id",
                accessToken: "test-widget-token",
                pkPaymentRequest: PKPaymentRequest()
            ),
            eventDelegate: eventDelegate,
            paymentSourcesService: PaymentSourcesMockService(),
            presenterFactory: factory,
            onShouldPresentPaymentSheet: hook,
            completion: { [weak self] result in
                self?.completionResults.append(result)
            })
    }

    /// Polls until `condition` holds; the hook runs in a `Task` that needs a chance to be scheduled.
    private func waitUntil(timeout: TimeInterval = 2.0,
                           _ condition: @escaping () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    // `Thread.isMainThread` warns when read from an async context.
    private nonisolated func isOnMainThread() -> Bool {
        Thread.isMainThread
    }

    // MARK: No hook (backward compatibility)

    func testTap_WithoutHook_PresentsImmediately() {
        let viewModel = makeViewModel(hook: nil)

        viewModel.handleButtonTap()

        XCTAssertEqual(factory.makeCallCount, 1)
        XCTAssertEqual(factory.presenter.presentCallCount, 1)
        XCTAssertTrue(viewModel.isProcessing, "button is disabled while the sheet is up")
        XCTAssertTrue(completionResults.isEmpty)
    }

    func testTap_WithoutHook_WhileSheetPresented_IsIgnored() {
        let viewModel = makeViewModel(hook: nil)

        viewModel.handleButtonTap()
        viewModel.handleButtonTap()
        viewModel.handleButtonTap()

        XCTAssertEqual(factory.makeCallCount, 1, "a second sheet must never be presented")
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1, "ignored taps emit no analytics")
    }

    func testFinishAndComplete_ReenablesButton() {
        let viewModel = makeViewModel(hook: nil)
        viewModel.handleButtonTap()
        XCTAssertTrue(viewModel.isProcessing)

        viewModel.finishAndComplete()

        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertEqual(completionResults.count, 1)
    }

    func testPresentFailure_ReenablesButton() async {
        factory.presenter.presentResult = false
        let viewModel = makeViewModel(hook: nil)

        viewModel.handleButtonTap()
        await waitUntil { viewModel.isProcessing == false }

        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertEqual(completionResults.count, 1)
        if case .failure(.unableToPresentPaymentSheet) = completionResults.first {
            // expected
        } else {
            XCTFail("Expected unableToPresentPaymentSheet, got \(String(describing: completionResults.first))")
        }
    }

    // MARK: Hook returns true

    func testTap_HookReturnsTrue_PresentsAfterDecision() async {
        var hookCallCount = 0
        let viewModel = makeViewModel(hook: {
            hookCallCount += 1
            return true
        })

        viewModel.handleButtonTap()
        XCTAssertEqual(factory.makeCallCount, 0, "sheet must not be presented before the decision")
        await waitUntil { self.factory.makeCallCount == 1 }

        XCTAssertEqual(hookCallCount, 1)
        XCTAssertEqual(factory.makeCallCount, 1)
        XCTAssertEqual(factory.presenter.presentCallCount, 1)
        XCTAssertTrue(viewModel.isProcessing)
        XCTAssertTrue(completionResults.isEmpty)
    }

    func testTap_HookRunsOnMainThread() async {
        var wasOnMainThread = false
        let viewModel = makeViewModel(hook: {
            wasOnMainThread = self.isOnMainThread()
            return true
        })

        viewModel.handleButtonTap()
        await waitUntil { self.factory.makeCallCount == 1 }

        XCTAssertTrue(wasOnMainThread)
    }

    // MARK: Hook returns false (silent decline)

    func testTap_HookReturnsFalse_DoesNotPresentOrComplete() async {
        let viewModel = makeViewModel(hook: { false })

        viewModel.handleButtonTap()
        XCTAssertTrue(viewModel.isProcessing, "button is disabled while the decision is pending")
        await waitUntil { viewModel.isProcessing == false }

        XCTAssertEqual(factory.makeCallCount, 0)
        XCTAssertEqual(factory.presenter.presentCallCount, 0)
        XCTAssertTrue(completionResults.isEmpty, "a decline must not call completion")
        XCTAssertNil(viewModel.error, "a decline must not produce a synthetic error")
        XCTAssertFalse(viewModel.isProcessing)
    }

    func testTap_AfterDecline_NextTapRunsHookAgain() async {
        var decisions = [false, true]
        var hookCallCount = 0
        let viewModel = makeViewModel(hook: {
            hookCallCount += 1
            return decisions.removeFirst()
        })

        viewModel.handleButtonTap()
        await waitUntil { viewModel.isProcessing == false }
        XCTAssertEqual(factory.makeCallCount, 0)

        viewModel.handleButtonTap()
        await waitUntil { self.factory.makeCallCount == 1 }

        XCTAssertEqual(hookCallCount, 2)
        XCTAssertEqual(factory.makeCallCount, 1)
    }

    // MARK: Single invocation while pending

    func testTap_WhileDecisionPending_IgnoresRepeatedTaps() async {
        var pendingDecision: CheckedContinuation<Bool, Never>?
        var hookCallCount = 0
        let viewModel = makeViewModel(hook: {
            hookCallCount += 1
            return await withCheckedContinuation { continuation in
                pendingDecision = continuation
            }
        })

        viewModel.handleButtonTap()
        await waitUntil { pendingDecision != nil }
        viewModel.handleButtonTap()
        viewModel.handleButtonTap()

        XCTAssertEqual(hookCallCount, 1, "validation must not run in parallel")
        XCTAssertEqual(factory.makeCallCount, 0)
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)

        pendingDecision?.resume(returning: true)
        await waitUntil { self.factory.makeCallCount == 1 }

        XCTAssertEqual(factory.makeCallCount, 1, "exactly one sheet after the decision")
        XCTAssertEqual(factory.presenter.presentCallCount, 1)
    }

    func testTap_HookHasNoTimeout_PresentsWheneverDecisionArrives() async {
        var pendingDecision: CheckedContinuation<Bool, Never>?
        let viewModel = makeViewModel(hook: {
            await withCheckedContinuation { continuation in
                pendingDecision = continuation
            }
        })

        viewModel.handleButtonTap()
        await waitUntil { pendingDecision != nil }
        // Hold the decision well past any plausible internal timeout.
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(factory.makeCallCount, 0)
        XCTAssertTrue(viewModel.isProcessing)

        pendingDecision?.resume(returning: true)
        await waitUntil { self.factory.makeCallCount == 1 }

        XCTAssertEqual(factory.makeCallCount, 1)
    }
}
