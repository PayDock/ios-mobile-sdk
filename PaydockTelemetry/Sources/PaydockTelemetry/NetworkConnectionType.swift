//
//  NetworkConnectionType.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// `network.connection.type` when the record is built.
package enum NetworkConnectionType: String, Sendable, Equatable { case wifi, cell, none, unknown }
