//
//  ActivityIndicator.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool

    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.color = UIColor(Color.defaultPrimary)
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }

}
