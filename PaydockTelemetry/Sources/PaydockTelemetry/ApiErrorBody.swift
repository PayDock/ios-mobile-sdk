//
//  ApiErrorBody.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The API's structured codes from a raw error body (R_05). Reads only `status`, `error.code`, `error_summary.code`
/// and the `gateway_specific_code` of `error.details`, `error_summary.details` and each of their `messages[]`, in that
/// order, distinct, non-blank. Nil for nil, empty, over 64 KB or non-object JSON, or when none of the fields is
/// present. Never a message or description.
package enum ApiErrorBody {
    package static let maxBytes = 65_536

    package static func apiError(from body: Data?) -> TelemetryEvent.APIError? {
        guard let body, !body.isEmpty, body.count <= maxBytes,
              let root = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any] else {
            return nil
        }
        let error = root["error"] as? [String: Any]
        let summary = root["error_summary"] as? [String: Any]
        let errorDetails = error?["details"] as? [String: Any]
        let summaryDetails = summary?["details"] as? [String: Any]
        let places = [errorDetails, summaryDetails] + [errorDetails, summaryDetails].flatMap(messages)
        var gatewayCodes: [String] = []
        for code in places.compactMap({ text($0?["gateway_specific_code"]) }) where !gatewayCodes.contains(code) {
            gatewayCodes.append(code)
        }
        let apiError = TelemetryEvent.APIError(status: integer(root["status"]), code: text(error?["code"]),
                                               summaryCode: text(summary?["code"]), gatewayCodes: gatewayCodes)
        guard apiError.status != nil || apiError.code != nil || apiError.summaryCode != nil
                || !apiError.gatewayCodes.isEmpty else {
            return nil
        }
        return apiError
    }

    /// The objects of a details object's `messages` array.
    private static func messages(_ details: [String: Any]?) -> [[String: Any]?] {
        ((details?["messages"] as? [Any]) ?? []).map { $0 as? [String: Any] }
    }

    /// A string that is not blank.
    private static func text(_ value: Any?) -> String? {
        guard let value = value as? String, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }

    /// A JSON number with no fraction; never a boolean or a string.
    private static func integer(_ value: Any?) -> Int? {
        guard let number = value as? NSNumber, CFGetTypeID(number) != CFBooleanGetTypeID() else {
            return nil
        }
        return Int(exactly: number.doubleValue)
    }
}
