//
//  StackFrame.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The § 5.5 iOS frame form, applied where an error is captured.
package enum StackFrame {
    /// `<index> <image> 0x<address>`, then the rest of the line.
    private static let rawForm = makeRegex(#"^(\d+)\s+(\S+)\s+(0x[0-9A-Fa-f]+)(?:\s+(.*))?$"#)
    /// `<symbol> + <offset>`.
    private static let symbolWithOffset = makeRegex(#"^(.*\S)\s+\+\s+(\d+)$"#)

    /// One raw call-stack symbol line in the § 5.5 iOS form. Raw form: `<index> <image> 0x<address> <symbol> + <offset>`,
    /// whitespace-padded. Gives `<image> <symbol> + <offset>`, or `<image> 0x<address>` when the symbol is missing,
    /// `???` or the image name. A line not in the raw form (already sanitised, or from MetricKit) comes back trimmed.
    package static func sanitise(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let raw = groups(rawForm, trimmed) else {
            return trimmed
        }
        let image = raw[1] ?? ""
        let addressForm = "\(image) \(raw[2] ?? "")"
        let rest = (raw[3] ?? "").trimmingCharacters(in: .whitespaces)
        guard let parts = groups(symbolWithOffset, rest) else {
            return isMissing(rest, image: image) ? addressForm : "\(image) \(rest)"
        }
        let symbol = parts[0] ?? ""
        return isMissing(symbol, image: image) ? addressForm : "\(image) \(symbol) + \(parts[1] ?? "")"
    }

    private static func isMissing(_ symbol: String, image: String) -> Bool {
        symbol.isEmpty || symbol == "???" || symbol == image
    }

    /// The capture groups in order (nil for one that took no part), or nil when the text does not match.
    private static func groups(_ regex: NSRegularExpression, _ text: String) -> [String?]? {
        guard let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }
        return (1..<match.numberOfRanges).map { index in
            Range(match.range(at: index), in: text).map { String(text[$0]) }
        }
    }

    private static func makeRegex(_ pattern: String) -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: pattern)
        } catch {
            preconditionFailure("Invalid pattern \(pattern)")
        }
    }
}

extension StackFrame {
    /// R_08: `<image> 0x<offset>`; a system image with a symbol: `<image> <symbol> + <distance>`; unresolved:
    /// `??? 0x<address>`. Hex lowercase without padding; image = last path component.
    package static func describe(_ address: UInt, _ resolved: ResolvedAddress?) -> String {
        guard let resolved, address >= resolved.imageLoadAddress else {
            return "??? 0x\(String(address, radix: 16))"
        }
        let image = (resolved.imagePath as NSString).lastPathComponent
        if isSystemImage(resolved.imagePath), let symbol = resolved.symbol, !symbol.isEmpty,
           let symbolAddress = resolved.symbolAddress, symbolAddress <= address {
            return "\(image) \(symbol) + \(address - symbolAddress)"
        }
        return "\(image) 0x\(String(address - resolved.imageLoadAddress, radix: 16))"
    }

    /// A path containing `/System/Library/` or `/usr/lib/`, or starting with `/System/` or `/usr/`.
    package static func isSystemImage(_ path: String) -> Bool {
        path.contains("/System/Library/") || path.contains("/usr/lib/") || path.hasPrefix("/System/")
            || path.hasPrefix("/usr/")
    }
}
