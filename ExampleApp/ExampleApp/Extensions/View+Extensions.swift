//
//  View+Extensions.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 19.07.2023..
//

import SwiftUI

extension View {

    func focusablePadding(_ edges: Edge.Set = .all, _ size: CGFloat? = nil) -> some View {
        modifier(FocusablePadding(edges, size))
    }

}
