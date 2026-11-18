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

    /// Selects and binds at `configureMobileSDK`, in every build. A test process (`TelemetryTestHost.isTestProcess`)
    /// binds the no-op and creates nothing (R_14). Otherwise the credentials come from the environment's collector
    /// (R_01) or, in a debug build of a Paydock app only, the local override (R_03); the level is the override's when an
    /// override exists, with or without an endpoint (R_04), else `.all`. In a debug build with the override, its test
    /// record and test crash flags pass to `bind`.
    @discardableResult
    static func bindTelemetry(
        environment: SDKEnvironment,
        processEnvironment: [String: String] = ProcessInfo.processInfo.environment,
        hostBundleIdentifier: String? = Bundle.main.bundleIdentifier
    ) -> any Telemetry {
        if TelemetryTestHost.isTestProcess(environment: processEnvironment, bundleIdentifier: hostBundleIdentifier) {
            return bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        }
        let createActive: (TelemetryCredentials, TelemetryLevel) -> ActiveTelemetry = {
            ActiveTelemetry.create(credentials: $0, level: $1, sdkVersion: SDKVersion.current,
                                   environmentName: environment.rawValue)
        }
        #if DEBUG
        let override = LocalTelemetryOverride.read(environment: processEnvironment,
                                                   hostBundleIdentifier: hostBundleIdentifier)
        let selection = selectTelemetry(
            credentialsProvider: SdkTelemetryCredentialsProvider(environment: environment, override: override),
            level: level(for: override),
            createActive: createActive
        )
        return bind(selection, sendTestRecord: override?.sendTestRecord ?? false,
                    raiseTestCrash: override?.raiseTestCrash ?? false)
        #else
        let selection = selectTelemetry(
            credentialsProvider: SdkTelemetryCredentialsProvider(environment: environment),
            level: .all,
            createActive: createActive
        )
        return bind(selection)
        #endif
    }

    #if DEBUG
    /// The override's level when an override exists (a Paydock debug app), with or without an endpoint; else `.all`.
    static func level(for override: LocalTelemetryOverride?) -> TelemetryLevel {
        override?.level ?? .all
    }

    /// Makes `selection.telemetry` the facade, then calls `selection.runtime.start()` once if it is active, and after
    /// it the runtime's debug hooks: `sendTestRecord()` when active and `sendTestRecord` is set (R_16), then
    /// `raiseTestCrash()` when active and `raiseTestCrash` is set (R_13). While an active facade is bound, another
    /// active selection is ignored and the bound facade returned: one runtime owns the store's directory for the
    /// process, so a second `configureMobileSDK` never starts a second one sending the same files.
    @discardableResult
    static func bind(_ selection: TelemetrySelection, sendTestRecord: Bool = false, raiseTestCrash: Bool = false) -> any Telemetry {
        let outcome = install(selection)
        if let kept = outcome.kept {
            return kept
        }
        if outcome.started {
            let hooks = selection.runtime as? any TelemetryDebugHooks
            if sendTestRecord {
                hooks?.sendTestRecord()
            }
            if raiseTestCrash {
                hooks?.raiseTestCrash()
            }
        }
        return selection.telemetry
    }
    #else
    /// Makes `selection.telemetry` the facade, then calls `selection.runtime.start()` once if it is active. While an
    /// active facade is bound, another active selection is ignored and the bound facade returned: one runtime owns the
    /// store's directory for the process, so a second `configureMobileSDK` never starts a second one sending the same
    /// files.
    @discardableResult
    static func bind(_ selection: TelemetrySelection) -> any Telemetry {
        install(selection).kept ?? selection.telemetry
    }
    #endif

    /// Binds `selection` unless an active facade is bound and `selection` is active too, and then starts the runtime
    /// when it is active. `kept` is the bound facade when the selection was ignored.
    private static func install(_ selection: TelemetrySelection) -> (kept: (any Telemetry)?, started: Bool) {
        let kept: (any Telemetry)? = lock.withLock {
            if selection.telemetry.isActive, bound.isActive {
                return bound
            }
            bound = selection.telemetry
            return nil
        }
        if let kept {
            return (kept, false)
        }
        if selection.telemetry.isActive {
            selection.runtime.start()
            return (nil, true)
        }
        return (nil, false)
    }

    private static let lock = NSLock()
    private static var bound: any Telemetry = NoOpTelemetry()
}

extension MobileSDK {
    /// The telemetry facade for SDK code (RS-4).
    var telemetry: any Telemetry { TelemetryBinding.current }
}

/// The decision with every input injectable, in every build: one `ActiveTelemetry` as both handles when
/// `TelemetryActivation.isActive(credentials:level:)`, else `NoOpTelemetry()`. `createActive` is called only when
/// active, so nothing is created or written while inactive.
func selectTelemetry(
    credentialsProvider: any TelemetryCredentialsProvider,
    level: TelemetryLevel,
    createActive: (TelemetryCredentials, TelemetryLevel) -> ActiveTelemetry
) -> TelemetrySelection {
    let credentials = credentialsProvider.credentials()
    guard TelemetryActivation.isActive(credentials: credentials, level: level), let credentials else {
        return TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry())
    }
    let active = createActive(credentials, level)
    return TelemetrySelection(telemetry: active, runtime: active)
}
