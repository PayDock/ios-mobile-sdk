//
//  TopRatedModel.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

struct TopRated: Codable {

    let page: Int
    let totalPages: Int
    let totalResults: Int
    let results: [Movie]

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
}
