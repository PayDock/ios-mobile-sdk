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
                stylizedNavigationLink(destination: CardDetailsWidgetView(), title: "Card Details", subtitle: "Tokenise card details")
                stylizedNavigationLink(destination: AddressWidgetView(), title: "Address", subtitle: "Capture customer address form")
                stylizedNavigationLink(destination: ApplePayWidgetView(), title: "Apple Pay", subtitle: "Standalone Apple Pay flow")
                stylizedNavigationLink(destination: PayPalWidgetView(), title: "PayPal", subtitle: "Standalone PayPal button")
                stylizedNavigationLink(destination: GiftCardWidgetView(), title: "Gift Card", subtitle: "Standalone Gift Card form")
                stylizedNavigationLink(destination: Integrated3DSWidgetView(), title: "Integrated 3DS", subtitle: "Integrated 3DS widget")
                stylizedNavigationLink(destination: Standalone3DSWidgetView(), title: "Standalone 3DS", subtitle: "Standalone 3DS widget")
            }
            .navigationTitle("Widgets")
            .background(Color(hex: "#EAE0D7"))
            .listStyle(.plain)

        }
        .foregroundColor(.black)
        .background(Color(hex: "#EAE0D7"))
    }

    func stylizedNavigationLink(destination: some View, title: String, subtitle: String) -> some View {
        return NavigationLink(destination: destination) {
            cell(title: title, subtitle: subtitle)
        }
        .listRowSeparatorTint(.black)
        .listSectionSeparator(.hidden, edges: .top)
        .listRowBackground(Color(hex: "#EAE0D7"))
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
