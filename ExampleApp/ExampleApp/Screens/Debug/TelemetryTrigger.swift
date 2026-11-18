//
//  TelemetryTrigger.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation

/// The trigger catalogue (R_11): each case's title, what it records, and a manual note where it has one.
/// Debug builds only: a release build holds no trigger.
enum TelemetryTrigger: CaseIterable {
    case appCrash, hang, sdkError, widgetOpened, http4xx, http5xx, timeout, offline

    var title: String {
        switch self {
        case .appCrash: return "App crash"
        case .hang: return "Hang"
        case .sdkError: return "SDK error"
        case .widgetOpened: return "Widget opened"
        case .http4xx: return "HTTP 4xx"
        case .http5xx: return "HTTP 5xx"
        case .timeout: return "Timeout"
        case .offline: return "Offline"
        }
    }

    /// What the trigger records, by event name.
    var records: String {
        switch self {
        case .appCrash:
            return "paydock.crash, kind exception: ExampleAppTestCrash from app code, in_sdk false"
        case .hang:
            return "paydock.crash, kind hang: a MetricKit hang diagnostic"
        case .sdkError:
            return "paydock.error: the standalone 3DS widget's invalid token"
        case .widgetOpened:
            return "paydock.widget.opened: the Apple Pay set-up widget"
        case .http4xx:
            return "paydock.network.failure: GET /v1/gateways/{id}/wallet-config, a 4xx status"
        case .http5xx:
            return "paydock.network.failure: GET /v1/gateways/{id}/wallet-config, a 5xx status"
        case .timeout:
            return "paydock.network.failure: error_type timeout, attempts 1 and 2"
        case .offline:
            return "paydock.network.failure: a connection failure, attempts 1 and 2"
        }
    }

    /// A manual step or caveat, where the trigger has one.
    var note: String? {
        switch self {
        case .appCrash:
            return "Ends the process; the record is sent on the next launch."
        case .hang:
            return "Blocks the main thread for 5 s. A hang reaches MetricKit only on a device, about a day later."
        case .sdkError, .widgetOpened:
            return "Opens the widget in a sheet; close it to return."
        case .http4xx, .http5xx:
            return "Calls the PayPal data collector with a blank or malformed token and a fake gateway ID."
        case .timeout:
            return "Points the SDK at a non-routable host for this call; the call is retried once, about 2 minutes."
        case .offline:
            return "Points the SDK at a closed loopback port for this call; the call is retried once."
        }
    }
}
#endif
