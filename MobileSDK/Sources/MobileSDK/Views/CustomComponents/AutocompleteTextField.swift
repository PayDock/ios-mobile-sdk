//
//  AutocompleteTextField.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

struct AutocompleteTextField: View {

    // MARK: - OutlineTextField Properties

    @Binding private var text: String
    @Binding private var valid: Bool
    @Binding private var leftImage: Image?
    @Binding private var editing: Bool
    @Binding private var errorMessage: String
    private let title: String
    private let placeholder: String

    // MARK: - AutocompleteTextField Properties

    @Binding private var showPopup: Bool
    @State private var options: [String]
    @State private var popupOpacity: CGFloat = 0
    @State private var popupScale = 0.7

    @FocusState private var focusField: Field?

    // MARK: - Initialization

    /// Creates a Material Design inspired text field with  an animated border, title and autocomplete popup menu.
    /// - Parameters:
    ///   - text: The text field contents.
    ///   - title: The title string.
    ///   - placeholder: Placeholder that appears when field is active.
    ///   - errorMessage: The field error message string.
    ///   - editing: Whether the field is in the editing state.
    ///   - valid: Whether the field is in the valid state.
    public init(text: Binding<String>,
                title: String,
                placeholder: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool>,
                showPopup: Binding<Bool>,
                options: Array<String>) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid
        self._showPopup = showPopup
        self.options = options
    }

    var body: some View {
        VStack(alignment: .leading) {
            OutlineTextField(
                text: $text,
                title: title,
                placeholder: placeholder,
                errorMessage: $errorMessage,
                editing: $editing,
                valid: $valid)
            .overlay(
                autocompletePopup
                    .offset(y: 64), alignment: .topLeading
            )
        }
        .padding([.top, .leading, .trailing], 8)
        .frame(height: 48)
    }

    private var autocompletePopup: some View {
        ZStack {
            if showPopup {
                Spacer()
                    .frame(height: 50)
                VStack(alignment: .center) {
                    ForEach(options, id: \.self) {
                        Text($0)
                            .frame(maxWidth: .infinity)
                            .padding(4)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                )
                .opacity(popupOpacity)
                .scaleEffect(popupScale)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.15)) {
                        popupOpacity = 1
                        popupScale = 1
                    }
                }
            }

        }

    }

    enum Field {
        case textField
    }
}

// MARK: - AutocompleteTextField_Previews

struct AutocompleteTextField_Previews: PreviewProvider {

    static var options = ["Afghanistan","America"]
    static var previews: some View {
        AutocompleteTextField(
            text: .constant("Search countries here"),
            title: "Select countries",
            placeholder: "",
            errorMessage: .constant(""),
            editing: .constant(true),
            valid: .constant(true),
            showPopup: .constant(true),
            options: options)
    }

}
