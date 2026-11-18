//
//  TelemetryTriggersVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation
import MobileSDK
import NetworkingLib

/// Runs one trigger at a time (R_11). Network triggers call the PayPal data collector with a blank or obviously
/// malformed token and a fake gateway ID, never a real credential, and show only the result's type name. Timeout and
/// offline point `NetworkingLib.shared.host` at a stand-in host for that call and restore the previous value in a
/// `defer` (R_12). `emptyConfigIds`: the names (never values) of the `ProjectEnvironment` IDs that are empty.
@MainActor final class TelemetryTriggersVM: ObservableObject {

    /// The widget a trigger presents in a sheet.
    enum Sheet: String, Identifiable {
        case standalone3ds, applePaySetup

        var id: String { rawValue }
    }

    /// The fake gateway ID every network trigger uses.
    static let fakeGatewayId = "telemetry-test-gateway"
    /// The 5xx trigger's token: obviously malformed, never a real credential.
    static let malformedToken = "telemetry-malformed-token"
    /// Non-routable: the connection times out. Equal to the SDK's `DebugStandInHosts.timeout`.
    static let timeoutHost = "10.255.255.1"
    /// A closed loopback port: the connection is refused. Equal to the SDK's `DebugStandInHosts.refused`.
    static let refusedHost = "127.0.0.1"
    /// How long the hang trigger blocks the main thread.
    static let hangSeconds: TimeInterval = 5

    @Published private(set) var running: TelemetryTrigger?
    @Published private(set) var lastResult: String?
    @Published var sheet: Sheet?

    let emptyConfigIds: [String]

    init(infoDictionary: [String: Any]? = Bundle.main.infoDictionary) {
        emptyConfigIds = Self.emptyConfigIds(in: infoDictionary ?? [:])
    }

    func run(_ trigger: TelemetryTrigger) {
        guard running == nil else {
            return
        }
        switch trigger {
        case .appCrash:
            NSException(name: NSExceptionName("ExampleAppTestCrash"), reason: "test", userInfo: nil).raise()
        case .hang:
            Thread.sleep(forTimeInterval: Self.hangSeconds)
            lastResult = "\(trigger.title): main thread blocked for \(Int(Self.hangSeconds)) s"
        case .sdkError:
            sheet = .standalone3ds
        case .widgetOpened:
            sheet = .applePaySetup
        case .http4xx:
            runNetwork(trigger, accessToken: "", host: nil)
        case .http5xx:
            runNetwork(trigger, accessToken: Self.malformedToken, host: nil)
        case .timeout:
            runNetwork(trigger, accessToken: "", host: Self.timeoutHost)
        case .offline:
            runNetwork(trigger, accessToken: "", host: Self.refusedHost)
        }
    }

    // MARK: - Network triggers

    private func runNetwork(_ trigger: TelemetryTrigger, accessToken: String, host: String?) {
        running = trigger
        lastResult = nil
        Task {
            let outcome = await Self.collect(accessToken: accessToken, host: host)
            lastResult = "\(trigger.title): \(outcome)"
            running = nil
        }
    }

    /// One PayPal data collector initialisation; nil `host` keeps the SDK's API host. Only a type name comes back.
    private static func collect(accessToken: String, host: String?) async -> String {
        let previousHost = NetworkingLib.shared.host
        if let host {
            NetworkingLib.shared.host = host
        }
        defer {
            NetworkingLib.shared.host = previousHost
        }
        let config = PayPalDataCollectorConfig(accessToken: accessToken, gatewayId: fakeGatewayId)
        do {
            let util = try await PayPalDataCollectorUtil.initialise(config: config)
            return String(reflecting: type(of: util))
        } catch {
            return String(reflecting: type(of: error))
        }
    }

    // MARK: - Config IDs

    /// The `ProjectEnvironment` keys this screen reports on, by name.
    static let configIdKeys: [String] = [
        ProjectEnvironment.Keys.apiAccessToken,
        ProjectEnvironment.Keys.widgetAccessToken,
        ProjectEnvironment.Keys.applePayServiceId,
        ProjectEnvironment.Keys.payPalGatewayId,
        ProjectEnvironment.Keys.mpgsGatewayId,
        ProjectEnvironment.Keys.mpgsTestGatewayId,
        ProjectEnvironment.Keys.gpaymentsServiceId,
        ProjectEnvironment.Keys.colesPayGatewayId,
        ProjectEnvironment.Keys.afterpayGatewayId,
        ProjectEnvironment.Keys.clickToPayServiceId,
        ProjectEnvironment.Keys.colesPayClientId,
        ProjectEnvironment.Keys.applePayMerchantId,
        ProjectEnvironment.Keys.zipGatewayId
    ]

    /// The names of the keys whose value is missing or blank. Values are never read out.
    static func emptyConfigIds(in infoDictionary: [String: Any]) -> [String] {
        configIdKeys.filter { key in
            let value = (infoDictionary[key] as? String)?.trimmingCharacters(in: .whitespaces) ?? ""
            return value.isEmpty
        }
    }
}
#endif
