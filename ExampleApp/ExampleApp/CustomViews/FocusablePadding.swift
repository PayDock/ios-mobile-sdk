//
//  FocusablePadding.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.07.2023..
//

import SwiftUI

struct FocusablePadding : ViewModifier {

    private let edges: Edge.Set
    private let size: CGFloat?
    @FocusState private var focused: Bool

    init(_ edges: Edge.Set, _ size: CGFloat?) {
        self.edges = edges
        self.size = size
        self.focused = false
    }

    func body(content: Content) -> some View {
        content
            .focused($focused)
            .padding(edges, size)
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
    }

}
