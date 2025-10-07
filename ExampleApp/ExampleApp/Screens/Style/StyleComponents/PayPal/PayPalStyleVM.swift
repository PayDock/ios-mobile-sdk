//
//  PayPalStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 09.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import PaymentButtons
import MobileSDK

class PayPalStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool

    private(set) var buttonColors: [PayPalButton.Color] = [
        .black, .white, .blue, .gold, .silver
    ]

    private(set) var buttonEdges: [PaymentButtonEdges] = [
        .hardEdges, .rounded, .softEdges
    ]

    private(set) var buttonSizes: [PaymentButtonSize] = [
        .collapsed, .expanded, .full, .mini
    ]

    private(set) var buttonLabels: [PayPalButton.Label] = [
        .buyNow, .checkout, .none, .payWith
    ]

    private(set) var buttonColorNames: [String] = [
        "Black", "White", "Blue", "Gold", "Silver"
    ]

    private(set) var buttonEdgesNames: [String] = [
        "Hard edges", "Rounded", "Soft edges"
    ]

    private(set) var buttonSizesNames: [String] = [
        "Collapsed", "Expanded", "Full", "Mini"
    ]

    private(set) var buttonLabelNames: [String] = [
        "Buy now", "Checkout", "None", "Pay with"
    ]

    // MARK: - Variables

    private var appearance: PayPalWidgetAppearance?
    @Published var showResetConfirmation = false

    @Published var buttonColor: PayPalButton.Color = .gold { didSet { updateAppearance() }}
    @Published var buttonEdge: PaymentButtonEdges = .softEdges { didSet { updateAppearance() }}
    @Published var buttonSize: PaymentButtonSize = .full { didSet { updateAppearance() }}
    @Published var buttonLabel: PayPalButton.Label = .none { didSet { updateAppearance() }}

    @Published var selectedButtonColorName: String = "Gold" {
        didSet {
            if let index = buttonColorNames.firstIndex(of: selectedButtonColorName) {
                buttonColor = buttonColors[index]
            }
        }
    }
    @Published var selectedButtonEdgeName: String = "Soft edges" {
        didSet {
            if let index = buttonEdgesNames.firstIndex(of: selectedButtonEdgeName) {
                buttonEdge = buttonEdges[index]
            }
        }
    }
    @Published var selectedButtonSizeName: String = "Full" {
        didSet {
            if let index = buttonSizesNames.firstIndex(of: selectedButtonSizeName) {
                buttonSize = buttonSizes[index]
            }
        }
    }
    @Published var selectedButtonLabelName: String = "None" {
        didSet {
            if let index = buttonLabelNames.firstIndex(of: selectedButtonLabelName) {
                buttonLabel = buttonLabels[index]
            }
        }
    }

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: PayPalWidgetAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
        self.buttonColor = appearance?.buttonColor ?? .gold
        self.buttonEdge = appearance?.buttonEdges ?? .softEdges
        self.buttonSize = appearance?.buttonSize ?? .full
        self.buttonLabel = appearance?.buttonLabel ?? .none

        // Sync string properties
        if let colorIndex = buttonColors.firstIndex(of: buttonColor) {
            selectedButtonColorName = buttonColorNames[colorIndex]
        }
        if let edgeIndex = buttonEdges.firstIndex(of: buttonEdge) {
            selectedButtonEdgeName = buttonEdgesNames[edgeIndex]
        }
        if let sizeIndex = buttonSizes.firstIndex(of: buttonSize) {
            selectedButtonSizeName = buttonSizesNames[sizeIndex]
        }
        if let labelIndex = buttonLabels.firstIndex(of: buttonLabel) {
            selectedButtonLabelName = buttonLabelNames[labelIndex]
        }
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.buttonColor = buttonColor
        appearance.buttonEdges = buttonEdge
        appearance.buttonSize = buttonSize
        appearance.buttonLabel = buttonLabel

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: PayPalWidgetAppearance.self)

        syncUIToAppearance()
    }
}
