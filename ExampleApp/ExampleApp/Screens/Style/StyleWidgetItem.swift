//
//  StyleWidgetItem.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

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
