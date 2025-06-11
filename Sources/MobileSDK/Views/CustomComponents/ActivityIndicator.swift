//
//  ActiviryIndicator.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 08.12.2023..
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    private let appearance: Theme.OverlayLoaderAppearance
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    // MARK: - Initialization
    
    init(appearance: Theme.OverlayLoaderAppearance,
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
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }

}
