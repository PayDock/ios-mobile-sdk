//
//  InnerHeightPreferenceKey.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.08.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct InnerHeightPreferenceKey: PreferenceKey {

    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }

}
