//
//  MetricKitFixtures.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// The synthetic MetricKit diagnostic payloads under `Fixtures/metrickit/` (never a real device's), and payloads built
/// in code for the shapes a file would only repeat.
enum MetricKitFixtures {
    /// Stands for free text in `free-text.json`; a test puts its sensitive text there at run time.
    static let freeTextPlaceholder = "{{FREE_TEXT}}"

    /// `Fixtures/metrickit/<name>.json`, with each placeholder replaced by `freeText` when one is given.
    static func data(_ name: String, freeText: String? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> Data {
        let folder = try XCTUnwrap(Bundle.module.url(forResource: "Fixtures", withExtension: nil), file: file, line: line)
            .appendingPathComponent("metrickit", isDirectory: true)
        let data = try Data(contentsOf: folder.appendingPathComponent("\(name).json"))
        guard let freeText else {
            return data
        }
        let text = try XCTUnwrap(String(data: data, encoding: .utf8), file: file, line: line)
        return Data(text.replacingOccurrences(of: freeTextPlaceholder, with: freeText).utf8)
    }

    /// One attributed crash whose call stack is the given frames, the first the innermost, each the next one's
    /// caller through `subFrames`.
    static func crash(frames: [[String: Any]], exceptionType: Int = 1, signal: Int = 11) throws -> Data {
        var chain: [String: Any]?
        for frame in frames.reversed() {
            var node = frame
            if let caller = chain {
                node["subFrames"] = [caller]
            }
            chain = node
        }
        let stack: [String: Any] = ["threadAttributed": true, "callStackRootFrames": chain.map { [$0] } ?? []]
        let payload: [String: Any] = ["crashDiagnostics": [[
            "callStackTree": ["callStackPerThread": true, "callStacks": [stack]],
            "diagnosticMetaData": ["exceptionType": exceptionType, "signal": signal]
        ]]]
        return try JSONSerialization.data(withJSONObject: payload)
    }

    /// A frame of the payload's form.
    static func frame(_ name: String, uuid: String, offset: UInt64) -> [String: Any] {
        ["binaryName": name, "binaryUUID": uuid, "offsetIntoBinaryTextSegment": offset, "address": 4_294_967_296 + offset,
         "sampleCount": 1]
    }
}
