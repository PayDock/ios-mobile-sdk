//
//  PickerView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.07.2023..
//

import SwiftUI

struct PickerView: View {

    @State var entries: [String]
    @State var selected: String
    @State var placeholder: String

    var onSelection: (String) -> Void

    var body: some View {
        VStack {
            Menu {
                ForEach(entries, id: \.self) { client in
                    Button(client) {
                        self.selected = client
                        onSelection(selected)
                    }
                }
            } label: {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(height: 40)
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 16)

                        HStack {
                            Text(selected.isEmpty ? placeholder : selected)
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
        }
    }
}

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        PickerView(entries: ["Font 1, Font 2"], selected: "", placeholder: "Select something", onSelection: {_ in })
    }
}
