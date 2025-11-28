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
    private let backgroundImage: Image?
    private let imageLocation: ImageLocation
    private let isLoading: Bool
    private let style: SDKButtonStyle
    private let scaleToFit: Bool
    private let isLeftAligned: Bool
    private let shouldTemplate: Bool
    private let contentPadding: CGFloat
    private let action: () -> Void

    @StateObject private var announcementManager = LoadingAnnouncementManager()
    @ScaledMetric private var iconHeight: CGFloat = 20

    init(title: String?,
         backgroundImage: Image? = nil,
         imageLocation: ImageLocation = .left,
         isLoading: Bool = false,
         style: SDKButtonStyle,
         scaleToFit: Bool = false,
         isLeftAligned: Bool = false,
         shouldTemplate: Bool = false,
         contentPadding: CGFloat = 16.0,
         action: @escaping () -> Void) {
        self.title = title
        self.backgroundImage = backgroundImage
        self.imageLocation = imageLocation
        self.isLoading = isLoading
        self.style = style
        self.scaleToFit = scaleToFit
        self.isLeftAligned = isLeftAligned
        self.shouldTemplate = shouldTemplate
        self.contentPadding = contentPadding
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: self.action) {
                if scaleToFit {
                    ZStack {
                        (style.image ?? backgroundImage)?
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
                } else if style.image == nil {
                    getTitle()
                        .padding(contentPadding) // Adds padding between outer button edges and the title inside it
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    getImageAndTitle()
                        .padding(contentPadding) // Adds padding between outer button edges and the content inside it
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
                    style.image?
                        .resizable()
                        .renderingMode(shouldTemplate ? .template : .original)
                        .scaledToFit()
                        .foregroundColor(style.imageColor)
                        .frame(height: scaleToFit ? .infinity : iconHeight)
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
                if let title = title, !title.isEmpty {
                    Text(title)
                }
            } else {
                if let title = title, !title.isEmpty {
                    Text(title)
                }

                if !isLoading {
                    style.image?.resizable()
                        .renderingMode(shouldTemplate ? .template : .original)
                        .scaledToFit()
                        .foregroundColor(style.imageColor)
                        .frame(height: iconHeight)
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
        SDKButton(title: "asdf", style: .custom(CustomButtonStyle(appearance: .init()))) { }
    }
}
