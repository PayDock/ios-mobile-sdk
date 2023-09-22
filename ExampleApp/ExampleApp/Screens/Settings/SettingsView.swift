//
//  SettingsView.swift
//  ExampleApp
//
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

                    sectionTitle("Secret Key")
                    secretKeyField(text: $viewModel.secretKey)
                    divider

                    sectionTitle("Language")
                    PickerView(entries: viewModel.languages, selected: viewModel.selectedLanguage, placeholder: "Language") { language in
                        viewModel.selectedLanguage = language
                    }
                    divider

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

    private func secretKeyField(text: Binding<String>) -> some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(height: 40)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 16)

                TextField("Secret Key", text: text)
                    .frame(height: 40)
                    .background(Color.white)
                    .padding(.leading, 32)
                    .padding(.trailing, 64)

                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.copySecretKey()
                    }) {
                        Image(.clone)
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
