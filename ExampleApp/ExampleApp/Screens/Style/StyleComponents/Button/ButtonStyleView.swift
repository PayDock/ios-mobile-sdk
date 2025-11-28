//
//  ButtonStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ButtonStyleView<T>: View {

    @StateObject var viewModel: ButtonStyleVM<T>
    let title: String

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool,
         buttonKeyPath: WritableKeyPath<T, Theme.ButtonAppearance>,
         title: String) {
        _viewModel = StateObject(wrappedValue: ButtonStyleVM<T>(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode,
            buttonKeyPath: buttonKeyPath))
        self.title = title
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SectionTitleView(title: "Colors")
                    colorListView
                    SectionTitleView(title: "Dimensions")
                    dimensionsListView
                    SectionTitleView(title: "Fonts")
                    fontListView
                    SectionTitleView(title: "Button Content")
                    iconListView
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .padding(.bottom, 16.0)
                .navigationTitle(title)
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var colorListView: some View {
        VStack(spacing: 16) {
            ColorPickerView(
                title: "Background color",
                text: Binding(
                    get: { viewModel.backgroundColor.toHex() },
                    set: { viewModel.backgroundColor = Color(hex: $0) }),
                pickedColor: $viewModel.backgroundColor)

            ColorPickerView(
                title: "Text color",
                text: Binding(
                    get: { viewModel.textColor.toHex() },
                    set: { viewModel.textColor = Color(hex: $0) }),
                pickedColor: $viewModel.textColor)

            ColorPickerView(
                title: "Image color",
                text: Binding(
                    get: { viewModel.imageColor.toHex() },
                    set: { viewModel.imageColor = Color(hex: $0) }),
                pickedColor: $viewModel.imageColor)

            ColorPickerView(
                title: "Border color",
                text: Binding(
                    get: { viewModel.borderColor.toHex() },
                    set: { viewModel.borderColor = Color(hex: $0) }),
                pickedColor: $viewModel.borderColor)

            ColorPickerView(
                title: "Loader color",
                text: Binding(
                    get: { viewModel.loaderColor.toHex() },
                    set: { viewModel.loaderColor = Color(hex: $0) }),
                pickedColor: $viewModel.loaderColor)
        }
    }

    private var dimensionsListView: some View {
        VStack(spacing: 16) {
            DimensionsFieldView(
                title: "Corner radius",
                text: Binding(
                    get: { "\(viewModel.cornerRadius)" },
                    set: { viewModel.cornerRadius = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Border width",
                text: Binding(
                    get: { "\(viewModel.borderWidth)" },
                    set: { viewModel.borderWidth = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Top padding",
                text: Binding(
                    get: { "\(viewModel.topPadding)" },
                    set: { viewModel.topPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Leading padding",
                text: Binding(
                    get: { "\(viewModel.leadingPadding)" },
                    set: { viewModel.leadingPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Bottom padding",
                text: Binding(
                    get: { "\(viewModel.bottomPadding)" },
                    set: { viewModel.bottomPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Trailing padding",
                text: Binding(
                    get: { "\(viewModel.trailingPadding)" },
                    set: { viewModel.trailingPadding = CGFloat(Double($0) ?? 0) }))
        }
    }

    private var fontListView: some View {
        VStack(spacing: 16) {
            ColorPickerView(
                title: "Underline color",
                text: Binding(
                    get: { viewModel.underlineColor.toHex() },
                    set: { viewModel.underlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.underlineColor)

            ColorPickerView(
                title: "Strikethrough color",
                text: Binding(
                    get: { viewModel.strikethroughColor.toHex() },
                    set: { viewModel.strikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.strikethroughColor)

            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.fontName,
                placeholder: "Select font",
                onSelection: { fontName in
                    viewModel.fontName = fontName
                })

            DimensionsFieldView(
                title: "Font size",
                text: Binding(
                    get: { "\(viewModel.fontSize)" },
                    set: { viewModel.fontSize = CGFloat(Double($0) ?? 0) }))
        }
    }

    private var iconListView: some View {
        VStack(spacing: 16) {
            IconPickerView(
                entries: viewModel.allSystemIconNames,
                selected: $viewModel.icon,
                placeholder: "Select icon",
                onSelection: { icon in
                    viewModel.icon = icon
                })

            DimensionsFieldView(title: "Text",
                                text: Binding(
                                    get: { viewModel.buttonText },
                                    set: { viewModel.buttonText = $0 }))
        }
    }
}

#Preview {
    ButtonStyleView<Theme>(selectedWidget: .all, stylingDarkMode: false, buttonKeyPath: \.actionButton, title: "Title")
}
