//
//  Appearance.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 04.09.2023..
//

import Foundation
import SwiftUI



public final class Appearance {
    
    public static let shared = Appearance()
    
    var colors = Colors(
        primary: Color(.primary),
        onPrimary: Color(.onPrimary),
        text: Color(.text),
        success: Color(.success),
        error: Color(.error),
        background: Color(.background),
        border: Color(.border),
        placeholder: Color(.placeholder))

    var dimensions = Dimensions()

    var fontName: String = "FFF-AcidGrotesk-Normal"
}
