//
//  LargeButton.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 19.08.2023..
//

import SwiftUI

struct LargeButton: View {

    var backgroundColor: Color
    var foregroundColor: Color

    private let title: String
    private let action: () -> Void

    private let disabled: Bool

    init(title: String,
         disabled: Bool = false,
         backgroundColor: Color = Color.purple,
         foregroundColor: Color = Color.white,
         action: @escaping () -> Void) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.title = title
        self.action = action
        self.disabled = disabled
    }

    var body: some View {
        HStack {
            Button(action:self.action) {
                Text(self.title)
                
                    .frame(maxWidth:.infinity)
            }
            .buttonStyle(LargeButtonStyle(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                isDisabled: disabled))
            .disabled(self.disabled)
        }
        .frame(maxWidth:.infinity)
    }
}

// MARK: - OutlineTextField_Previews

struct LargeButton_Previews: PreviewProvider {

    static var previews: some View {
        LargeButton(title: "asdf") {

        }
    }

}
