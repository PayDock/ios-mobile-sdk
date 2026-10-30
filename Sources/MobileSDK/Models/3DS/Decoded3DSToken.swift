//
//  Decoded3DSToken.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.02.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

struct Decoded3DSToken: Codable {

    let content: String
    let format: ThreeDsFormat
    let charge3dsId: String?

    enum ThreeDsFormat: String, Codable {
        case html // Used in Integrated3DS token
        case url // Used in Integrated3DS token
        case standalone3ds = "standalone_3ds" // Used in Standalone3DS token
    }

    enum CodingKeys: String, CodingKey {
        case content
        case format
        case charge3dsId = "charge_3ds_id"
    }
}

extension Decoded3DSToken {

    /// The 3DS charge ID: the token's own `charge_3ds_id` (Integrated 3DS) or, for Standalone 3DS tokens, the
    /// `charge_3ds_id` inside the `meta` claim of the JWT in `content`. `nil` when neither can be read.
    /// Not verified — only used to label errors.
    var resolvedCharge3dsId: String? {
        if let charge3dsId { return charge3dsId }
        let parts = content.split(separator: ".")
        guard parts.count >= 2,
              let claims = Self.jsonObject(base64URL: String(parts[1])),
              let meta = claims["meta"] as? String,
              let metaClaims = Self.jsonObject(base64URL: meta) else {
            return nil
        }
        return metaClaims["charge_3ds_id"] as? String
    }

    private static func jsonObject(base64URL: String) -> [String: Any]? {
        var base64 = base64URL.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
