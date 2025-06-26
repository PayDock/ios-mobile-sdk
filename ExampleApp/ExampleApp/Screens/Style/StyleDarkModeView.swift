//
//  StyleDarkModeView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct StyleDarkModeView: View {
    
    @EnvironmentObject var viewModel: StyleVM
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Mode")
                    .font(.title3)
                Spacer()
                StyleDarkModeButton(isSelected: !viewModel.stylingDarkMode, icon: Image("sun")) {
                    viewModel.stylingDarkMode = false
                }
                StyleDarkModeButton(isSelected: viewModel.stylingDarkMode, icon: Image("moon")) {
                    viewModel.stylingDarkMode = true
                }
            }
            Text("These styles apply to the widget screen based on your phone's dark or light mode settings. ")
                .font(.caption)
            
        }
        .background(Color(hex: "#EAE0D7"))
        .padding(.bottom, 16.0)
    }
}

#Preview {
    StyleDarkModeView()
        .environmentObject(StyleVM(selectedWidget: .all))
}
