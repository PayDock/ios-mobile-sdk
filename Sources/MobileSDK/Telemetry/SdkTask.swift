//
//  SdkTask.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// R_04: SDK work in a `Task` on the main actor, as every SDK site runs today; an error it throws is reported as
/// uncaught. Nothing awaits the task.
enum SdkTask {
    @discardableResult
    static func run(widget: SdkWidget?,
                    _ operation: @escaping @Sendable @MainActor () async throws -> Void) -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try await operation()
            } catch {
                SdkTelemetry.reportUncaught(error, widget: widget)
            }
        }
    }
}
