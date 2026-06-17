//
//  Stylable.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public protocol LoaderStylableAppearance {
    var loader: Theme.LoaderAppearance { get set }
}

public protocol OverlayLoaderStylableAppearance {
    var overlayLoader: Theme.OverlayLoaderAppearance { get set }
}

public protocol ToggleStylableAppearance {
    var toggle: Theme.ToggleAppearance { get set }
}

public protocol ActionButtonStylableAppearance {
    var actionButton: Theme.ButtonAppearance { get set }
}

public protocol ExpandSectionButtonStylableAppearance {
    var expandSectionButton: Theme.ButtonAppearance { get set }
}

public protocol ToolbarButtonStylableAppearance {
    var toolbarButton: Theme.ButtonAppearance { get set }
}

public protocol TextFieldStylableAppearance {
    var textField: Theme.TextFieldAppearance { get set }
}

public protocol DropdownStylableAppearance {
    var searchDropdown: Theme.SearchDropdownAppearance { get set }
}

public protocol TitleStylableAppearance {
    var title: Theme.TextAppearance { get set }
}

public protocol ToggleTextStylableAppearance {
    var toggleText: Theme.TextAppearance { get set }
}

public protocol LinkTextStylableAppearance {
    var linkText: Theme.TextAppearance { get set }
}

public protocol SpacingStylableAppearance {
    var horizontalSpacing: CGFloat { get set }
    var verticalSpacing: CGFloat { get set }
    var textFieldVerticalSpacing: CGFloat { get set }
}

public protocol ActionButtonLoaderStylableAppearance {
    var loader: Theme.ButtonLoader { get set }
}
