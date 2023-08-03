//
//  OutlineTextField.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct OutlineTextField: View {

    // MARK: Properties

    @State private var borderColor = Color.gray
    @State private var borderWidth = 1.0
    @State private var placeholderBackgroundOpacity = 0.0
    @State private var placeholderBottomPadding = 0.0
    @State private var placeholderColor = Color.gray
    @State private var placeholderFontSize = 16.0
    @State private var placeholderLeadingPadding = 2.0

    @Binding private var text: String
    @Binding private var valid: Bool
    @Binding private var editing: Bool
    @Binding private var hint: String

    @FocusState private var focusField: Field?

    private let placeholder: String

    // MARK: - Initialization

    /// Creates a Material Design inspired text field with an animated border and placeholder.
    /// - Parameters:
    ///   - text: The text field contents.
    ///   - placeholder: The placeholder string.
    ///   - hint: The field hint string.
    ///   - editing: Whether the field is in the editing state.
    ///   - valid: Whether the field is in the valid state.
    public init(_ text: Binding<String>,
                placeholder: String,
                hint: Binding<String>,
                editing: Binding<Bool>,
                valid: Binding<Bool>) {
        self._text = text
        self.placeholder = placeholder
        self._hint = hint
        self._editing = editing
        self._valid = valid
    }

    // MARK: - View protocol properties

    public var body: some View {
        ZStack {
            TextField("", text: $text)
                .padding(6.0)
                .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth))
            // TODO: - Handle focusing from CardDetailsView
            //                .focused($focusField, equals: .textField)
            HStack {
                ZStack {
                    Color(.white)
                        .cornerRadius(4.0)
                        .opacity(placeholderBackgroundOpacity)
                    Text(placeholder)
                        .foregroundColor(.white)
                        .colorMultiply(placeholderColor)
                        .animatableFont(size: placeholderFontSize)
                        .padding(2.0)
                        .layoutPriority(1)
                }
                .padding([.leading], placeholderLeadingPadding)
                .padding([.bottom], placeholderBottomPadding)
                Spacer()
            }
            HStack {
                VStack {
                    Spacer()
                    Text(hint)
                        .font(.system(size: 10.0))
                        .foregroundColor(.gray)
                        .padding([.leading], 10.0)
                }
                Spacer()
            }
        }
        .onChange(of: editing) { _ in
            // TODO: - Handle focusing from CardDetailsView
            //            focusField = $0 ? .textField : nil
            withAnimation(.easeInOut(duration: 0.15)) {
                updateBorder()
                updatePlaceholder()
            }
        }
        .frame(height: 64.0)
    }

}

// MARK: - Private methods

private extension OutlineTextField {

    func updateBorder() {
        updateBorderColor()
        updateBorderWidth()
    }

    func updateBorderColor() {
        if !valid {
            borderColor = .red
        } else if editing {
            borderColor = .blue
        } else {
            borderColor = .gray
        }
    }

    func updateBorderWidth() {
        borderWidth = editing ? 2.0 : 1.0
    }

    func updatePlaceholder() {
        updatePlaceholderBackground()
        updatePlaceholderColor()
        updatePlaceholderFontSize()
        updatePlaceholderPosition()
    }

    func updatePlaceholderBackground() {
        if editing || !text.isEmpty {
            placeholderBackgroundOpacity = 1.0
        } else {
            placeholderBackgroundOpacity = 0.0
        }
    }

    func updatePlaceholderColor() {
        if valid {
            placeholderColor = editing ? .blue : .gray
        } else if text.isEmpty {
            placeholderColor = editing ? .red : .gray
        } else {
            placeholderColor = .red
        }
    }

    func updatePlaceholderFontSize() {
        if editing || !text.isEmpty {
            placeholderFontSize = 10.0
        } else {
            placeholderFontSize = 16.0
        }
    }

    func updatePlaceholderPosition() {
        if editing || !text.isEmpty {
            placeholderBottomPadding = 34.0
            placeholderLeadingPadding = 8.0

        } else {
            placeholderBottomPadding = 0.0
            placeholderLeadingPadding = 8.0
        }
    }

    enum Field {
        case textField
    }

}

// MARK: - OutlineTextField_Previews

struct OutlineTextField_Previews: PreviewProvider {

    static var previews: some View {
        OutlineTextField(.constant("Asdf"), placeholder: "Placeholder", hint: .constant("Hint"), editing: .constant(false), valid: .constant(false))
    }

}
