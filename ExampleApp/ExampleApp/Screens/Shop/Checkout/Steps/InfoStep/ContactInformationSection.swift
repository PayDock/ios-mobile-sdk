//
//  ContactInformationSection.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ContactInformationSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var phone: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("First Name", text: $firstName)
                        .accessibilityIdentifier("Checkout First Name Field")
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Last Name", text: $lastName)
                        .accessibilityIdentifier("Checkout Last Name Field")
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                TextField("Email", text: $email)
                    .accessibilityIdentifier("Checkout Email Field")
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                TextField("Phone", text: $phone)
                    .accessibilityIdentifier("Checkout Phone Field")
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
            }
        }
    }
}
