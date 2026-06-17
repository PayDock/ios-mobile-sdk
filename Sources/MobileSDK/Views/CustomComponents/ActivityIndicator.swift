//
//  ActivityIndicator.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    private let appearance: Theme.LoaderAppearance
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    // MARK: - Initialization

    init(appearance: Theme.LoaderAppearance,
         isAnimating: Binding<Bool>,
         style: UIActivityIndicatorView.Style) {
        self.appearance = appearance
        self._isAnimating = isAnimating
        self.style = style
    }

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.color = UIColor(appearance.color)
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
