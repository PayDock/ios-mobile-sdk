//
//  CardDetailsView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct CardDetailsView: View {

    @State var isPresented = false
    @StateObject private var viewModel = CardDetailsVM()
    @FocusState private var text1InFocus: Bool

    var body: some View {
        VStack {
            OutlineTextField($viewModel.text1, editing: $viewModel.editingTextField1)
                .onTapGesture { viewModel.editingTextField1 = true }
                .focused($text1InFocus)
                .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.text1InFocus = true
                  }
                }

            OutlineTextField($viewModel.text2, editing: $viewModel.editingTextField2)
                .onTapGesture { viewModel.editingTextField2 = true }
            Spacer()
        }
        .onTapGesture {
            viewModel.cancelEditing()
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView()
            .previewLayout(.sizeThatFits)
    }
}
