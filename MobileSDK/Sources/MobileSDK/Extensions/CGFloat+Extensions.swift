//
//  CGFloat+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.09.2023..
//

import Foundation

extension CGFloat {

    static var buttonCornerRadius: CGFloat { Appearance.shared.dimensions.buttonCornerRadius }
    static var textFieldCornerRadius: CGFloat { Appearance.shared.dimensions.textFieldCornerRadius }
    static var borderWidth: CGFloat { Appearance.shared.dimensions.borderWidth }
    static var spacing: CGFloat { Appearance.shared.dimensions.spacing }

}
