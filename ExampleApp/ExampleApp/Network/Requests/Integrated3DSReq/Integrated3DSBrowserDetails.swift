//
//  Integrated3DSBrowserDetails.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSBrowserDetails: Codable {

    let colorDepth = "24"
    let javaEnabled = "true"
    let language = "en-US"
    let name = "chrome"
    let screenHeight = "640"
    let screenWidth = "480"
    let timeZone = "273"

    enum CodingKeys: String, CodingKey {
        case colorDepth = "color_depth"
        case javaEnabled = "java_enabled"
        case language = "language"
        case name = "name"
        case screenHeight = "screen_height"
        case screenWidth = "screen_width"
        case timeZone = "time_zone"

    }
}
