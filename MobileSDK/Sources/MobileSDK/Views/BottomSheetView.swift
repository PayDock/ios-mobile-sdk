//
//  BottomSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

public struct BottomSheetView<Content: View>: View {

    @ViewBuilder private let content: Content
    @Binding var isPresented: Bool
    @State private var sheetHeight: CGFloat = .zero

    public init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    public var body: some View {
        Text("")
            .sheet(isPresented: $isPresented) {
                VStack {
                    headerView
                    content
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                        .overlay {
                            GeometryReader { geometry in
                                Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                            }
                        }
                        .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                            sheetHeight = newHeight
                        }
                        .presentationDetents([.height(sheetHeight)])
                        .interactiveDismissDisabled(true)
                        .scrollDisabled(true)
                }
            }
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Button {
                isPresented = false
            } label: {
                Image("round-btn", bundle:Bundle.module)
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
