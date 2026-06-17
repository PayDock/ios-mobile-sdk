//
//  ButtonLoaderStyleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

struct ButtonLoaderStyleView: View {

    @StateObject var viewModel: ButtonLoaderStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: ButtonLoaderStyleVM(
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
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .navigationTitle("Button Loader")
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
                title: "Loader",
                text: Binding(
                    get: { viewModel.loaderColor.toHex() },
                    set: { viewModel.loaderColor = Color(hex: $0) }),
                pickedColor: $viewModel.loaderColor
            )
        }
    }
}

struct ButtonLoaderStyleView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonLoaderStyleView(selectedWidget: .all, stylingDarkMode: false)
    }
}
