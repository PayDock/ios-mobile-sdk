//
//  BottomSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

public struct BottomSheetView<Content: View>: View {

    @Binding var isPresented: Bool
    @State var selectedDetent: PresentationDetent = .medium
    @ViewBuilder let content: Content

    private let availableDetents: [PresentationDetent] = [.medium, .large]

    public var body: some View {
        Text("")
            .sheet(isPresented: $isPresented) {
                content
                    .presentationDetents([.medium])
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
