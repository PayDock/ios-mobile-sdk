//
//  ToggleStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ToggleStyleView: View {

    @StateObject var viewModel: ToggleStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: ToggleStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    SectionTitleView(title: "Colors")
                    colorListView
                    SectionTitleView(title: "Custom Style")
                    Text("Modifying these properties applies a custom toggle style that overrides the native toggle appearance.")
                        .font(.caption)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    customStyleList
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .navigationTitle("Toggle")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var colorListView: some View {
        VStack {
            ColorPickerView(
                title: "Active color",
                text: Binding(
                    get: { viewModel.activeColor.toHex() },
                    set: { viewModel.activeColor = Color(hex: $0) }),
                pickedColor: $viewModel.activeColor)
        }
    }

    private var customStyleList: some View {
        VStack {
            ColorPickerView(
                title: "Inactive color",
                text: Binding(
                    get: { viewModel.inactiveColor.toHex() },
                    set: { viewModel.inactiveColor = Color(hex: $0) }),
                pickedColor: $viewModel.inactiveColor)

            ColorPickerView(
                title: "Toggle color",
                text: Binding(
                    get: { viewModel.toggleColor.toHex() },
                    set: { viewModel.toggleColor = Color(hex: $0) }),
                pickedColor: $viewModel.toggleColor)
        }
    }
}

struct ToggleStyleView_Previews: PreviewProvider {
    static var previews: some View {
        ToggleStyleView(selectedWidget: .all, stylingDarkMode: false)
    }
}
