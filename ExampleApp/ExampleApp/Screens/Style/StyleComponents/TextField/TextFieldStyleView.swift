//
//  TextFieldStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 11.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct TextFieldStyleView: View {

    @StateObject var viewModel: TextFieldStyleVM
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: TextFieldStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
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
                    SectionTitleView(title: "Padding")
                    paddingListView
                    SectionTitleView(title: "Fonts")
                    fontListView
                }
                .padding(.bottom, 16.0)
                .navigationTitle("Text Field")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
    }

    private var colorListView: some View {
        VStack (spacing: 16) {
            ColorPickerView(
                title: "Active color",
                text: Binding(
                    get: { viewModel.activeColor.toHex() },
                    set: { viewModel.activeColor = Color(hex: $0) }),
                pickedColor: $viewModel.activeColor)
            
            ColorPickerView(
                title: "Inactive color",
                text: Binding(
                    get: { viewModel.inactiveColor.toHex() },
                    set: { viewModel.inactiveColor = Color(hex: $0) }),
                pickedColor: $viewModel.inactiveColor)
            
            ColorPickerView(
                title: "Error color",
                text: Binding(
                    get: { viewModel.errorColor.toHex() },
                    set: { viewModel.errorColor = Color(hex: $0) }),
                pickedColor: $viewModel.errorColor)
            
            ColorPickerView(
                title: "Success color",
                text: Binding(
                    get: { viewModel.successColor.toHex() },
                    set: { viewModel.successColor = Color(hex: $0) }),
                pickedColor: $viewModel.successColor)
            
            ColorPickerView(
                title: "Text color",
                text: Binding(
                    get: { viewModel.textColor.toHex() },
                    set: { viewModel.textColor = Color(hex: $0) }),
                pickedColor: $viewModel.textColor)
            
            ColorPickerView(
                title: "Placeholder color",
                text: Binding(
                    get: { viewModel.placeholderColor.toHex() },
                    set: { viewModel.placeholderColor = Color(hex: $0) }),
                pickedColor: $viewModel.placeholderColor)
            
            ColorPickerView(
                title: "Background color",
                text: Binding(
                    get: { viewModel.backgroundColor.toHex() },
                    set: { viewModel.backgroundColor = Color(hex: $0) }),
                pickedColor: $viewModel.backgroundColor)
        }
    }
    
    private var dimensionsListView: some View {
        VStack {
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
                title: "Active border width",
                text: Binding(
                    get: { "\(viewModel.activeBorderWidth)" },
                    set: { viewModel.activeBorderWidth = CGFloat(Double($0) ?? 0) }))
        }
    }
    
    private var paddingListView: some View {
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
                selected: viewModel.textFont,
                placeholder: "Text font",
                onSelection: { fontName in
                    viewModel.textFont = fontName
                })
            
            PickerView(
                entries: viewModel.allFontNames,
                selected: viewModel.titleFont,
                placeholder: "Title font",
                onSelection: { fontName in
                    viewModel.titleFont = fontName
                })
            
            PickerView(
                entries: viewModel.allFontNames,
                selected: viewModel.placeholderFont,
                placeholder: "Placeholder font",
                onSelection: { fontName in
                    viewModel.placeholderFont = fontName
                })
            
            PickerView(
                entries: viewModel.allFontNames,
                selected: viewModel.errorFont,
                placeholder: "Error font",
                onSelection: { fontName in
                    viewModel.errorFont = fontName
                })
        }
    }
}

#Preview {
    TextFieldStyleView(selectedWidget: .all, stylingDarkMode: false)
}
