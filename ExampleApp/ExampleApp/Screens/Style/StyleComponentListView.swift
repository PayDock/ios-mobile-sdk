//
//  StyleComponentListView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct StyleComponentListView: View {
    
    @EnvironmentObject var viewModel: StyleVM
    let selectedWidget: WidgetsEnum
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.getComponentsForWidget(selectedWidget), id: \.self) { component in
                    stylizedNavigationLink(component: component)
                }
            }
            .listStyle(.plain)
            .background(Color(hex: "#EAE0D7"))
        }
        .navigationTitle(selectedWidget.title)
        .foregroundColor(.black)
        .background(Color(hex: "#EAE0D7"))
        .onAppear {
            viewModel.selectedWidget = selectedWidget
        }
    }
    
    func stylizedNavigationLink(component: StyleComponentsEnum) -> some View {
        return NavigationLink(destination: component.destinationView(
            selectedWidget: selectedWidget,
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
