//
//  JSONLoader.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 31.01.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

struct JSONLoader {
    
    func loadJSON<T: Decodable>(filename: String?, bundle: Bundle? = Bundle.module, type: T.Type) -> T {
        guard let filename = filename else {
            fatalError("No filename provided for a mock response!")
        }
        guard let path = bundle?.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }

        do {
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedObject = try decoder.decode(type, from: data)

            return decodedObject

        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}
