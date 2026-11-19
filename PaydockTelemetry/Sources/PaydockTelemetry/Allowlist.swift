//
//  Allowlist.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The attribute keys a record and a resource may carry (spec § 5.1, § 5.2), and their value kinds.
package enum Allowlist {
    package enum ValueKind: Sendable, Equatable { case string, int, bool }

    /// The 14 § 5.1 keys, in § 5.1 order.
    package static let resourceKeys: [String] = [
        "service.name", "service.namespace", "service.version", "paydock.sdk.platform", "paydock.telemetry.spec_version",
        "deployment.environment.name", "os.name", "os.version", "device.manufacturer", "device.model.identifier",
        "app.installation.id", "paydock.app.id", "paydock.app.version", "paydock.app.debuggable"
    ]

    /// Encoding order (generate.py ORDER).
    package static let recordKeys: [String] = recordKeysAndKinds.map(\.key)

    /// Each record key's kind.
    package static let recordKinds: [String: ValueKind] = Dictionary(uniqueKeysWithValues: recordKeysAndKinds)

    private static let recordKeysAndKinds: [(key: String, kind: ValueKind)] = [
        // Common
        ("event.name", .string), ("session.id", .string), ("log.record.uid", .string), ("network.connection.type", .string),
        ("paydock.widget", .string), ("paydock.occurrences", .int), ("paydock.group.key", .string),
        ("paydock.occurred_at", .string),
        // Exception
        ("exception.type", .string), ("exception.stacktrace", .string), ("paydock.exception.cause_types", .string),
        ("paydock.exception.in_sdk", .bool), ("paydock.error.kind", .string), ("paydock.error.code", .string),
        ("paydock.crash.kind", .string), ("paydock.crash.source", .string), ("paydock.crash.reason", .string),
        ("thread.name", .string),
        // Network
        ("http.request.method", .string), ("url.template", .string), ("server.address", .string),
        ("http.response.status_code", .int), ("error.type", .string), ("paydock.api.status", .int),
        ("paydock.api.error.code", .string), ("paydock.api.error.summary_code", .string),
        ("paydock.api.gateway.codes", .string), ("paydock.http.attempt", .int),
        // Dropped
        ("paydock.dropped.reason", .string), ("paydock.dropped.count", .int),
        // Payment (D24)
        ("paydock.payment.id", .string), ("paydock.payment.outcome", .string), ("paydock.payment.duration_ms", .int)
    ]

    // MARK: - Patterns

    private static let uuid = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
    private static let template = #"(?:/|(?:/(?:[a-z_-]+|v[0-9]+|\{[a-z_]+\}))+)"#
    private static let uuidShape = makeRegex("^\(uuid)$")
    private static let sequenceShape = makeRegex("^[1-9][0-9]{0,18}$")
    private static let templateShape = makeRegex("^\(template)$")
    private static let groupKeyShape = makeRegex("^http [A-Z]+ \(template) [0-9]{3}$")
    private static let digitRun = makeRegex(#"\d(?:[ -]?\d)*"#)
    private static let email = makeRegex(#"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#)
    private static let jwt = makeRegex(#"eyJ[A-Za-z0-9_-]{5,}\.[A-Za-z0-9_-]{5,}\."#)
    private static let authorization = makeRegex(#"(bearer|basic)\s+[A-Za-z0-9+/=._-]{8,}"#, options: .caseInsensitive)
    private static let longRun = makeRegex(#"[A-Za-z0-9+/=]{40,}"#)

    // MARK: - Filter and checks

    /// Keeps the attributes whose key is listed, whose value has the key's kind and whose string passes its check;
    /// a repeated key keeps its first value; then body = RecordBody.of(kept).
    package static func filter(_ record: TelemetryRecord) -> TelemetryRecord {
        var seen = Set<String>()
        var kept: [TelemetryAttribute] = []
        for attribute in record.attributes where seen.insert(attribute.key).inserted {
            if problem(attribute, sessionId: record.sessionId) == nil {
                kept.append(attribute)
            }
        }
        return TelemetryRecord(id: record.id, timeUnixMillis: record.timeUnixMillis, severity: record.severity,
                               body: RecordBody.of(kept), attributes: kept)
    }

    /// True when the value holds a card number (also inside a longer digit run), an email, a JWT, an authorization
    /// value, or (unless `checkingLongSecrets` is false) a long secret.
    package static func isSensitive(_ value: String, checkingLongSecrets: Bool = true) -> Bool {
        hasCardNumber(value) || found(email, in: value) || found(jwt, in: value) || found(authorization, in: value)
            || (checkingLongSecrets && hasLongSecret(value))
    }

    /// Why a batch must not be sent; empty when it may. The exporter sends only a batch with no violation. A record
    /// whose body is not `RecordBody.of(attributes)`, or holds a sensitive value, is a violation too (R_19).
    /// A violation names keys and positions only, never a value.
    package static func violations(resource: ResourceAttributes, records: [TelemetryRecord]) -> [String] {
        var found: [String] = []
        let map = resource.asMap()
        if Set(map.keys) != Set(resourceKeys) {
            let missing = resourceKeys.filter { map[$0] == nil }
            let unlisted = map.keys.filter { !resourceKeys.contains($0) }.sorted()
            found.append("resource keys differ from the allowlist: missing \(missing), unlisted \(unlisted)")
        }
        if !isUUID(map["app.installation.id"]) {
            found.append("resource: app.installation.id is missing or not a UUID")
        }
        for (index, record) in records.enumerated() {
            found += violations(of: record).map { "record \(index): \($0)" }
        }
        return found
    }

    private static func violations(of record: TelemetryRecord) -> [String] {
        var found: [String] = []
        for key in ["session.id", "log.record.uid"] where record.value(key) == nil {
            found.append("missing \(key)")
        }
        for attribute in record.attributes {
            if let problem = problem(attribute, sessionId: record.sessionId) {
                found.append(problem)
            }
        }
        if record.body != RecordBody.of(record.attributes) {
            found.append("body differs from the body rule")
        }
        if isSensitive(record.body) {
            found.append("body holds a sensitive value")
        }
        return found
    }

    /// Why the attribute may not be kept, or nil when it may.
    private static func problem(_ attribute: TelemetryAttribute, sessionId: String?) -> String? {
        let key = attribute.key
        guard let kind = recordKinds[key] else {
            return "unlisted key \(key)"
        }
        switch (kind, attribute.value) {
        case (.int, .int), (.bool, .bool):
            return nil
        case let (.string, .string(text)):
            return passes(key, text, sessionId: sessionId) ? nil : "\(key) fails its check"
        default:
            return "wrong kind for \(key)"
        }
    }

    private static func passes(_ key: String, _ text: String, sessionId: String?) -> Bool {
        switch key {
        case "session.id", "paydock.payment.id":
            // The shape alone: a random UUID can hold an all-digit run the card check would reject.
            return matches(uuidShape, text)
        case "paydock.payment.outcome":
            return TelemetryEvent.PaymentOutcome(rawValue: text) != nil
        case "log.record.uid":
            guard let sessionId, text.hasPrefix("\(sessionId)-") else {
                return false
            }
            return matches(sequenceShape, String(text.dropFirst(sessionId.count + 1)))
        case "url.template":
            return matches(templateShape, text)
        case "paydock.group.key":
            return matches(groupKeyShape, text)
        case "exception.stacktrace":
            return !isSensitive(text, checkingLongSecrets: false)
        default:
            return !isSensitive(text)
        }
    }

    // MARK: - Sensitive values

    /// A maximal run of digits joined by single spaces or dashes, touching no ASCII letter or digit at either end, whose
    /// digits, separators removed, hold a contiguous window of 13 to 19 digits that passes Luhn (R_19): a card number
    /// inside a longer run is still caught.
    private static func hasCardNumber(_ value: String) -> Bool {
        ranges(digitRun, in: value).contains { range in
            let before = range.lowerBound == value.startIndex ? nil : value[value.index(before: range.lowerBound)]
            let after = range.upperBound == value.endIndex ? nil : value[range.upperBound]
            return !isASCIILetterOrDigit(before) && !isASCIILetterOrDigit(after)
                && hasLuhnWindow(value[range].compactMap(\.wholeNumberValue))
        }
    }

    private static func hasLuhnWindow(_ digits: [Int]) -> Bool {
        for length in 13...19 where length <= digits.count {
            for start in 0...(digits.count - length) where passesLuhn(digits[start..<(start + length)]) {
                return true
            }
        }
        return false
    }

    private static func passesLuhn(_ digits: ArraySlice<Int>) -> Bool {
        var sum = 0
        for (position, digit) in digits.reversed().enumerated() {
            let weighted = position % 2 == 1 ? digit * 2 : digit
            sum += weighted > 9 ? weighted - 9 : weighted
        }
        return sum % 10 == 0
    }

    /// A run of 40 or more `[A-Za-z0-9+/=]` holding a letter and a digit.
    private static func hasLongSecret(_ value: String) -> Bool {
        ranges(longRun, in: value).contains { range in
            value[range].contains { $0.isASCII && $0.isLetter } && value[range].contains { $0.isASCII && $0.isNumber }
        }
    }

    private static func isASCIILetterOrDigit(_ character: Character?) -> Bool {
        guard let character else {
            return false
        }
        return character.isASCII && (character.isLetter || character.isNumber)
    }

    private static func isUUID(_ value: ResourceAttributeValue?) -> Bool {
        guard case let .string(text) = value else {
            return false
        }
        return matches(uuidShape, text)
    }

    // MARK: - Regular expressions

    private static func matches(_ regex: NSRegularExpression, _ text: String) -> Bool {
        found(regex, in: text)
    }

    private static func found(_ regex: NSRegularExpression, in text: String) -> Bool {
        regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    private static func ranges(_ regex: NSRegularExpression, in text: String) -> [Range<String.Index>] {
        regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap { Range($0.range, in: text) }
    }

    private static func makeRegex(_ pattern: String, options: NSRegularExpression.Options = []) -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Invalid pattern \(pattern)")
        }
    }
}
