//
//  StandInHostsScanTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation
import XCTest
import PaydockTelemetry

/// R_02, R_12: the example app's trigger view model names exactly `DebugStandInHosts.timeout` and
/// `DebugStandInHosts.refused` as its two override hosts, and the whole file sits inside `#if DEBUG`. A source scan:
/// the app can't import the SDK's package-level type, so it repeats the two addresses as literals.
final class StandInHostsScanTests: XCTestCase {

    static let triggersViewModelPath = "ExampleApp/ExampleApp/Screens/Debug/TelemetryTriggersVM.swift"

    /// Any IPv4 address in a string literal.
    private static let addressLiteral = SourceScan.makeRegex(#""(\d{1,3}(?:\.\d{1,3}){3})""#)

    // MARK: - The example app's view model

    func testTheTriggersViewModel_NamesExactlyTheTwoStandInHosts() throws {
        let text = try Self.triggersViewModelText()

        XCTAssertEqual(Set(Self.addresses(in: text)), [DebugStandInHosts.timeout, DebugStandInHosts.refused],
                       "\(Self.triggersViewModelPath) must override the API host with exactly the two stand-in hosts")
    }

    func testTheTriggersViewModel_IsWhollyInsideIfDebug() throws {
        let text = try Self.triggersViewModelText()

        XCTAssertTrue(Self.isWhollyInsideIfDebug(text),
                      "\(Self.triggersViewModelPath) must open with `#if DEBUG` and close with its `#endif`")
    }

    // MARK: - The scan itself

    func testTheScan_ReadsTheAddressesInOrderOfFirstUse_AndOnlyFromLiterals() {
        let text = """
        let timeout = "10.255.255.1"
        let refused = "127.0.0.1"
        let again = "10.255.255.1"
        let version = "1.2.3"
        """

        XCTAssertEqual(Self.addresses(in: text), ["10.255.255.1", "127.0.0.1"])
    }

    func testTheScan_IfDebugRule() {
        let wrapped = "//\n//  Header\n\n#if DEBUG\nimport Foundation\n#if os(iOS)\nlet value = 1\n#endif\nfinal class A {}\n#endif\n"
        let codeBefore = "import Foundation\n#if DEBUG\nfinal class A {}\n#endif\n"
        let codeAfter = "#if DEBUG\nfinal class A {}\n#endif\nfinal class B {}\n"
        let closedEarly = "#if DEBUG\n#endif\nfinal class A {}\n#if DEBUG\n#endif\n"
        let otherCondition = "#if os(iOS)\nfinal class A {}\n#endif\n"

        XCTAssertTrue(Self.isWhollyInsideIfDebug(wrapped))
        XCTAssertFalse(Self.isWhollyInsideIfDebug(codeBefore))
        XCTAssertFalse(Self.isWhollyInsideIfDebug(codeAfter))
        XCTAssertFalse(Self.isWhollyInsideIfDebug(closedEarly))
        XCTAssertFalse(Self.isWhollyInsideIfDebug(otherCondition))
    }

    // MARK: - Helpers

    /// The view model's source. A missing file fails both scans of it, never passes them.
    private static func triggersViewModelText() throws -> String {
        let url = SourceScan.repoRoot.appendingPathComponent(triggersViewModelPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            XCTFail("\(triggersViewModelPath) does not exist: the example app's telemetry triggers are missing")
            throw CocoaError(.fileNoSuchFile)
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// The distinct IPv4 addresses written as string literals, in order of first use. Comment lines are ignored.
    private static func addresses(in text: String) -> [String] {
        var found: [String] = []
        for line in text.components(separatedBy: .newlines)
        where !line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
            let range = NSRange(line.startIndex..., in: line)
            for match in addressLiteral.matches(in: line, range: range) {
                guard let address = Range(match.range(at: 1), in: line).map({ String(line[$0]) }) else {
                    continue
                }
                if !found.contains(address) {
                    found.append(address)
                }
            }
        }
        return found
    }

    /// True when the first line that is neither blank nor a comment is `#if DEBUG`, and the `#endif` that closes it
    /// is the last such line.
    private static func isWhollyInsideIfDebug(_ text: String) -> Bool {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("//") }
        guard lines.first == "#if DEBUG", lines.last == "#endif" else {
            return false
        }
        var depth = 0
        for (index, line) in lines.enumerated() {
            if line.hasPrefix("#if ") {
                depth += 1
            } else if line == "#endif" || line.hasPrefix("#endif ") {
                depth -= 1
                if depth == 0 {
                    return index == lines.count - 1
                }
            }
        }
        return false
    }
}
#endif
