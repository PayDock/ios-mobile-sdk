//
//  SDKButton.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.08.2023..
//

import SwiftUI

struct SDKButton: View {

    private let title: String
    private let image: Image?
    private let imageLocation: ImageLocation
    private let style: SDKButtonStyle
    private let action: () -> Void

    init(title: String,
         image: Image? = nil,
         imageLocation: ImageLocation = .left,
         style: SDKButtonStyle,
         action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.imageLocation = imageLocation
        self.style = style
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: self.action) {
                if image != nil {
                    getImageAndTitle()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(self.title)
                        .frame(maxWidth: .infinity)
                }
            }
            .myStyle(style)
            .disabled(style.isDisabled)
        }
        .frame(maxWidth:.infinity, minHeight: 50)
    }

    private func getImageAndTitle() -> some View {
        HStack {
            if imageLocation == .left {
                image?.resizable().scaledToFit().frame(maxHeight: 20)
                    .font(.system(size: 32, weight: .light))
                Text(self.title)
            } else {
                Text(self.title)
                image?.resizable().scaledToFit().frame(maxHeight: 20)
                    .font(.system(size: 32, weight: .light))
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

