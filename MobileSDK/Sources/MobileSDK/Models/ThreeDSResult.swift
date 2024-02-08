//
//  ThreeDSResult.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 06.12.2023..
//

import Foundation

public struct ThreeDSResult {
  public let event: EventType
  public let charge3dsId: String

  public enum EventType: String {
    case chargeAuthSuccess
    case chargeAuthReject
    case chargeAuthChallenge
    case chargeAuthDecoupled
    case chargeAuthInfo
    case error
  }
}
