//
//  TextStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 13.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import MobileSDK

struct TextStyleView<T>: View {

    @StateObject var viewModel: TextStyleVM<T>
    let title: String
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool,
         textKeyPath: WritableKeyPath<T, Theme.TextAppearance>,
         title: String) {
        _viewModel = StateObject(wrappedValue: TextStyleVM<T>(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode,
            textKeyPath: textKeyPath))
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
                    ResetStyleButton() {
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
                title: "Text color",
                text: Binding(
                    get: { viewModel.textColor.toHex() },
                    set: { viewModel.textColor = Color(hex: $0) }),
                pickedColor: $viewModel.textColor)

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
        }
    }
    
    private var dimensionsListView: some View {
        VStack (spacing: 16) {
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
        VStack (spacing: 16) {
            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.fontName,
                placeholder: "Select Font",
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
}
