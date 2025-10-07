//
//  SpacingsStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct SpacingsStyleView: View {

    @StateObject var viewModel: SpacingsStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: SpacingsStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    spacingsListView
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .navigationTitle("Spacings")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var spacingsListView: some View {
        VStack(spacing: 16) {
            DimensionsFieldView(
                title: "Horizontal spacing",
                text: Binding(
                    get: { "\(viewModel.horizontalSpacing)" },
                    set: { viewModel.horizontalSpacing = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Vertical spacing",
                text: Binding(
                    get: { "\(viewModel.verticalSpacing)" },
                    set: { viewModel.verticalSpacing = CGFloat(Double($0) ?? 0) }))
        }
    }
}

struct SpacingsStyleView_Previews: PreviewProvider {
    static var previews: some View {
        SpacingsStyleView(selectedWidget: .all, stylingDarkMode: false)
    }
}
