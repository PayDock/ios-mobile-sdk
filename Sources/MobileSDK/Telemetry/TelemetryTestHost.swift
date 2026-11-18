//
//  TelemetryTestHost.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// R_14: the Xcode test runner or a hosted unit-test process, which never activates telemetry: a test suite that calls
/// `configureMobileSDK` on sandbox or staging starts no runtime and creates no telemetry directory.
enum TelemetryTestHost {
    /// The bundle identifier of the process that runs unhosted test bundles.
    static let testRunnerBundleIdentifier = "com.apple.dt.xctest.tool"
    /// Set by Xcode in every process it runs tests in, hosted or not.
    static let configurationKey = "XCTestConfigurationFilePath"

    /// True for the test runner's bundle identifier, or when `environment` has `configurationKey`.
    static func isTestProcess(environment: [String: String], bundleIdentifier: String?) -> Bool {
        bundleIdentifier == testRunnerBundleIdentifier || environment[configurationKey] != nil
    }
}
