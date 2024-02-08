//
//  BottomSheetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 26.12.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {

    @ViewBuilder private let content: Content
    @Binding var isPresented: Bool
    @State private var sheetHeight: CGFloat = .zero

    public init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        Text("")
            .sheet(isPresented: $isPresented) {
                VStack {
                    headerView
                    content
                        .padding(.top, 20)
                        .overlay {
                            GeometryReader { geometry in
                                Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                            }
                        }
                        .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                            sheetHeight = newHeight + 80
                        }
                        .presentationDetents([.height(sheetHeight)])
                        .interactiveDismissDisabled(false)
                        .scrollDisabled(false)
                    Spacer()
                }
                .background(.white)
            }
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Button {
                isPresented = false
            } label: {
                Image("round-btn")
                    .foregroundColor(.black)
            }
            .padding(.top, 60)
            .padding(.trailing, 16)
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {

    static var previews: some View {
        BottomSheetView(isPresented: .constant(true)) {
            Text("Bottom sheet content")
        }
    }

}
