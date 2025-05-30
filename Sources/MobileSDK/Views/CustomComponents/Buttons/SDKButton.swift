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
    private let action: () -> Void

    init(title: String?,
         image: Image? = nil,
         imageLocation: ImageLocation = .left,
         isLoading: Bool = false,
         style: SDKButtonStyle,
         scaleToFit: Bool = false,
         action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.imageLocation = imageLocation
        self.isLoading = isLoading
        self.style = style
        self.scaleToFit = scaleToFit
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: self.action) {
                if scaleToFit {
                    ZStack {
                        image?
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                            .opacity(isLoading ? 1.0 : 0.0)
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
        }
        .frame(maxWidth:.infinity, minHeight: 48)
    }

    private func getImageAndTitle() -> some View {
        HStack {
            if imageLocation == .left {
                if (!isLoading) {
                    image?
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: scaleToFit ? .infinity : 20)
                        .font(.system(size: 32, weight: .light))
                } else {
                    if #available(iOS 18.0, *) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                            .padding(.trailing, 4)
                    }
                }
                Text(self.title ?? "")
            } else {
                Text(self.title ?? "")
                if (!isLoading) {
                    image?.resizable()
                        .scaledToFit()
                        .frame(maxHeight: 20)
                        .font(.system(size: 32, weight: .light))
                } else {
                    if #available(iOS 18.0, *) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                            .padding(.leading, 4)
                    }
                }
            }
        }
    }
    
    private func getTitle() -> some View {
        HStack {
            if (isLoading) {
                if #available(iOS 18.0, *) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor))
                        .padding(.trailing, 4)
                }
            }
            Text(self.title ?? "")
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
