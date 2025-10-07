//
//  Integrated3DSData.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSData: Codable {
    let browserDetails: Integrated3DSBrowserDetails

    enum CodingKeys: String, CodingKey {
        case browserDetails = "browser_details"
    }
}
