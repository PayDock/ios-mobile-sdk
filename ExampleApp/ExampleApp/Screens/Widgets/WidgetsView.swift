//
//  WidgetsView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import SwiftUI

struct WidgetsView: View {
    
    @StateObject private var viewModel = WidgetsVM()

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: CardDetailsWidgetView()) {
                    cell(title: "Card Details",
                         subtitle: "Tokenise card details") {}
                }
                .listRowSeparatorTint(.black)
                .listSectionSeparator(.hidden, edges: .top)
                .listRowBackground(Color(hex: "#EAE0D7"))
            }
            .navigationTitle("Widgets")
            .background(Color(hex: "#EAE0D7"))
            .listStyle(.plain)

        }
        .padding(.trailing, -28)
        .background(Color(hex: "#EAE0D7"))
    }

    func cell(title: String, subtitle: String, onTap: () -> Void) -> some View {
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
            Image("chevron-right")
        }
        .listRowBackground(Color(hex: "#EAE0D7"))
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsView()
    }
}
