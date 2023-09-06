//
//  StyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 18.07.2023..
//

import SwiftUI

struct StyleView: View {

    @ObservedObject var viewModel = StyleVM()

    init() {
        styleNavigation()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    sectionTitle("Colours")
                    colorListView

                    divider

                    sectionTitle("Font")
                    PickerView(entries: viewModel.allFontNames, selected: viewModel.fontName, placeholder: "Select Font", onSelection: {_ in })
                    divider

                    sectionTitle("Design")
                    HStack {
                        designTextView(title: "Corner", text: $viewModel.cornerRadius)
                        designTextView(title: "Padding", text: $viewModel.padding)
                        designTextView(title: "Border Width", text: $viewModel.borderWidth)
                    }
                    .padding(.trailing, 16)
                    divider

                    Button("Update styles") {
                        viewModel.saveStyle()
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .padding(.horizontal, 16)
                }
                .navigationTitle("Style")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
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

    private var colorListView: some View {
        VStack {
            colorFieldView(title: "Primary", text: $viewModel.primaryColorHex)
            colorFieldView(title: "On Primary", text: $viewModel.onPrimaryColorHex)
            colorFieldView(title: "Text", text: $viewModel.textColorHex)
            colorFieldView(title: "Success", text: $viewModel.successColorHex)
            colorFieldView(title: "Error", text: $viewModel.errorColorHex)
            colorFieldView(title: "Background", text: $viewModel.backgroundColorHex)
            colorFieldView(title: "Placeholder", text: $viewModel.placeholderColorHex)
        }
    }

    private func colorFieldView(title: String, text: Binding<String>) -> some View {
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

                    TextField(title, text: text)
                        .frame(height: 40)
                        .background(Color.white)
                        .padding(.leading, 32)
                }

                Rectangle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hex: "#\(text.wrappedValue)"))
                    .padding(16)
            }
        }
    }

    private func designTextView(title: String, text: Binding<String>) -> some View {
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

                    TextField(title, text: text)
                        .frame(height: 40)
                        .background(Color.white)
                        .padding(.leading, 32)
                }
            }
        }
    }

    private func styleNavigation() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().barTintColor = .white
    }
}

struct StyleView_Previews: PreviewProvider {
    static var previews: some View {
        StyleView()
    }
}
