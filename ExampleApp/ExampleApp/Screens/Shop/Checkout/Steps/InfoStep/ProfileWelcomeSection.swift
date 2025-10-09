//
//  ProfileWelcomeSection.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ProfileWelcomeSection: View {
    let firstName: String
    let onUseProfileInfo: () -> Void

    var body: some View {
        HStack {
            Text("Welcome back, \(firstName)!")
                .font(.headline)
                .foregroundColor(.defaultPrimary)

            Spacer()

            Button("Use Profile Info") {
                onUseProfileInfo()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.defaultPrimary)
        }
        .padding()
        .background(Color.defaultPrimary.opacity(0.1))
        .cornerRadius(8)
    }
}
