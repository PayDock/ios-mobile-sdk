//
//  SourceScan.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest

/// Reads the SDK's own sources for the telemetry source scans: the repo root from this file's path, the `.swift` files
/// under a directory, and each line with its comments and string literals blanked, so braces and names count only
/// where they are code.
enum SourceScan {

    /// A source file: its repo-relative path and its lines as code (comments and string contents removed).
    struct File {
        let path: String
        let code: [String]
    }

    static let repoRoot: URL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // Telemetry
        .deletingLastPathComponent() // MobileSDKTests
        .deletingLastPathComponent() // Tests
        .deletingLastPathComponent() // repo root

    /// Every `.swift` file under the repo-relative `directory`, sorted by path.
    static func files(under directory: String) throws -> [File] {
        let url = repoRoot.appendingPathComponent(directory)
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) else {
            return []
        }
        return try enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
            .map { try file(at: relativePath(of: $0)) }
            .sorted { $0.path < $1.path }
    }

    /// The file at the repo-relative `path`.
    static func file(at path: String) throws -> File {
        let text = try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
        return File(path: path, code: codeLines(text))
    }

    /// The number of non-overlapping matches of `regex` across `lines`.
    static func count(_ regex: NSRegularExpression, in lines: [String]) -> Int {
        lines.reduce(0) { $0 + regex.numberOfMatches(in: $1, range: NSRange($1.startIndex..., in: $1)) }
    }

    static func matches(_ regex: NSRegularExpression, _ text: String) -> Bool {
        regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    static func makeRegex(_ pattern: String) -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: pattern)
        } catch {
            preconditionFailure("Invalid pattern \(pattern)")
        }
    }

    /// The `{` minus `}` balance of a code line.
    static func braceBalance(_ line: String) -> Int {
        line.reduce(0) { $0 + ($1 == "{" ? 1 : $1 == "}" ? -1 : 0) }
    }

    /// The index of the first line after `start` that leaves the block `start` sits in (the line whose `}` closes
    /// it), or `lines.count`.
    static func blockEnd(after start: Int, in lines: [String]) -> Int {
        var depth = 0
        var index = start + 1
        while index < lines.count {
            for character in lines[index] {
                if character == "{" { depth += 1 }
                if character == "}" {
                    depth -= 1
                    if depth < 0 { return index }
                }
            }
            index += 1
        }
        return lines.count
    }

    /// The index of the line that opens the block `start` sits in (the line whose `{` opens it), or -1.
    static func blockStart(before start: Int, in lines: [String]) -> Int {
        var depth = 0
        var index = start - 1
        while index >= 0 {
            for character in lines[index].reversed() {
                if character == "}" { depth += 1 }
                if character == "{" {
                    depth -= 1
                    if depth < 0 { return index }
                }
            }
            index -= 1
        }
        return -1
    }

    private static func relativePath(of file: URL) -> String {
        let rootPath = repoRoot.standardizedFileURL.path + "/"
        let filePath = file.standardizedFileURL.path
        return filePath.hasPrefix(rootPath) ? String(filePath.dropFirst(rootPath.count)) : filePath
    }

    /// Blanks `//` and `/* */` comments and the contents of string literals (keeping the quotes), line by line.
    /// Multi-line string literals (`"""`) are blanked whole.
    private static func codeLines(_ text: String) -> [String] {
        var inBlockComment = false
        var inMultilineString = false
        return text.components(separatedBy: .newlines).map { line in
            var code = ""
            var inString = false
            var characters = Array(line)[...]
            while let character = characters.first {
                let rest = String(characters.prefix(3))
                if inBlockComment {
                    if rest.hasPrefix("*/") { inBlockComment = false; characters = characters.dropFirst(2) } else {
                        characters = characters.dropFirst()
                    }
                    continue
                }
                if inMultilineString {
                    if rest == "\"\"\"" { inMultilineString = false; characters = characters.dropFirst(3) } else {
                        characters = characters.dropFirst()
                    }
                    continue
                }
                if inString {
                    if character == "\\" { characters = characters.dropFirst(2); continue }
                    if character == "\"" { inString = false; code.append(character) }
                    characters = characters.dropFirst()
                    continue
                }
                if rest == "\"\"\"" { inMultilineString = true; characters = characters.dropFirst(3); continue }
                if rest.hasPrefix("//") { break }
                if rest.hasPrefix("/*") { inBlockComment = true; characters = characters.dropFirst(2); continue }
                if character == "\"" { inString = true }
                code.append(character)
                characters = characters.dropFirst()
            }
            return code
        }
    }
}
