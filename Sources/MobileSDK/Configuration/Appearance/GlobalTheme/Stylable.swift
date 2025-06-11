//
//  Stylable.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.06.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public protocol LoaderStylableAppearance {
    var loader: Theme.OverlayLoaderAppearance { get set }
}

public protocol ToggleStylableAppearance {
    var toggle: Theme.ToggleAppearance { get set }
}
