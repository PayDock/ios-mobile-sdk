//
//  ConfigWidgetItem.swift
//  ExampleApp

import SwiftUI

struct ConfigWidgetItem: Identifiable {
    let id = UUID()
    let widget: ConfigWidgetsEnum

    func destination(viewModel: ConfigVM) -> some View {
        let components = viewModel.getComponentsForWidget(widget)

        // If there's only one component, navigate directly to it
        if components.count == 1, let component = components.first {
            return AnyView(component.destinationView(selectedWidget: widget))
        }

        // Otherwise, show the component list
        return AnyView(ConfigComponentListView(selectedWidget: widget))
    }
}
