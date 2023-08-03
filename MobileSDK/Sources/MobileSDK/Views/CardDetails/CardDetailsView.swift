//
//  CardDetailsView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct CardDetailsView: View {

    @State var isPresented = false
    @ObservedObject var viewModel = CardDetailsVM()

    var body: some View {
        VStack {
            OutlineTextField($viewModel.text1, editing: $viewModel.editingTextField1)
                .padding()
                .onTapGesture { viewModel.editingTextField1 = true }

            OutlineTextField($viewModel.text2, editing: $viewModel.editingTextField2)
                .padding()
                .onTapGesture { viewModel.editingTextField2 = true }
            Spacer()
        }
        .onTapGesture {
            viewModel.cancelEditing()
        }
        .frame(width: 300.0, height: 200.0)
        .contentShape(Rectangle())
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView()
            .previewLayout(.sizeThatFits)
    }
}
