//
//  Base64Decoder.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.02.2025..
//

import Foundation

struct Base64Decoder {
    
    func decodeBase64<T: Decodable>(_ base64String: String, to type: T.Type) -> T? {
        guard let data = Data(base64Encoded: base64String) else {
            print("Invalid Base64 string")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error:", error)
            return nil
        }
    }
}
