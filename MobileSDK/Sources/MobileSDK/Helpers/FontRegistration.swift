//
//  FontRegistration.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import UIKit
import CoreGraphics
import CoreText

struct FontRegistration {

    enum FontError: Swift.Error {
        case failedToRegisterFont
    }

    private func registerFont(named name: String) throws {
        guard let asset = NSDataAsset(name: "Fonts/\(name)", bundle: Bundle.module),
              let provider = CGDataProvider(data: asset.data as NSData),
              let font = CGFont(provider),
              CTFontManagerRegisterGraphicsFont(font, nil) else {
            throw FontError.failedToRegisterFont
        }
    }

    func registerAllFonts() {
        do {
            try registerFont(named: "FFF-AcidGrotesk-Light")
            try registerFont(named: "FFF-AcidGrotesk-Medium")
            try registerFont(named: "FFF-AcidGrotesk-Normal")
            try registerFont(named: "FFF-AcidGrotesk-UltraLight")
        } catch {
            print("ERROR: Failed registering fonts!")
        }
    }

}
