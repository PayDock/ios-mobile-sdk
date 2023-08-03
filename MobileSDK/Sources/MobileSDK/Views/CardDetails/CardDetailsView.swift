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
    @FocusState private var textFieldInFocus: CardDetailsFocusable?
    @State var isPresented = false

    @State private var editingTextField1 = false {
        didSet {
            guard editingTextField1 != oldValue else { return }

            if editingTextField1 {
                editingTextField2 = false
            } else {
                viewModel.validateText1()
            }
        }
    }

    @State private var editingTextField2 = false {
        didSet {
            guard editingTextField2 != oldValue else { return }

            if editingTextField2 {
                editingTextField1 = false
            } else {
                viewModel.validateText2()
            }
        }
    }

    // MARK: - View protocol properties

    var body: some View {
        VStack {
            OutlineTextField(
                $viewModel.text1,
                placeholder: viewModel.placeholder1,
                hint: $viewModel.hint1,
                editing: $editingTextField1,
                valid: $viewModel.text1Valid)
            .focused($textFieldInFocus, equals: .text1)
            .padding(.horizontal, 16)
            .onTapGesture {
                self.textFieldInFocus = .text1
                self.editingTextField1 = true
            }

            OutlineTextField(
                $viewModel.text2,
                placeholder: viewModel.placeholder2,
                hint: $viewModel.hint2,
                editing: $editingTextField2,
                valid: $viewModel.text2Valid)
            .focused($textFieldInFocus, equals: .text2)
            .padding(.horizontal, 16)
            .onTapGesture {
                self.textFieldInFocus = .text2
                self.editingTextField2 = true
            }
            
            Spacer()
        }
        .onTapGesture {
            editingTextField1 = false
            editingTextField2 = false
        }
    }

    enum CardDetailsFocusable: Hashable {
      case text1
      case text2
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView()
            .previewLayout(.sizeThatFits)
    }
}
