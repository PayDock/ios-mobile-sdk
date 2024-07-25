//
//  SettingsView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 18.07.2023..
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel = SettingsVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    sectionTitle("Environment")
                    HStack {
                        Text(viewModel.getSelectedEnvironmentEndpoint())
                            .padding(.horizontal, 16)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    PickerView(entries: viewModel.getProjectEnvironmentNames(), selected: viewModel.selectedEnvironment, placeholder: "Select environment", onSelection: { selectedEnvironment  in
                        viewModel.selectedEnvironment = selectedEnvironment
                    })
                    divider

                    sectionTitle("Access Token")
                    textField(title: "Access Token", text: $viewModel.accessToken) {
                        viewModel.copyAccessToken()
                    }
                    divider

                    sectionTitle("Language")
                    PickerView(entries: viewModel.languages, selected: viewModel.selectedLanguage, placeholder: "Language") { language in
                        viewModel.selectedLanguage = language
                    }
                    divider

                    Button("Save") {
                        viewModel.save()
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .navigationTitle("Settings")
            }
            .background(Color(hex: "#EAE0D7"))
        }
    }

    private var divider: some View {
        Rectangle()
            .foregroundColor(Color.black)
            .frame(height: 1).padding(.vertical, 15)
            .padding(.horizontal, 16)
    }

    private func sectionTitle(_ title: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.title)
            Spacer()
        }
        .padding(16)
    }

    private func textField(title: String, text: Binding<String>, action: @escaping () -> Void) -> some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(height: 40)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 16)

                TextField(title, text: text)
                    .frame(height: 40)
                    .background(Color.white)
                    .padding(.leading, 32)
                    .padding(.trailing, 64)

                HStack {
                    Spacer()
                    Button(action: action) {
                        Image("clone")
                            .padding(.horizontal, 32)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
