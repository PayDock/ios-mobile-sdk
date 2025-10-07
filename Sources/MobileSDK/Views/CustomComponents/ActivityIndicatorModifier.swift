//
//  ActivityIndicatorModifier.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 08.12.2023..
//

import SwiftUI

public struct ActivityIndicatorModifier: AnimatableModifier {
    private let appearance: Theme.OverlayLoaderAppearance
    public var isLoading: Bool
    @State private var hostingController: UIHostingController<ActivityIndicator>?
    @StateObject private var announcementManager = LoadingAnnouncementManager()

    public init(appearance: Theme.OverlayLoaderAppearance = Theme.OverlayLoaderAppearance(),
                isLoading: Bool) {
        self.appearance = appearance
        self.isLoading = isLoading
    }

    public func body(content: Content) -> some View {
        ZStack {
            ZStack(alignment: .bottom) {
                content
                if isLoading {
                    VStack {}
                        .onAppear { showIndicator() }
                        .onDisappear { dismissIndicator() }
                }
            }
        }
    }

    public func showIndicator() {
        let activityIndicator = ActivityIndicator(
            appearance: appearance,
            isAnimating: .constant(true),
            style: .large
        )

        hostingController = UIHostingController(rootView: activityIndicator)
        hostingController?.view.backgroundColor = UIColor(appearance.overlayColor)
        hostingController?.view.frame = UIScreen.main.bounds
        hostingController?.view.alpha = 0

        hostingController?.view.isAccessibilityElement = true
        hostingController?.view.accessibilityLabel = "Loading, please wait."
        hostingController?.view.accessibilityTraits = [.updatesFrequently]
        hostingController?.view.accessibilityViewIsModal = true

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(hostingController!.view)
        }

        UIView.animate(withDuration: 0.3) {
            hostingController?.view.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .screenChanged,
                                 argument: self.hostingController?.view)
        }

        announcementManager.start()
    }

    public func dismissIndicator() {
        UIView.animate(withDuration: 0.3, animations: {
            hostingController?.view.alpha = 0
        }, completion: { _ in
            hostingController?.view.removeFromSuperview()
            hostingController = nil

            announcementManager.stop()
        })
    }
}

final class LoadingAnnouncementManager: ObservableObject {
    private var timer: Timer?

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            UIAccessibility.post(notification: .announcement, argument: "Still loading, this might take a few moments.")
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
