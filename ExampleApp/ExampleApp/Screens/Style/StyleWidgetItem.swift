//
//  StyleWidgetItem.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

struct StyleWidgetItem: Identifiable {
    let id = UUID()
    let widget: WidgetsEnum
    let destination: StyleComponentListView

    init(widget: WidgetsEnum) {
        self.widget = widget
        self.destination = StyleComponentListView(selectedWidget: widget)
    }
}
