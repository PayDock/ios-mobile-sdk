//
//  Standalone3DSAuthenticationFlowTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

/// `Standalone3DSResult.authenticationFlow`: set on `chargeAuthSuccess` / `chargeAuthReject` from the challenge or
/// decoupled event seen for the same charge 3DS id (frictionless otherwise), `nil` on every other event.
@MainActor
final class Standalone3DSAuthenticationFlowTests: XCTestCase {
    typealias Recorder = Standalone3DSTests.Recorder

    // MARK: - Frictionless (R_02)

    func testFrictionless_successAlone() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "chargeId"])

        XCTAssertEqual(finalResults(recorder).map(\.event), [.chargeAuthSuccess])
        XCTAssertEqual(finalResults(recorder).map(\.authenticationFlow), [.frictionless])
    }

    func testFrictionless_rejectAlone() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthReject", "charge3dsId": "chargeId"])

        XCTAssertEqual(finalResults(recorder).map(\.event), [.chargeAuthReject])
        XCTAssertEqual(finalResults(recorder).map(\.authenticationFlow), [.frictionless])
    }

    // MARK: - Challenge and decoupled (R_03)

    func testChallenge_thenSuccess() {
        let recorder = makeRecordingCoordinator()

        sendChallengeSequence(to: recorder, final: "chargeAuthSuccess")

        XCTAssertEqual(results(recorder).map(\.event), [.chargeAuthChallenge, .chargeAuthSuccess])
        XCTAssertEqual(results(recorder).map(\.authenticationFlow), [nil, .challenge])
    }

    func testChallenge_thenReject() {
        let recorder = makeRecordingCoordinator()

        sendChallengeSequence(to: recorder, final: "chargeAuthReject")

        XCTAssertEqual(results(recorder).map(\.event), [.chargeAuthChallenge, .chargeAuthReject])
        XCTAssertEqual(results(recorder).map(\.authenticationFlow), [nil, .challenge])
    }

    func testDecoupled_thenSuccess() {
        let recorder = makeRecordingCoordinator()

        sendDecoupledSequence(to: recorder, final: "chargeAuthSuccess")

        XCTAssertEqual(results(recorder).map(\.event), [.chargeAuthDecoupled, .chargeAuthSuccess])
        XCTAssertEqual(results(recorder).map(\.authenticationFlow), [nil, .decoupled])
    }

    func testDecoupled_thenReject() {
        let recorder = makeRecordingCoordinator()

        sendDecoupledSequence(to: recorder, final: "chargeAuthReject")

        XCTAssertEqual(results(recorder).map(\.event), [.chargeAuthDecoupled, .chargeAuthReject])
        XCTAssertEqual(results(recorder).map(\.authenticationFlow), [nil, .decoupled])
    }

    func testMostRecentWins_challengeThenDecoupled() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "chargeId"])

        XCTAssertEqual(finalResults(recorder).map(\.authenticationFlow), [.decoupled])
    }

    func testMostRecentWins_decoupledThenChallenge() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "chargeId"])

        XCTAssertEqual(finalResults(recorder).map(\.authenticationFlow), [.challenge])
    }

    // MARK: - Nil elsewhere and failures (R_04)

    func testNilOnChallengeDecoupledInfoAndChargeError() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthInfo"])
        recorder.coordinator.handleMessage(["event": "error", "charge3dsId": "chargeId"])

        XCTAssertEqual(results(recorder).map(\.event),
                       [.chargeAuthChallenge, .chargeAuthDecoupled, .chargeAuthInfo, .chargeError])
        XCTAssertEqual(results(recorder).map(\.authenticationFlow), [nil, nil, nil, nil])
    }

    func testInvalidMessage_deliversOneFailureAndNoResult() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["invalid": "data"])

        XCTAssertEqual(failures(recorder), [.mappingFailed])
        XCTAssertTrue(results(recorder).isEmpty)
    }

    func testSuccessWithoutId_deliversOneFailureAndNoResult() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess"])

        XCTAssertEqual(failures(recorder), [.mappingFailed])
        XCTAssertEqual(results(recorder).map(\.event), [.chargeAuthChallenge])
    }

    // MARK: - Per charge id (R_05)

    func testTwoIds_trackedSeparately() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_a"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_b"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_a"])

        let finals = finalResults(recorder)
        XCTAssertEqual(finals.map(\.charge3dsId), ["id_b", "id_a"])
        XCTAssertEqual(finals.map(\.authenticationFlow), [.frictionless, .challenge])
    }

    func testTrackingEnds_afterFinalEvent() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_a"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_a"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_a"])

        XCTAssertEqual(finalResults(recorder).map(\.authenticationFlow), [.challenge, .frictionless])
    }

    func testTrackingEnds_afterChargeErrorWithLastId() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "id_a"])
        recorder.coordinator.handleMessage(["event": "error"])
        recorder.coordinator.handleMessage(["event": "chargeAuthSuccess", "charge3dsId": "id_a"])

        XCTAssertEqual(results(recorder).map(\.event), [.chargeAuthChallenge, .chargeError, .chargeAuthSuccess])
        XCTAssertEqual(results(recorder).map(\.charge3dsId), ["id_a", "id_a", "id_a"])
        XCTAssertEqual(results(recorder).map(\.authenticationFlow), [nil, nil, .frictionless])
    }

    // MARK: - Unchanged events, progress and loading (R_06)

    func testChallengeSequence_eventsProgressAndLoadingUnchanged() {
        let recorder = makeRecordingCoordinator()

        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeLoaded", "charge3dsId": "chargeId", "reason": "load"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeCompleted", "charge3dsId": "chargeId", "source": "poll"])
        recorder.coordinator.handleMessage(["event": "chargeAuthReject", "charge3dsId": "chargeId"])

        XCTAssertEqual(recorder.events, [.chargeAuthChallenge, .chargeAuthReject])
        XCTAssertEqual(recorder.progress, [
            .challengeStarted(charge3dsId: "chargeId"),
            .challengeLoaded(charge3dsId: "chargeId", reason: .load),
            .challengeCompleted(charge3dsId: "chargeId", source: .poll)
        ])
        XCTAssertEqual(recorder.loading.calls, [.start, .finish, .start, .finish])
        XCTAssertFalse(recorder.coordinator.isLoading)
    }

    // MARK: - Helpers

    /// Coordinator wired to a recording loading delegate, already loading as it is after `makeUIView`
    /// (as `Standalone3DSTests.makeRecordingCoordinator` does).
    private func makeRecordingCoordinator() -> Recorder {
        let recorder = Recorder()
        recorder.coordinator = Standalone3DSWidget.Coordinator(
            completion: { [unowned recorder] in recorder.results.append($0) },
            loadingDelegate: recorder.loading,
            onProgress: { [unowned recorder] in recorder.progress.append($0) })
        recorder.coordinator.notifyLoadingStart()
        return recorder
    }

    private func sendChallengeSequence(to recorder: Recorder, final event: String) {
        recorder.coordinator.handleMessage(["event": "chargeAuthChallenge", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeLoaded", "charge3dsId": "chargeId", "reason": "load"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeCompleted", "charge3dsId": "chargeId", "source": "poll"])
        recorder.coordinator.handleMessage(["event": event, "charge3dsId": "chargeId"])
    }

    private func sendDecoupledSequence(to recorder: Recorder, final event: String) {
        recorder.coordinator.handleMessage(["event": "chargeAuthDecoupled", "charge3dsId": "chargeId"])
        recorder.coordinator.handleMessage(["event": "chargeAuthChallengeCompleted", "charge3dsId": "chargeId", "source": "callback"])
        recorder.coordinator.handleMessage(["event": event, "charge3dsId": "chargeId"])
    }

    private func results(_ recorder: Recorder) -> [Standalone3DSResult] {
        recorder.results.compactMap { try? $0.get() }
    }

    private func finalResults(_ recorder: Recorder) -> [Standalone3DSResult] {
        results(recorder).filter { $0.event == .chargeAuthSuccess || $0.event == .chargeAuthReject }
    }

    private func failures(_ recorder: Recorder) -> [Standalone3DSError] {
        recorder.results.compactMap {
            if case .failure(let error) = $0 { return error }
            return nil
        }
    }
}
