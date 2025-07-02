//
//  LoaderStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 09.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct LoaderStyleView: View {

    @StateObject var viewModel: LoaderStyleVM
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: LoaderStyleVM(
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
                    ResetStyleButton() {
                        viewModel.showResetConfirmation = true
                    }
                }
                .navigationTitle("Loader")
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
            
            ColorPickerView(
                title: "Loader overlay",
                text: Binding(
                    get: { viewModel.loaderOverlayColor.toHex() },
                    set: { viewModel.loaderOverlayColor = Color(hex: $0) }),
                pickedColor: $viewModel.loaderOverlayColor
            )
        }
    }
}

struct LoaderStyleView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderStyleView(selectedWidget: .all, stylingDarkMode: false)
    }
}
