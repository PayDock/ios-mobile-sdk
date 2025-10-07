//
//  SubsectionTitleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct SubsectionTitleView: View {

    let title: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.title2)
            Spacer()
        }
        .padding(16)
    }
}

#Preview {
    SectionTitleView(title: "Title")
}
