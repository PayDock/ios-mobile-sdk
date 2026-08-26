//
//  ErrorRes+Extensions.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import NetworkingLib

extension ErrorRes {

    public func apiFailureMessage(fallback: String) -> String {
        let message = self.error?.message ?? self.errorSummary?.message
        let trimmed = message?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty == false) ? (trimmed ?? fallback) : fallback
    }

    /// Non-user-facing technical detail for logs, e.g. `"status: 400, code: E123"`. Used by widget
    /// errors' `debugDescription` so integrators can log the API status/code that came back.
    public var technicalDetail: String {
        let code = self.error?.code ?? self.errorSummary?.code ?? "nil"
        return "status: \(status), code: \(code)"
    }
}
