//
//  MovieModel.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

struct MovieModel: Codable {

    let id: Int
    let originalTitle: String

    enum CodingKeys: String, CodingKey {
        case id
        case originalTitle = "original_title"
    }

}
