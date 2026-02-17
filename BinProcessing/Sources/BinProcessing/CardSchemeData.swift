//
//  CardSchemeData.swift
//  BinProcessing
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Decodable model for card-schemes.json (BIN lookup: prefix tables and scheme code mapping).
struct CardSchemeData: Decodable {
    /// 2-digit prefix -> scheme code (e.g. "41" -> "v")
    let prefix2: [String: String]?
    /// 4-digit prefix -> scheme code
    let prefix4: [String: String]?
    /// 6-digit prefix -> scheme code
    let prefix6: [String: String]?
    /// 8-digit prefix -> scheme code
    let prefix8: [String: String]?
    /// Scheme code -> scheme name (e.g. "v" -> "visa")
    let schemeNames: [String: String]
    /// Ranges by length: "2", "4", "6", "8" -> [[start, end, schemeCode]]
    let ranges: [String: [[String]]]

    enum CodingKeys: String, CodingKey {
        case prefix2 = "2"
        case prefix4 = "4"
        case prefix6 = "6"
        case prefix8 = "8"
        case schemeNames = "s"
        case ranges = "r"
    }
}
