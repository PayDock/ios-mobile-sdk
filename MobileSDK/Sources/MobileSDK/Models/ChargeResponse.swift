//
//  ChargeResponse.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.10.2023..
//

import Foundation

public struct ChargeResponse: Codable {

  public let status: String
  public let amount: Decimal
  public let currency: String

}
