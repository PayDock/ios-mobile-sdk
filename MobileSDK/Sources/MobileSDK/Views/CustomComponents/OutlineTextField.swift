//
//  OutlineTextField.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct OutlineTextField: View {

    // MARK: - Properties

    @Binding private var text: String
    @Binding private var editing: Bool
    @FocusState private var focusField: Field?
    @State private var borderColor = Color.gray
    @State private var borderWidth = 1.0

    // MARK: - Initialisation

    init(_ text: Binding<String>, editing: Binding<Bool>) {
      self._text = text
      self._editing = editing
    }

    var body: some View {
        TextField("", text: $text)
            .padding(6.0)
            .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                .stroke(borderColor, lineWidth: borderWidth))
            .focused($focusField, equals: .textField)
            .onChange(of: editing) {
                focusField = $0 ? .textField : nil
                withAnimation(.easeOut(duration: 0.1)) {
                    borderColor = editing ? .blue : .gray
                    borderWidth = editing ? 2.0 : 1.0
                }
            }
    }

    private enum Field {
        case textField
    }

}

struct OutlineTextField_Previews: PreviewProvider {
    static var previews: some View {
        OutlineTextField(.constant("Asdf"), editing: .constant(true))
    }
}
