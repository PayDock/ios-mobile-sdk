//
//  AllowlistTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// The build-failing guard of MD-14's acceptance (R_05, R_07): no unlisted key, wrong kind or sensitive-looking value
/// reaches an encoded record, and a batch that could carry one is never sendable. Failure messages name cases and
/// keys, never the sensitive values.
final class AllowlistTests: XCTestCase {

    private typealias Samples = SensitiveSamples

    /// An attribute the allowlist must refuse.
    private struct Unsendable {
        let name: String
        let key: String
        let value: AttributeValue
    }

    private let otherSessionId = "9a3e5d71-0c2b-4f86-b1e4-7d5a2c9f0e13"

    /// A valid SDK error record with no code and no widget: its body is `paydock.error · sdk_error · Sample.Error`.
    private lazy var base: TelemetryRecord = {
        let pending = PendingRecord(id: "\(Samples.sessionId)-4", sessionId: Samples.sessionId,
                                    event: .sdkError(error: TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: [])),
                                    createdAt: Samples.builtAt)
        return RecordFactory.create(pending, connection: .wifi)
    }()

    // MARK: - What may be sent

    func testSyntheticValues_AreWhatTheChecksLookFor() {
        XCTAssertEqual(Samples.cardNumber.count, 16)
        XCTAssertEqual(Samples.groupedCardNumber.count, 19)
        for (name, value) in sensitiveValues {
            XCTAssertTrue(Allowlist.isSensitive(value), name)
        }
        XCTAssertFalse(Allowlist.isSensitive(Samples.longSecret, checkingLongSecrets: false))
        XCTAssertFalse(Allowlist.isSensitive(Samples.mangledSymbol, checkingLongSecrets: false))
        XCTAssertTrue(Allowlist.isSensitive(Samples.mangledSymbol))
    }

    func testEveryFixtureBatch_EncodesWithNoViolation_AndNoForbiddenString() throws {
        let resource = try GoldenFixtures.resource()

        for fixture in try GoldenFixtures.all() {
            let record = try GoldenFixtures.record(fixture)

            XCTAssertEqual(Allowlist.violations(resource: resource, records: [record]), [], fixture.name)
            assertClean(OtlpLogEncoder.encode(resource: resource, records: [record]), fixture.name)
        }
    }

    func testEveryEventVariant_BuiltFromErrorsHoldingSensitiveText_EncodesWithNoViolation() throws {
        let resource = try GoldenFixtures.resource()
        let built = Samples.builtRecords()
        let records = built.map(Samples.sendable)

        XCTAssertEqual(Set(records.compactMap(\.eventName)),
                       ["paydock.crash", "paydock.error", "paydock.network.failure", "paydock.widget.opened",
                        "paydock.telemetry.dropped"])
        for (index, record) in built.enumerated() {
            XCTAssertEqual(Allowlist.filter(record), record, "variant \(index): the filter dropped an attribute")
        }
        XCTAssertEqual(Allowlist.violations(resource: resource, records: records), [])
        assertClean(OtlpLogEncoder.encode(resource: resource, records: records), "every variant")
    }

    func testAMangledSwiftSymbol_SurvivesInTheStackTrace_ButNotInAnotherKey() {
        let stackTrace = "Sample.Error\n\tat MobileSDK \(Samples.mangledSymbol) + 340"
        let traced = base.with("exception.stacktrace", .string(stackTrace))

        XCTAssertEqual(Allowlist.filter(traced), traced)
        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: [traced]), [])

        let elsewhere = tainted("paydock.error.code", .string(Samples.mangledSymbol))
        XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [elsewhere]).isEmpty)
        XCTAssertEqual(Allowlist.filter(elsewhere), base)
    }

    func testTheStackTrace_StillFailsOnACardNumberEmailOrToken() {
        for (name, value) in sensitiveValues where name != "long secret" {
            let record = tainted("exception.stacktrace", .string("Sample.Error\n\tat MobileSDK \(value) + 12"))

            XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty, name)
            XCTAssertNil(Allowlist.filter(record).value("exception.stacktrace"), name)
        }
    }

    // MARK: - What must not be sent

    func testViolations_AndTheFilter_ForEveryUnsendableAttribute() {
        var cases = [
            Unsendable(name: "unlisted key", key: "paydock.sample.unlisted", value: .string("value")),
            Unsendable(name: "int where a string belongs", key: "paydock.error.code", value: .int(42)),
            Unsendable(name: "bool where an int belongs", key: "paydock.occurrences", value: .bool(true)),
            Unsendable(name: "email in the widget", key: "paydock.widget", value: .string(Samples.email)),
            Unsendable(name: "bearer value in the thread name", key: "thread.name", value: .string(Samples.bearer))
        ]
        cases += sensitiveValues.map {
            Unsendable(name: "\($0.name) in a string value", key: "paydock.error.code", value: .string("CODE \($0.value)"))
        }

        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: [base]), [])
        for item in cases {
            let record = tainted(item.key, item.value)

            XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty, item.name)
            XCTAssertEqual(Allowlist.filter(record), base, "\(item.name): the filter keeps it or leaves the body")
        }
    }

    func testViolations_ForAMissingSessionIdOrRecordUid() {
        for key in ["session.id", "log.record.uid"] {
            let attributes = base.attributes.filter { $0.key != key }
            let record = TelemetryRecord(id: base.id, timeUnixMillis: base.timeUnixMillis, severity: base.severity,
                                         body: base.body, attributes: attributes)

            XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty, key)
        }
    }

    func testViolations_AndTheFilter_ForARecordUidOfAnotherSessionOrSequenceZero() {
        for uid in ["\(otherSessionId)-4", "\(Samples.sessionId)-0", "\(Samples.sessionId)-04", Samples.sessionId] {
            let record = base.with("log.record.uid", .string(uid))

            XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty, uid)
            XCTAssertNil(Allowlist.filter(record).value("log.record.uid"), uid)
        }
    }

    func testViolations_ForAMalformedSessionId() {
        let record = base.with("session.id", .string("not-a-session"))

        XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty)
        XCTAssertNil(Allowlist.filter(record).value("session.id"))
    }

    func testViolations_ForAResourceWithAnEmptyOrMalformedInstallationId() {
        XCTAssertFalse(Allowlist.violations(resource: sampleResource(installationId: ""), records: []).isEmpty)
        XCTAssertFalse(Allowlist.violations(resource: sampleResource(installationId: "installation"), records: [base]).isEmpty)
        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: []), [])
    }

    func testViolationMessages_NeverHoldTheValue() {
        let records = sensitiveValues.map { tainted("paydock.error.code", .string($0.value)) }
        let messages = Allowlist.violations(resource: sampleResource(), records: records).joined(separator: "\n")

        // One for the attribute, one for the body the value reaches.
        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: records).count, 2 * sensitiveValues.count)
        for (name, value) in sensitiveValues {
            XCTAssertFalse(messages.contains(value), name)
        }
    }

    func testCardNumber_AsALuhnValidRunOf13To19Digits() {
        XCTAssertTrue(Allowlist.isSensitive("card \(Samples.cardNumber.replacingOccurrences(of: "0000", with: "00-00"))"))
        XCTAssertFalse(Allowlist.isSensitive("A\(Samples.cardNumber)"), "touches a letter")
        let checkDigit = Samples.cardNumber.last?.wholeNumberValue ?? 0
        XCTAssertFalse(Allowlist.isSensitive(String(Samples.cardNumber.dropLast()) + String((checkDigit + 1) % 10)), "fails Luhn")
        XCTAssertFalse(Allowlist.isSensitive("123456789012"), "too short")
        XCTAssertFalse(Allowlist.isSensitive("MobileSDK 0x0000000104a3c1f0"))
    }

    // MARK: - Hardening (R_19)

    func testACardNumber_InsideALongerDigitRun_IsFlagged() {
        for suffix in [" 123", " 12 28", "-123", " 12-28"] {
            XCTAssertTrue(Allowlist.isSensitive("ref \(Samples.cardNumber)\(suffix)"), "followed by a \(suffix.count)-character run")
            XCTAssertTrue(Allowlist.isSensitive("\(Samples.groupedCardNumber)\(suffix)"), "grouped, followed by a run")
            XCTAssertTrue(Allowlist.isSensitive(String(suffix.dropFirst()) + " " + Samples.cardNumber), "preceded by a run")
            let record = tainted("paydock.error.code", .string("CODE \(Samples.cardNumber)\(suffix)"))
            XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty)
            XCTAssertEqual(Allowlist.filter(record), base)
        }
        XCTAssertFalse(Allowlist.isSensitive("A\(Samples.cardNumber) 123"), "the run touches a letter")
        XCTAssertFalse(Allowlist.isSensitive("12  \(String(Samples.cardNumber.prefix(12)))"), "no window of 13 digits")
    }

    func testAStackTraceWithAddresses_StillPasses() {
        let frames = SensitiveSamples.rawFrames.map(StackFrame.sanitise) + [
            "3   MobileSDK   0x0000000104a3c1f0 0x104a30000 + 49648",
            "4   libsystem_kernel.dylib   0x00000001a5c1e8f0 __pthread_kill + 8"
        ]
        let stackTrace = (["Sample.Error"] + frames.map { "\tat \($0)" }).joined(separator: "\n")
        let traced = base.with("exception.stacktrace", .string(stackTrace))

        XCTAssertFalse(Allowlist.isSensitive(stackTrace, checkingLongSecrets: false))
        XCTAssertEqual(Allowlist.filter(traced), traced)
        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: [traced]), [])
    }

    func testABody_DifferingFromTheBodyRule_OrHoldingAnEmail_IsAViolation() {
        let differing = TelemetryRecord(id: base.id, timeUnixMillis: base.timeUnixMillis, severity: base.severity,
                                        body: base.body + " · extra", attributes: base.attributes)
        let violations = Allowlist.violations(resource: sampleResource(), records: [differing])
        XCTAssertEqual(violations, ["record 0: body differs from the body rule"])
        XCTAssertEqual(Allowlist.filter(differing), base, "the filter rebuilds the body")

        let withEmail = TelemetryRecord(id: base.id, timeUnixMillis: base.timeUnixMillis, severity: base.severity,
                                        body: "\(base.body) · \(Samples.email)", attributes: base.attributes)
        let messages = Allowlist.violations(resource: sampleResource(), records: [withEmail])
        XCTAssertTrue(messages.contains("record 0: body holds a sensitive value"), "\(messages.count) violations")
        XCTAssertFalse(messages.joined().contains(Samples.email))

        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: [base]), [])
    }

    // MARK: - Payments (D24)

    func testThePaymentKeys_EndTheRecordKeys_WithTheirKinds() {
        XCTAssertEqual(Array(Allowlist.recordKeys.suffix(5)), [
            "paydock.dropped.reason", "paydock.dropped.count",
            "paydock.payment.id", "paydock.payment.outcome", "paydock.payment.duration_ms"
        ])
        XCTAssertEqual(Allowlist.recordKinds["paydock.payment.id"], .string)
        XCTAssertEqual(Allowlist.recordKinds["paydock.payment.outcome"], .string)
        XCTAssertEqual(Allowlist.recordKinds["paydock.payment.duration_ms"], .int)
    }

    func testAPaymentRecord_IsSendable_AndKeptWhole() {
        let record = payment(outcome: .error, errorCode: "CARD_TOKENISE_ERROR")

        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: [record]), [])
        XCTAssertEqual(Allowlist.filter(record), record)
    }

    func testANonUUIDPaymentId_IsDropped() {
        for paymentId in ["not-a-payment", "9b2e4f61-7c3a-4d58-a1e9", "9b2e4f617c3a4d58a1e93f0d6b8c2a17", ""] {
            let record = payment(outcome: .success).with("paydock.payment.id", .string(paymentId))

            XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty, paymentId)
            XCTAssertNil(Allowlist.filter(record).value("paydock.payment.id"), paymentId)
        }
    }

    func testAnUnknownOutcome_IsDropped() {
        for outcome in ["failed", "SUCCESS", "canceled", ""] {
            let record = payment(outcome: .success).with("paydock.payment.outcome", .string(outcome))

            XCTAssertFalse(Allowlist.violations(resource: sampleResource(), records: [record]).isEmpty, outcome)
            let filtered = Allowlist.filter(record)
            XCTAssertNil(filtered.value("paydock.payment.outcome"), outcome)
            XCTAssertEqual(filtered.body, "paydock.payment.finished · PayPalWidget", outcome)
        }
        for outcome in TelemetryEvent.PaymentOutcome.allCases {
            let record = payment(outcome: outcome)
            XCTAssertEqual(Allowlist.filter(record), record, outcome.rawValue)
        }
    }

    /// A random UUID can hold an all-digit run whose window passes Luhn: the shape check alone keeps it. The UUID is
    /// built at run time from the synthetic card number, so no source file holds a Luhn-valid digit run.
    func testAUUIDWhoseDigitGroupsFormALuhnValidRun_IsKept() {
        let digitsOnly = allDigitUUID(Samples.cardNumber + String(repeating: "7", count: 16))
        XCTAssertTrue(Allowlist.isSensitive(digitsOnly), "the card check alone would reject it")

        let record = RecordFactory.create(
            PendingRecord(id: "\(Samples.sessionId)-6", sessionId: Samples.sessionId,
                          event: .paymentStarted(widget: "CardDetailsWidget", paymentId: digitsOnly), createdAt: Samples.builtAt),
            connection: .wifi
        )

        XCTAssertEqual(record.value("paydock.payment.id"), .string(digitsOnly))
        XCTAssertEqual(Allowlist.filter(record), record)
        XCTAssertEqual(Allowlist.violations(resource: sampleResource(), records: [record]), [])
    }

    // MARK: - Helpers

    /// 32 digits grouped 8-4-4-4-12, the UUID shape.
    private func allDigitUUID(_ digits: String) -> String {
        precondition(digits.count == 32 && digits.allSatisfy(\.isNumber))
        var rest = Substring(digits)
        return [8, 4, 4, 4, 12].map { length -> String in
            defer { rest = rest.dropFirst(length) }
            return String(rest.prefix(length))
        }.joined(separator: "-")
    }

    /// A finished payment record of `PayPalWidget`, as the factory builds it.
    private func payment(outcome: TelemetryEvent.PaymentOutcome, errorCode: String? = nil) -> TelemetryRecord {
        let event = TelemetryEvent.paymentFinished(widget: "PayPalWidget", paymentId: "9b2e4f61-7c3a-4d58-a1e9-3f0d6b8c2a17",
                                                   outcome: outcome, errorCode: errorCode, durationMs: 41_873)
        let pending = PendingRecord(id: "\(Samples.sessionId)-5", sessionId: Samples.sessionId, event: event,
                                    createdAt: Samples.builtAt)
        return RecordFactory.create(pending, connection: .wifi)
    }

    private var sensitiveValues: [(name: String, value: String)] {
        [
            ("card number", Samples.cardNumber),
            ("grouped card number", Samples.groupedCardNumber),
            ("email", Samples.email),
            ("JWT", Samples.jwt),
            ("bearer value", Samples.bearer),
            ("long secret", Samples.longSecret)
        ]
    }

    /// The base record with the attribute set, and its body rebuilt from it, so the value reaches the body too.
    private func tainted(_ key: String, _ value: AttributeValue) -> TelemetryRecord {
        let attributes = base.with(key, value).attributes
        return TelemetryRecord(id: base.id, timeUnixMillis: base.timeUnixMillis, severity: base.severity,
                               body: RecordBody.of(attributes), attributes: attributes)
    }

    private func sampleResource(installationId: String = "5f0d2b8a-6c41-4e97-a3b2-8d1e7c9f4a60") -> ResourceAttributes {
        ResourceAttributes(serviceVersion: "4.9.1", deploymentEnvironmentName: "sandbox", osVersion: "18.1",
                           deviceModelIdentifier: "iPhone15,2", appInstallationId: installationId, appId: "com.paydock.example",
                           appVersion: "1.0.0", appDebuggable: true)
    }

    /// The encoded text holds no sensitive sample string and no `service.instance.id`.
    private func assertClean(_ data: Data, _ name: String, file: StaticString = #filePath, line: UInt = #line) {
        let json = String(bytes: data, encoding: .utf8) ?? ""

        XCTAssertFalse(json.isEmpty, name, file: file, line: line)
        XCTAssertFalse(json.contains("service.instance.id"), "\(name): service.instance.id", file: file, line: line)
        for (index, forbidden) in Samples.forbiddenInOutput.enumerated() {
            XCTAssertFalse(json.contains(forbidden), "\(name): forbidden sample \(index)", file: file, line: line)
        }
    }
}
