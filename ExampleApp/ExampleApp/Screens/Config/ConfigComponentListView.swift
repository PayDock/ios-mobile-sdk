//
//  ConfigComponentListView.swift
//  ExampleApp
//

import SwiftUI

struct ConfigComponentListView: View {

    @EnvironmentObject var viewModel: ConfigVM
    let selectedWidget: ConfigWidgetsEnum

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

    func stylizedNavigationLink(component: ConfigComponentsEnum) -> some View {
        return NavigationLink(destination: component.destinationView(selectedWidget: selectedWidget).environmentObject(viewModel)) {
                cell(component: component)
            }
            .listRowSeparatorTint(.black)
            .listSectionSeparator(.hidden, edges: .top)
            .listRowBackground(Color(hex: "#EAE0D7"))
    }

    func cell(component: ConfigComponentsEnum) -> some View {
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
    ConfigComponentListView(selectedWidget: .card)
}
