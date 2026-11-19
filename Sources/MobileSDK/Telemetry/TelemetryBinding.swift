//
//  TelemetryBinding.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PaydockTelemetry

/// What the binding chose. SDK code only ever receives `telemetry`; `runtime` stays in this file.
struct TelemetrySelection {
    let telemetry: any Telemetry
    let runtime: any TelemetryRuntime
}

/// The one binding at SDK start (RS-4).
enum TelemetryBinding {
    /// The facade SDK code reads: `NoOpTelemetry` until `bind`.
    static var current: any Telemetry { lock.withLock { bound } }

    /// Selects and binds at `configureMobileSDK`, one path in every build, debug and release. A test process
    /// (`TelemetryTestHost.isTestProcess`) binds the no-op and creates nothing (R_14). Otherwise the environment's
    /// collector (`TelemetryCollector.logsURL(for:)`, R_01) is the only input: no build reads a local value, and no
    /// request carries a key (R_02, R_05).
    @discardableResult
    static func bindTelemetry(
        environment: SDKEnvironment,
        processEnvironment: [String: String] = ProcessInfo.processInfo.environment,
        hostBundleIdentifier: String? = Bundle.main.bundleIdentifier
    ) -> any Telemetry {
        if TelemetryTestHost.isTestProcess(environment: processEnvironment, bundleIdentifier: hostBundleIdentifier) {
            return bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        }
        let selection = selectTelemetry(
            endpoint: TelemetryCollector.logsURL(for: environment),
            createActive: {
                ActiveTelemetry.create(endpoint: $0, sdkVersion: SDKVersion.current, environmentName: environment.rawValue)
            }
        )
        return bind(selection)
    }

    /// Makes `selection.telemetry` the facade, then calls `selection.runtime.start()` once if it is active. While an
    /// active facade is bound, another active selection is ignored and the bound facade returned: one runtime owns the
    /// store's directory for the process, so a second `configureMobileSDK` never starts a second one sending the same
    /// files.
    @discardableResult
    static func bind(_ selection: TelemetrySelection) -> any Telemetry {
        install(selection) ?? selection.telemetry
    }

    /// Binds `selection` unless an active facade is bound and `selection` is active too, and then starts the runtime
    /// when it is active. Returns the bound facade when the selection was ignored, else nil.
    private static func install(_ selection: TelemetrySelection) -> (any Telemetry)? {
        let kept: (any Telemetry)? = lock.withLock {
            if selection.telemetry.isActive, bound.isActive {
                return bound
            }
            bound = selection.telemetry
            return nil
        }
        if let kept {
            return kept
        }
        if selection.telemetry.isActive {
            selection.runtime.start()
        }
        return nil
    }

    private static let lock = NSLock()
    private static var bound: any Telemetry = NoOpTelemetry()
}

extension MobileSDK {
    /// The telemetry facade for SDK code (RS-4).
    var telemetry: any Telemetry { TelemetryBinding.current }
}

/// The decision with every input injectable, in every build: one `ActiveTelemetry` as both handles when
/// `TelemetryActivation.isActive(endpoint:)`, else `NoOpTelemetry()`. `createActive` is called only when active, with
/// the endpoint, so nothing is created or written while inactive.
func selectTelemetry(endpoint: String?, createActive: (String) -> ActiveTelemetry) -> TelemetrySelection {
    guard TelemetryActivation.isActive(endpoint: endpoint), let endpoint else {
        return TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry())
    }
    let active = createActive(endpoint)
    return TelemetrySelection(telemetry: active, runtime: active)
}
