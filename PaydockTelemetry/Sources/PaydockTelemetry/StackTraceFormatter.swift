//
//  StackTraceFormatter.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// `exception.stacktrace` (spec § 5.5): the same text shape on every platform.
package enum StackTraceFormatter {
    package static let maxFrames = 64        // per exception
    package static let maxCauses = 8
    package static let maxBytes = 16_384     // UTF-8, whole lines only

    /// The type line (`Caused by: <type>` for a cause; none when the type is nil), then `\tat <frame>` per frame,
    /// joined with `\n`, cut at the last whole line that keeps the text within `maxBytes`.
    package static func format(_ error: TelemetryEvent.ErrorInfo) -> String {
        var lines = section(error, prefix: "")
        var cause = error.cause
        var causes = 0
        while let current = cause, causes < maxCauses {
            lines += section(current, prefix: "Caused by: ")
            cause = current.cause
            causes += 1
        }
        return within(maxBytes, lines)
    }

    private static func section(_ error: TelemetryEvent.ErrorInfo, prefix: String) -> [String] {
        let typeLine = error.type.map { ["\(prefix)\($0)"] } ?? []
        return typeLine + error.frames.prefix(maxFrames).map { "\tat \($0)" }
    }

    /// The leading lines whose `\n`-joined UTF-8 size stays within `limit`.
    private static func within(_ limit: Int, _ lines: [String]) -> String {
        var kept: [String] = []
        var size = 0
        for line in lines {
            let added = line.utf8.count + (kept.isEmpty ? 0 : 1)
            if size + added > limit {
                break
            }
            kept.append(line)
            size += added
        }
        return kept.joined(separator: "\n")
    }
}
