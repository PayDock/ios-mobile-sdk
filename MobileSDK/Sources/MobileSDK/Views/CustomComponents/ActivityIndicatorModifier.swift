//
//  ActivityIndicatorModifier.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 08.12.2023..
//

import SwiftUI

struct ActivityIndicatorModifier: AnimatableModifier {
    var isLoading: Bool
    @State private var hostingController: UIHostingController<ActivityIndicator>? = nil

    init(isLoading: Bool) {
        self.isLoading = isLoading
    }

    func body(content: Content) -> some View {
        ZStack {
            ZStack(alignment: .bottom) {
                content
                if isLoading  {
                    VStack {}
                        .onAppear {
                            showIndicator()
                        }
                        .onDisappear { 
                            dismissIndicator()
                        }
                }
            }
        }
    }

    func showIndicator() {
        let activityIndicator = ActivityIndicator(isAnimating: .constant(true), style: .large)
        
        hostingController = UIHostingController(rootView: activityIndicator)
        hostingController?.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        hostingController?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hostingController?.view.alpha = 0

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(hostingController!.view)
            hostingController?.view.center.x = window.center.x
        }

        UIView.animate(withDuration: 0.3) {
            hostingController?.view.alpha = 1
        }
    }

    func dismissIndicator() {
        UIView.animate(withDuration: 0.3, animations: {
            hostingController?.view.alpha = 0
        }, completion: { _ in
            hostingController?.view.removeFromSuperview()
            hostingController = nil
        })
    }
}
