//
//  CGFloat+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.09.2023..
//

import Foundation

extension CGFloat {

    static var cornerRadius: CGFloat { Appearance.shared.dimensions.cornerRadius }
    static var borderWidth: CGFloat { Appearance.shared.dimensions.borderWidth }
    static var spacing: CGFloat { Appearance.shared.dimensions.spacing }

}
