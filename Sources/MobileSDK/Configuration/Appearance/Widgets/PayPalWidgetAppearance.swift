//
//  PayPalWidgetAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI
import PaymentButtons

public struct PayPalWidgetAppearance: ActionButtonLoaderStylableAppearance {
    public var buttonInsets: NSDirectionalEdgeInsets?
    public var buttonColor: PayPalButton.Color
    public var buttonEdges: PaymentButtonEdges
    public var buttonSize: PaymentButtonSize
    public var buttonLabel: PayPalButton.Label?
    public var loader: Theme.ButtonLoader

    public init(buttonInsets: NSDirectionalEdgeInsets? = nil,
                buttonColor: PayPalButton.Color = .gold,
                buttonEdges: PaymentButtonEdges = .softEdges,
                buttonSize: PaymentButtonSize = .full,
                buttonLabel: PayPalButton.Label? = nil,
                loader: Theme.ButtonLoader = .init(spinnerColor: .black)) {
        self.buttonInsets = buttonInsets
        self.buttonColor = buttonColor
        self.buttonEdges = buttonEdges
        self.buttonSize = buttonSize
        self.buttonLabel = buttonLabel
        self.loader = loader
    }
}
