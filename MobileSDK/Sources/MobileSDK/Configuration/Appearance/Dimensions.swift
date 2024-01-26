//
//  Dimensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.09.2023..
//

import Foundation

public struct Dimensions {

    public let cornerRadius: Double
    public let borderWidth: Double
    public let spacing: CGFloat

    public init(cornerRadius: Double = 4,
                borderWidth: Double = 1,
                spacing: CGFloat = 16) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.spacing = spacing
    }
    
}
