//
//  Padding.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 06.05.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct Padding {

    public var top: CGFloat
    public var leading: CGFloat
    public var bottom: CGFloat
    public var trailing: CGFloat

    public init(top: CGFloat = 0,
                leading: CGFloat = 0,
                bottom: CGFloat = 0,
                trailing: CGFloat = 0) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}
