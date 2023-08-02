//
//  InnerHeightPreferenceKey.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 02.08.2023..
//

import SwiftUI

struct InnerHeightPreferenceKey: PreferenceKey {

    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }

}
