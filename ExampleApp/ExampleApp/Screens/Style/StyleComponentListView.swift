//
//  StyleComponentListView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct StyleComponentListView: View {
    
    @StateObject var viewModel: StyleVM
    
    init(selectedWidget: WidgetsEnum) {
        _viewModel = StateObject(wrappedValue: StyleVM(selectedWidget: selectedWidget))
    }
    
    var body: some View {
        NavigationStack {
            List {
                StyleDarkModeView()
                    .environmentObject(viewModel)
                    .listRowBackground(Color(hex: "#EAE0D7"))
                    .listRowSeparatorTint(.clear)

                ForEach(viewModel.getComponentsForWidget(viewModel.selectedWidget), id: \.self) { component in
                    stylizedNavigationLink(component: component)
                }
            }
            .listStyle(.plain)
            .background(Color(hex: "#EAE0D7"))
        }
        .navigationTitle(viewModel.selectedWidget.title)
        .foregroundColor(.black)
        .background(Color(hex: "#EAE0D7"))
    }
    
    func stylizedNavigationLink(component: StyleComponentsEnum) -> some View {
        return NavigationLink(destination: component.destinationView(
            selectedWidget: viewModel.selectedWidget,
            stylingDarkMode: viewModel.stylingDarkMode)) {
                cell(component: component)
        }
        .listRowSeparatorTint(.black)
        .listSectionSeparator(.hidden, edges: .top)
        .listRowBackground(Color(hex: "#EAE0D7"))
    }
    
    func cell(component: StyleComponentsEnum) -> some View {
        HStack {
            HStack {
                Text(component.title)
                    .font(.title2)
                    .padding(.vertical, 6)
                Spacer()
            }
            Spacer()
        }
        .listRowBackground(Color(hex: "#EAE0D7"))
    }
}

#Preview {
    StyleComponentListView(selectedWidget: .all)
}
