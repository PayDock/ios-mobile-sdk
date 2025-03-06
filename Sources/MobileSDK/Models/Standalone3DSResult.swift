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

  public enum EventType: String {
    case chargeAuthSuccess
    case chargeAuthReject
    case chargeAuthChallenge
    case chargeAuthDecoupled
    case chargeAuthInfo
    case chargeError
  }
}
