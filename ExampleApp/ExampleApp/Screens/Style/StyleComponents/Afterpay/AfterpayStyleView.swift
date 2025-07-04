//
//  AfterpayStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct AfterpayStyleView: View {

    @StateObject var viewModel: AfterpayStyleVM
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: AfterpayStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
    }
    
    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SectionTitleView(title: "Style")
                    stylePickersView
                    ResetStyleButton() {
                        viewModel.showResetConfirmation = true
                    }
                }
                .padding(.bottom, 16.0)
                .navigationTitle("AfterPay Button")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var stylePickersView: some View {
        VStack(spacing: 16) {
            PickerView(
                entries: viewModel.buttonTypeNames,
                selected: $viewModel.selectedButtonTypeName,
                placeholder: "Select Button Type") { buttonTypeName in
                viewModel.selectedButtonTypeName = buttonTypeName
            }
            
            PickerView(
                entries: viewModel.colorSchemeNames,
                selected: $viewModel.selectedColorSchemeName,
                placeholder: "Select Color Scheme") { colorSchemeName in
                viewModel.selectedColorSchemeName = colorSchemeName
            }
        }
    }
}

#Preview {
    AfterpayStyleView(selectedWidget: .all, stylingDarkMode: false)
}
