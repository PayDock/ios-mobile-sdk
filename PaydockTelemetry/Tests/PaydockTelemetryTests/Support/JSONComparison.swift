//
//  JSONComparison.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Compares two parsed JSON values (`JSONSerialization` objects): objects by key, arrays in order (so attribute
/// order counts), and a boolean never equals a number.
enum JSONComparison {

    /// The path of the first difference, or nil when the values are equal.
    static func firstDifference(_ actual: Any, _ expected: Any, path: String = "$") -> String? {
        switch (actual, expected) {
        case let (actual as [String: Any], expected as [String: Any]):
            guard Set(actual.keys) == Set(expected.keys) else {
                return "\(path): keys \(actual.keys.sorted()) != \(expected.keys.sorted())"
            }
            for (key, value) in expected.sorted(by: { $0.key < $1.key }) {
                if let difference = firstDifference(actual[key] ?? NSNull(), value, path: "\(path).\(key)") {
                    return difference
                }
            }
            return nil
        case let (actual as [Any], expected as [Any]):
            guard actual.count == expected.count else {
                return "\(path): \(actual.count) elements != \(expected.count)"
            }
            for (index, pair) in zip(actual, expected).enumerated() {
                if let difference = firstDifference(pair.0, pair.1, path: "\(path)[\(index)]") {
                    return difference
                }
            }
            return nil
        default:
            return same(actual, expected) ? nil : "\(path): \(actual) != \(expected)"
        }
    }

    /// Sorted-key, pretty-printed text of a parsed value, for failure messages.
    static func text(_ value: Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys]),
              let text = String(bytes: data, encoding: .utf8) else {
            return "\(value)"
        }
        return text
    }

    private static func same(_ actual: Any, _ expected: Any) -> Bool {
        switch (actual, expected) {
        case let (actual as String, expected as String):
            return actual == expected
        case let (actual as NSNumber, expected as NSNumber):
            return isBool(actual) == isBool(expected) && actual == expected
        case (is NSNull, is NSNull):
            return true
        default:
            return false
        }
    }

    private static func isBool(_ number: NSNumber) -> Bool {
        CFGetTypeID(number) == CFBooleanGetTypeID()
    }
}
