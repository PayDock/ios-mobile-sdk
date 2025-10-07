//
//  SDKButton.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.08.2023..
//

import SwiftUI

struct SDKButton: View {

    private let title: String?
    private let image: Image?
    private let imageLocation: ImageLocation
    private let isLoading: Bool
    private let style: SDKButtonStyle
    private let scaleToFit: Bool
    private let isLeftAligned: Bool
    private let shouldTemplate: Bool
    private let action: () -> Void

    @StateObject private var announcementManager = LoadingAnnouncementManager()

    init(title: String?,
         image: Image? = nil,
         imageLocation: ImageLocation = .left,
         isLoading: Bool = false,
         style: SDKButtonStyle,
         scaleToFit: Bool = false,
         isLeftAligned: Bool = false,
         shouldTemplate: Bool = false,
         action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.imageLocation = imageLocation
        self.isLoading = isLoading
        self.style = style
        self.scaleToFit = scaleToFit
        self.isLeftAligned = isLeftAligned
        self.shouldTemplate = shouldTemplate
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: self.action) {
                if scaleToFit {
                    ZStack {
                        image?
                            .resizable()
                            .renderingMode(shouldTemplate ? .template : .original)
                            .scaledToFit()
                            .foregroundColor(style.imageColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(style.isDisabled ? 0.3 : 1.0)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                            .opacity(isLoading ? 1.0 : 0.0)
                            .onAppear {
                                announcementManager.start()
                            }
                            .onDisappear {
                                announcementManager.stop()
                            }
                    }
                } else if image != nil && title != nil {
                    getImageAndTitle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    getTitle()
                        .padding(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .myStyle(style)
            .disabled(style.isDisabled)
            .accessibilityLabel(isLoading ? "Loading" : title ?? "")
        }
        .frame(maxWidth: .infinity, minHeight: 48)
    }

    private func getImageAndTitle() -> some View {
        HStack {
            if imageLocation == .left {
                if !isLoading {
                    image?
                        .resizable()
                        .renderingMode(shouldTemplate ? .template : .original)
                        .scaledToFit()
                        .foregroundColor(style.imageColor)
                        .frame(maxHeight: scaleToFit ? .infinity : 20)
                        .font(.system(size: 32, weight: .light))
                        .opacity(style.isDisabled ? 0.3 : 1.0)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                        .onAppear {
                            announcementManager.start()
                        }
                        .onDisappear {
                            announcementManager.stop()
                        }
                }
                Text(self.title ?? "")
            } else {
                Text(self.title ?? "")
                if !isLoading {
                    image?.resizable()
                        .renderingMode(shouldTemplate ? .template : .original)
                        .scaledToFit()
                        .foregroundColor(style.imageColor)
                        .frame(maxHeight: 20)
                        .font(.system(size: 32, weight: .light))
                        .opacity(style.isDisabled ? 0.3 : 1.0)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                        .onAppear {
                            announcementManager.start()
                        }
                        .onDisappear {
                            announcementManager.stop()
                        }
                }
            }
        }
    }

    private func getTitle() -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                    .onAppear {
                        announcementManager.start()
                        UIAccessibility.post(notification: .announcement, argument: "Loading")
                    }
                    .onDisappear {
                        announcementManager.stop()
                        UIAccessibility.post(notification: .announcement, argument: "Finished loading")
                    }
            }
            Text(self.title ?? "")
            if isLeftAligned {
                Spacer()
            }
        }
    }

    enum ImageLocation {
        case left
        case right
    }
}

// MARK: - OutlineTextField_Previews

struct LargeButton_Previews: PreviewProvider {

    static var previews: some View {
        SDKButton(title: "asdf", style: .outline(OutlineButtonStyle())) { }
    }
}
