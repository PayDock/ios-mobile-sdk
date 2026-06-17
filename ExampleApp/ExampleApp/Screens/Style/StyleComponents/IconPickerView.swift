//
//  IconPickerView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

struct IconPickerView: View {

    @State var entries: [String]
    @Binding var selected: Image?
    @State var placeholder: String
    @State private var showingIconGrid = false

    var onSelection: (Image?) -> Void

    var body: some View {
        VStack {
            HStack {
                Text(placeholder)
                    .padding(.leading, 16)
                    .padding(.bottom, -4)
                Spacer()
            }

            Button(action: {
                showingIconGrid = true
            }, label: {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(height: 40)
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 16)

                        HStack {
                            if let selected = selected {
                                selected
                                    .foregroundColor(.black)
                                    .padding(.leading, 32)
                            }

                            Text(selected != nil ? "" : "Select an icon")
                                .foregroundColor(.black)
                                .padding(.horizontal, (selected != nil) ? 0 : 32)
                            Spacer()
                            Image("angle-down")
                                .padding(.trailing, 32)
                        }
                    }
                }
            })
            .buttonStyle(PlainButtonStyle())
            .accessibilityIdentifier("Button_\(placeholder)")
            .sheet(isPresented: $showingIconGrid) {
                IconGridView(
                    entries: entries,
                    selectedIcon: $selected,
                    onSelection: onSelection
                )
            }
        }
    }
}

struct IconPickerView_Previews: PreviewProvider {
    static var previews: some View {
        IconPickerView(
            entries: ["heart", "star", "bookmark", "house"],
            selected: .constant(Image(systemName: "heart")),
            placeholder: "Select an icon",
            onSelection: { _ in }
        )
    }
}
