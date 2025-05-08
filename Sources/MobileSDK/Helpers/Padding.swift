//
//  Padding.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 06.05.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct Padding {
    
    public let top: CGFloat
    public let leading: CGFloat
    public let bottom: CGFloat
    public let trailing: CGFloat
    
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
