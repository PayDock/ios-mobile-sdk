//
//  Appearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.09.2023..
//

import Foundation

/// An object containing visual configuration for whole application.
struct Appearance {
    /// A color pallete to provide basic set of colors for the Views.
    ///
    /// By providing different object or changing individual colors, you can change the look of the views.
    var lightThemeColors = Theme.Colors()

    var darkThemeColors = Theme.Colors()

    /// A set of fonts to be used in the Views.
    ///
    /// By providing different object or changing individual fonts, you can change the look of the views.
    //    public var fonts = Fonts()

    /// A set of images to be used.
    ///
    /// By providing different object or changing individual images, you can change the look of the views.
    //    public var images = Images()
}

// MARK: - Appearance + Default

extension Appearance {
    static var shared: Appearance = .init()
}
