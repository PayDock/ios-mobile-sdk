//
//  ApplePlatformInfo.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// Reads the OS version, the model identifier and the host app's bundle. Only random IDs and these platform values:
/// never a hardware, vendor or advertising identifier, never the device name (principle 10). Reads on access, so
/// creating one reads nothing.
package struct ApplePlatformInfo: PlatformInfo {
    package init() {}

    /// `"<major>.<minor>"`, plus `".<patch>"` when the patch is not 0.
    package var osVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let majorMinor = "\(version.majorVersion).\(version.minorVersion)"
        return version.patchVersion == 0 ? majorMinor : "\(majorMinor).\(version.patchVersion)"
    }

    /// The simulated model on a simulator, else the `machine` field of `uname`, e.g. `iPhone15,2`.
    package var modelIdentifier: String {
        #if targetEnvironment(simulator)
        if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"], !simulated.isEmpty {
            return simulated
        }
        #endif
        var systemInfo = utsname()
        guard uname(&systemInfo) == 0 else {
            return ""
        }
        return withUnsafePointer(to: &systemInfo.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: pointer.pointee)) {
                String(cString: $0)
            }
        }
    }

    package var appId: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    package var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    /// True: this type exists only in debug builds of the SDK, which a host compiles in its own debug configuration.
    package var appDebuggable: Bool {
        true
    }
}
#endif
