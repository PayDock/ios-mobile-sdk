//
//  Appearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.09.2023..
//

import Foundation
import SwiftUI

/// An object containing visual configuration for whole SDK.
struct Appearance {
    /// A color pallete to provide basic set of colors for the Views.
    ///
    /// By providing different object or changing individual colors, you can change the look of the views.
    var lightThemeColors = Colors()

    var darkThemeColors = Colors()

    var dimensions = Dimensions()

    /// A set of fonts to be used in the Views.
    ///
    /// By providing different object or changing individual fonts, you can change the look of the views.
    var font: UIFont = .systemFont(ofSize: 14)

    /// A set of images to be used.
    ///
    /// By providing different object or changing individual images, you can change the look of the views.
    //    public var images = Images()
}

// MARK: - Appearance + shared

extension Appearance {
    static var shared: Appearance = .init()
}
