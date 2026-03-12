//
//  PickerView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.07.2023..
//

import SwiftUI

struct PickerView: View {

    @State var entries: [String]
    @Binding var selected: String
    @State var placeholder: String

    var onSelection: (String) -> Void

    var body: some View {
        VStack {
            HStack {
                Text(placeholder)
                    .padding(.leading, 16)
                    .padding(.bottom, -4)
                Spacer()
            }
            Menu {
                ForEach(entries, id: \.self) { client in
                    Button(client) {
                        self.selected = client
                        onSelection(selected)
                    }
                    .accessibilityIdentifier("MenuItem_\(placeholder)_\(client)")
                }
            } label: {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(height: 40)
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 16)

                        HStack {
                            Text(selected)
                                .foregroundColor(.black)
                                .padding(.leading, 32)
                                .font(.custom(selected, size: 14))
                            Spacer()
                            Image("angle-down")
                                .padding(.trailing, 32)
                        }
                    }
                }
            }
            .accessibilityIdentifier("Menu_\(placeholder)")
        }
    }
}

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        PickerView(entries: ["Font 1, Font 2"], selected: .constant("Font"), placeholder: "Select something", onSelection: {_ in })
    }
}
