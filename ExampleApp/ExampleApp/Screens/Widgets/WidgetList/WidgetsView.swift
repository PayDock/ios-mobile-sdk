//
//  WidgetsView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import SwiftUI

struct WidgetsView: View {
    
    @StateObject private var viewModel = WidgetsVM()

    init() {
        styleNavigation()
    }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: CardDetailsWidgetView()) {
                    cell(
                        title: "Card Details",
                        subtitle: "Tokenise card details")
                }
                .listRowSeparatorTint(.black)
                .listSectionSeparator(.hidden, edges: .top)
                .listRowBackground(Color(hex: "#EAE0D7"))
                
                NavigationLink(destination: AddressWidgetView()) {
                    cell(
                        title: "Address",
                        subtitle: "Capture customer address form")
                }
                .listRowSeparatorTint(.black)
                .listSectionSeparator(.hidden, edges: .top)
                .listRowBackground(Color(hex: "#EAE0D7"))

                NavigationLink(destination: AddressWidgetView()) {
                    cell(
                        title: "Apple Pay",
                        subtitle: "Standalone Apple Pay flow")
                }
                .listRowSeparatorTint(.black)
                .listSectionSeparator(.hidden, edges: .top)
                .listRowBackground(Color(hex: "#EAE0D7"))
            }
            .navigationTitle("Widgets")
            .background(Color(hex: "#EAE0D7"))
            .listStyle(.plain)

        }
        .foregroundColor(.black)
        .padding(.trailing, -28)
        .background(Color(hex: "#EAE0D7"))
    }

    func cell(title: String, subtitle: String) -> some View {
        HStack {
            VStack {
                HStack {
                    Text(title)
                        .font(.title2)
                        .padding(.vertical, 6)
                    Spacer()
                }

                HStack {
                    Text(subtitle)
                        .foregroundColor(.gray)
                        .padding(.bottom, 6)
                    Spacer()
                }

            }
            Spacer()
            Image(.chevronRight)
        }
        .listRowBackground(Color(hex: "#EAE0D7"))
    }

    private func styleNavigation() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().barTintColor = .white
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsView()
    }
}
