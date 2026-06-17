//
//  SDKButton.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

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
    private let accessibilityHint: String?
    private let action: () -> Void

    @StateObject private var announcementManager = LoadingAnnouncementManager()
    @ScaledMetric private var iconHeight: CGFloat = 20

    // Observe Dynamic Type so the button rebuilds when the accessibility font size changes.
    // The title font comes from CustomFont.scaledFont, which for system fonts bakes a fixed-size
    // Font via UIFontMetrics at compute time — that Font does not live-update on a Dynamic Type
    // change (unlike the relativeTo-based custom-font path). Re-evaluating on this value (see the
    // `.id` below) recomputes the font under the new size, instead of requiring the button to be
    // reinitialised.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(title: String?,
         backgroundImage: Image? = nil,
         imageLocation: ImageLocation = .left,
         isLoading: Bool = false,
         style: SDKButtonStyle,
         scaleToFit: Bool = false,
         isLeftAligned: Bool = false,
         shouldTemplate: Bool = false,
         contentPadding: CGFloat = 16.0,
         accessibilityHint: String? = nil,
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
        self.accessibilityHint = accessibilityHint
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
            .accessibilityLabel(getAccessibilityLabel())
            .accessibilityHint(getAccessibilityHint())
            .accessibilityAddTraits(.isButton)
            // Rebuild the styled button when Dynamic Type changes so the baked system font
            // (CustomFont.scaledFont) is recomputed at the new size without reinitialising.
            .id(dynamicTypeSize)
        }
        .frame(maxWidth: .infinity, minHeight: 48)
    }

    // MARK: - Accessibility Helpers

    private func getAccessibilityLabel() -> String {
        let buttonTitle = title ?? ""
        if isLoading {
            return "\(buttonTitle), loading"
        }
        return buttonTitle
    }

    private func getAccessibilityHint() -> String {
        if style.isDisabled {
            return "Button is currently disabled"
        }
        if isLoading {
            return "Please wait, processing"
        }
        // Use custom hint if provided and not empty
        if let customHint = accessibilityHint, !customHint.isEmpty {
            return customHint
        }
        // Provide sensible default based on button title
        return getDefaultAccessibilityHint()
    }

    private func getDefaultAccessibilityHint() -> String {
        guard let buttonTitle = title?.lowercased() else {
            return "Double tap to activate"
        }

        // Provide context-appropriate defaults based on button text
        if buttonTitle.contains("submit") || buttonTitle.contains("send") {
            return "Double tap to submit"
        } else if buttonTitle.contains("continue") || buttonTitle.contains("next") {
            return "Double tap to continue"
        } else if buttonTitle.contains("pay") || buttonTitle.contains("purchase") || buttonTitle.contains("buy") {
            return "Double tap to process payment"
        } else if buttonTitle.contains("save") {
            return "Double tap to save"
        } else if buttonTitle.contains("cancel") {
            return "Double tap to cancel"
        } else if buttonTitle.contains("delete") || buttonTitle.contains("remove") {
            return "Double tap to delete"
        } else if buttonTitle.contains("confirm") {
            return "Double tap to confirm"
        } else if buttonTitle.contains("done") || buttonTitle.contains("finish") {
            return "Double tap to finish"
        } else if buttonTitle.contains("back") {
            return "Double tap to go back"
        } else if buttonTitle.contains("close") {
            return "Double tap to close"
        } else {
            return "Double tap to activate"
        }
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

// MARK: - SDKButton_Previews

struct LargeButton_Previews: PreviewProvider {

    static var previews: some View {
        SDKButton(title: "asdf", style: .custom(CustomButtonStyle(appearance: .init()))) { }
    }
}
