//
//  Standalone3DSResult.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 25.02.2025..
//

import Foundation

public struct Standalone3DSResult {
  public let event: EventType
  public let charge3dsId: String
  /// Raw authentication status string reported by the web SDK for this event
  /// (e.g. success / pending / rejected / error-style values).
  /// Informational only — do not branch on it instead of ``event``. May be `nil`.
  public let status: String?
  /// Human-readable outcome description (the web SDK's `result.description`) when provided — typically only on
  /// frictionless / first-step outcomes; nil otherwise, including challenge results.
  public let resultDescription: String?

  init(event: EventType, charge3dsId: String, status: String? = nil, resultDescription: String? = nil) {
    self.event = event
    self.charge3dsId = charge3dsId
    self.status = status
    self.resultDescription = resultDescription
  }

  public enum EventType: String {
    case chargeAuthSuccess
    case chargeAuthReject
    case chargeAuthChallenge
    case chargeAuthDecoupled
    case chargeAuthInfo
    case chargeError
  }
}
