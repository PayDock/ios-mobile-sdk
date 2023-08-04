//
//  CardDetailsView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct CardDetailsView: View {

    // MARK: - Properties

    @StateObject private var viewModel = CardDetailsVM()
    @FocusState private var textFieldInFocus: CardDetailsVM.CardDetailsFocusable?
    @State var isPresented = false

    // MARK: - View protocol properties

    var body: some View {
        VStack {
            OutlineTextField(
                $viewModel.text1,
                placeholder: viewModel.placeholder1,
                hint: $viewModel.hint1,
                editing: $viewModel.editingTextField1,
                valid: $viewModel.text1Valid)
            .focused($textFieldInFocus, equals: .text1)
            .padding(.horizontal, 16)
            .onTapGesture {
                self.textFieldInFocus = .text1
                viewModel.setEditingTextField(focusedField: .text1)
            }

            OutlineTextField(
                $viewModel.text2,
                placeholder: viewModel.placeholder2,
                hint: $viewModel.hint2,
                editing: $viewModel.editingTextField2,
                valid: $viewModel.text2Valid)
            .focused($textFieldInFocus, equals: .text2)
            .padding(.horizontal, 16)
            .onTapGesture {
                self.textFieldInFocus = .text2
                viewModel.setEditingTextField(focusedField: .text2)
            }
            
            Spacer()
        }
    }


}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView()
            .previewLayout(.sizeThatFits)
    }
}
