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
  /// How the shopper was authenticated: set only on `chargeAuthSuccess` and `chargeAuthReject`, `nil` on every other
  /// event. Frictionless when no `chargeAuthChallenge` or `chargeAuthDecoupled` came for this `charge3dsId` before it.
  public let authenticationFlow: AuthenticationFlow?

  init(event: EventType, charge3dsId: String, status: String? = nil, resultDescription: String? = nil,
       authenticationFlow: AuthenticationFlow? = nil) {
    self.event = event
    self.charge3dsId = charge3dsId
    self.status = status
    self.resultDescription = resultDescription
    self.authenticationFlow = authenticationFlow
  }

  public enum EventType: String {
    case chargeAuthSuccess
    case chargeAuthReject
    case chargeAuthChallenge
    case chargeAuthDecoupled
    case chargeAuthInfo
    case chargeError
  }

  /// How the shopper was authenticated, on a final result.
  public enum AuthenticationFlow: String {
    /// No challenge and no decoupled authentication: the issuer authenticated the shopper without interaction.
    case frictionless
    /// The shopper completed an interactive challenge (`chargeAuthChallenge`).
    case challenge
    /// The shopper authenticated out of band, e.g. in their banking app (`chargeAuthDecoupled`).
    case decoupled
  }
}
