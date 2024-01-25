//
//  LargeButton.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 19.08.2023..
//

import SwiftUI

struct LargeButton: View {

    private let title: String
    private let image: Image?
    private let imageLocation: ImageLocation
    private let disabled: Bool
    private var backgroundColor: Color
    private var foregroundColor: Color
    private let action: () -> Void

    init(title: String,
                image: Image? = nil,
                imageLocation: ImageLocation = .left,
                disabled: Bool = false,
                backgroundColor: Color = .primaryColor,
                foregroundColor: Color = .white,
                action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.imageLocation = imageLocation
        self.disabled = disabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
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
            .buttonStyle(LargeButtonStyle(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                isDisabled: disabled))
            .disabled(self.disabled)
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
        LargeButton(title: "asdf") { }
    }

}
