//
//  MetricKitPayload.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Parses one `MXDiagnosticPayload.jsonRepresentation()` (R_12). Reads only `binaryUUID`, `binaryName`,
/// `offsetIntoBinaryTextSegment`, `threadAttributed`, `exceptionType` and `signal`, so free text never enters an event:
/// terminationReason, virtualMemoryRegionInfo and exceptionReason are never read.
package enum MetricKitPayload {
    private static let exceptionNames = [
        "EXC_BAD_ACCESS", "EXC_BAD_INSTRUCTION", "EXC_ARITHMETIC", "EXC_EMULATION", "EXC_SOFTWARE", "EXC_BREAKPOINT",
        "EXC_SYSCALL", "EXC_MACH_SYSCALL", "EXC_RPC_ALERT", "EXC_CRASH", "EXC_RESOURCE", "EXC_GUARD", "EXC_CORPSE_NOTIFY"
    ]
    private static let signalNames = [
        "SIGHUP", "SIGINT", "SIGQUIT", "SIGILL", "SIGTRAP", "SIGABRT", "SIGEMT", "SIGFPE", "SIGKILL", "SIGBUS", "SIGSEGV",
        "SIGSYS", "SIGPIPE", "SIGALRM", "SIGTERM"
    ]

    /// The crash diagnostics, then the hang diagnostics, of one payload's JSON; [] when it doesn't parse. Reads only
    /// the keys listed in § Contracts; a frame missing a key is skipped.
    package static func diagnostics(json: Data, timeEnd: Int64) -> [MetricKitDiagnostic] {
        guard let payload = (try? JSONSerialization.jsonObject(with: json)) as? [String: Any] else {
            return []
        }
        let crashes = objects(payload["crashDiagnostics"]).map { diagnostic -> MetricKitDiagnostic in
            let metaData = diagnostic["diagnosticMetaData"] as? [String: Any]
            return MetricKitDiagnostic(kind: .crash, exceptionType: metaData?["exceptionType"] as? Int,
                                       signal: metaData?["signal"] as? Int, frames: frames(diagnostic), timeEnd: timeEnd)
        }
        let hangs = objects(payload["hangDiagnostics"]).map { diagnostic in
            MetricKitDiagnostic(kind: .hang, exceptionType: nil, signal: nil, frames: frames(diagnostic), timeEnd: timeEnd)
        }
        return crashes + hangs
    }

    /// Mach exception and signal names: 1…13 → EXC_BAD_ACCESS, EXC_BAD_INSTRUCTION, EXC_ARITHMETIC, EXC_EMULATION,
    /// EXC_SOFTWARE, EXC_BREAKPOINT, EXC_SYSCALL, EXC_MACH_SYSCALL, EXC_RPC_ALERT, EXC_CRASH, EXC_RESOURCE, EXC_GUARD,
    /// EXC_CORPSE_NOTIFY, else "EXC_<n>"; signals 1…15 → SIGHUP, SIGINT, SIGQUIT, SIGILL, SIGTRAP, SIGABRT, SIGEMT,
    /// SIGFPE, SIGKILL, SIGBUS, SIGSEGV, SIGSYS, SIGPIPE, SIGALRM, SIGTERM, else "SIG<n>".
    package static func exceptionName(_ type: Int) -> String {
        name(type, in: exceptionNames) ?? "EXC_\(type)"
    }

    package static func signalName(_ signal: Int) -> String {
        name(signal, in: signalNames) ?? "SIG\(signal)"
    }

    /// The name at the 1-based `number`, nil outside the list.
    private static func name(_ number: Int, in names: [String]) -> String? {
        number >= 1 && number <= names.count ? names[number - 1] : nil
    }

    /// The JSON objects of an array value; anything else gives none.
    private static func objects(_ value: Any?) -> [[String: Any]] {
        (value as? [Any] ?? []).compactMap { $0 as? [String: Any] }
    }

    /// The attributed thread's stack, else the first one: its root frame (the innermost), then each frame's first
    /// `subFrames` element (its caller), at most `ErrorInfo.maxFrames` kept.
    private static func frames(_ diagnostic: [String: Any]) -> [DiagnosticFrame] {
        let stacks = objects((diagnostic["callStackTree"] as? [String: Any])?["callStacks"])
        guard let stack = stacks.first(where: { $0["threadAttributed"] as? Bool == true }) ?? stacks.first else {
            return []
        }
        var frames: [DiagnosticFrame] = []
        var next = objects(stack["callStackRootFrames"]).first
        while let node = next, frames.count < TelemetryEvent.ErrorInfo.maxFrames {
            if let frame = frame(node) {
                frames.append(frame)
            }
            next = objects(node["subFrames"]).first
        }
        return frames
    }

    /// Nil when the name, the UUID or a non-negative integer offset is missing.
    private static func frame(_ node: [String: Any]) -> DiagnosticFrame? {
        guard let name = node["binaryName"] as? String, let uuid = node["binaryUUID"] as? String,
              let offset = node["offsetIntoBinaryTextSegment"] as? UInt64 else {
            return nil
        }
        return DiagnosticFrame(binaryName: name, binaryUUID: uuid.uppercased(), offset: offset)
    }
}
