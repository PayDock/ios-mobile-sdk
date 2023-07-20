//
//  StyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 18.07.2023..
//

import SwiftUI

struct StyleView: View {

    @ObservedObject var viewModel = StyleVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    sectionTitle("Colours")
                    colorFieldView(title: "Primary", text: $viewModel.primaryColor)
                    colorFieldView(title: "Secondary", text: $viewModel.secondaryColor)
                    divider

                    sectionTitle("Font")
                    fontPickerView(title: "Font", text: $viewModel.fontName)
                    divider

                    HStack {
                        designTextView(title: "Corner Radius", text: $viewModel.cornerRadius)
                        designTextView(title: "Padding", text: $viewModel.padding)
                    }
                    .padding(.trailing, 16)
                    divider

                    Button("Button Name") {
                        print("asdf")
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

    private func fontPickerView(title: String, text: Binding<String>) -> some View {
        VStack {
            Menu {
                ForEach(viewModel.allFontNames, id: \.self) { client in
                    Button(client) {
                        self.viewModel.fontName = client
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
                            Text(viewModel.fontName.isEmpty ? "Select font" : viewModel.fontName)
                                .foregroundColor(.black)
                                .padding(.leading, 32)
                            Spacer()
                            Image("angle-down")
                                .padding(.trailing, 32)
                        }
                    }
                }
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
}

struct StyleView_Previews: PreviewProvider {
    static var previews: some View {
        StyleView()
    }
}
