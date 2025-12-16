//
//  ConfigWidgetItem.swift
//  ExampleApp
//

import SwiftUI

struct ConfigWidgetItem: Identifiable {
    let id = UUID()
    let widget: ConfigWidgetsEnum

    var destination: some View {
        ConfigComponentListView(selectedWidget: widget)
    }
}
