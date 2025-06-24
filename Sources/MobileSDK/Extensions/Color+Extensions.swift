//
//  Color+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import Foundation
import SwiftUI

public extension Color {
    static var defaultPrimary: Color { Color(.primary) }
    static var defaultOnPrimary: Color { Color(.onPrimary) }
    static var defaultText: Color { Color(.text) }
    static var defaultSuccess: Color { Color(.success) }
    static var defaultError: Color { Color(.error) }
    static var defaultBackground: Color { Color(.background) }
    static var defaultBorder: Color { Color(.border) }
    static var defaultPlaceholder: Color { Color(.placeholder) }
    static var defaultLoaderOverlay: Color { .black.opacity(0.3)}
}
