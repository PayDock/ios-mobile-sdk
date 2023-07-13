//
//  Mockable.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

protocol Mockable: AnyObject {

    var bundle: Bundle { get }
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T

}

extension Mockable {

    var bundle: Bundle {
        return Bundle.module
    }

    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }

        do {
            let data = try Data(contentsOf: path)
            let decodedObject = try JSONDecoder().decode(type, from: data)

            return decodedObject

        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }

}
