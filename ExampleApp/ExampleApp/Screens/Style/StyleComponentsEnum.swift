//
//  StyleComponentsEnum.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

enum StyleComponentsEnum {
    case textField
    case searchDropdown
    case actionButton
    case expandSectionButton
    case toolbarButton
    case loader
    case toggle
    case linkText
    case toggleText
    case description
    case title
    
    var title: String {
        switch self {
        case .textField: return "Text Field"
        case .searchDropdown: return "Search Dropdown"
        case .actionButton: return "Action Button"
        case .expandSectionButton: return "Expand Section Button"
        case .toolbarButton: return "Toolbar Button"
        case .loader: return "Loader"
        case .toggle: return "Toggle"
        case .linkText: return "Link Text"
        case .toggleText: return "Toggle Text"
        case .description: return "Description"
        case .title: return "Title"
        }
    }
    
    var destinationView: AnyView {
        // TODO: - Add destination component by component
        switch self {
        default: return AnyView(EmptyView())
        }
    }
}
