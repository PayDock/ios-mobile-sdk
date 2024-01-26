//
//  AutocompleteTextField.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
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
    @Binding private var options: [String]
    @State private var popupOpacity: CGFloat = 0
    @State private var popupScale = 0.7
    private var onSelection: (Int?) -> ()

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
    ///   - showPopup: Whether the autocomplete field is displayed..
    ///   - option: Autocomplete popup list of options.
    ///   - onSelection: Returns selected value
    public init(text: Binding<String>,
                title: String,
                placeholder: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool>,
                showPopup: Binding<Bool>,
                options: Binding<Array<String>>,
                onSelection: @escaping (Int?) -> ()) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid
        self._showPopup = showPopup
        self._options = options
        self.onSelection = onSelection
    }

    var body: some View {
        VStack(alignment: .leading) {
            OutlineTextField(
                text: $text,
                title: title,
                placeholder: placeholder,
                errorMessage: $errorMessage,
                editing: $editing,
                valid: $valid,
                validationIconEnabled: false)
            .overlay(
                autocompletePopup
                    .offset(x: -1, y: 52), alignment: .topLeading
            )
        }
        .frame(height: 48)
    }

    private var autocompletePopup: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                if showPopup && editing {
                    Spacer()
                        .frame(height: 50)
                    VStack(alignment: .center) {
                        if options.isEmpty {
                            Text("No results")
                                .customFont(.body)
                                .foregroundColor(.textColor)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(options, id: \.self) { option in
                                HStack {
                                    Text(option)
                                        .customFont(.body)
                                        .foregroundColor(.textColor)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .onTapGesture {
                                            onSelection(getOptionIndex(option: option))
                                        }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(.primaryLightColor)
                            .shadow(radius: 4)
                    )
                    .opacity(popupOpacity)
                    .scaleEffect(popupScale)
                    .frame(width: proxy.size.width + 2)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.15)) {
                            popupOpacity = 1
                            popupScale = 1
                        }
                    }
                    .onDisappear {
                        popupOpacity = 0
                        popupScale = 0.7
                    }
                }
            }
            .background(Color.backgroundColor)
        }
    }

    private func getOptionIndex(option: String) -> Int? {
        return options.firstIndex { $0 == option }
    }

    enum Field {
        case textField
    }
}

// MARK: - AutocompleteTextField_Previews

struct AutocompleteTextField_Previews: PreviewProvider {

    static var options = ["Australia", "Canada"]
    static var previews: some View {
        AutocompleteTextField(
            text: .constant("Search countries here"),
            title: "Select countries",
            placeholder: "",
            errorMessage: .constant(""),
            editing: .constant(true),
            valid: .constant(true),
            showPopup: .constant(true),
            options: .constant(options), onSelection: {_ in })
    }
}
