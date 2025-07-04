//
//  DimensionsFieldView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct DimensionsFieldView: View {
    
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .padding(.leading, 16)
                    .padding(.bottom, -4)
                Spacer()
            }
            HStack {
                ZStack {
                    Rectangle()
                        .frame(height: 40)
                        .foregroundColor(Color.white)
                        .padding(.leading, 16)
                    
                    TextField(title, text: $text)
                        .frame(height: 40)
                        .background(Color.white)
                        .padding(.leading, 32)
                }
            }
        }
        .padding(.trailing, 16.0)
    }
}

#Preview {
    DimensionsFieldView(title: "Title", text: .constant("Text"))
}
