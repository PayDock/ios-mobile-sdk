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
}
