//
//  WidgetsView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.07.2023..
//

import SwiftUI

struct WidgetsView: View {

    @StateObject private var viewModel = WidgetsVM()

    init() {
        styleNavigation()
    }
    
    let widgetItems: [WidgetItem] = [
        WidgetItem(destination: AnyView(CardDetailsWidgetView()), title: "Card Details", subtitle: "Tokenise card details"),
        WidgetItem(destination: AnyView(AddressWidgetView()), title: "Address", subtitle: "Capture customer address form"),
        WidgetItem(destination: AnyView(ApplePayWidgetView()), title: "Apple Pay", subtitle: "Standalone Apple Pay flow"),
        WidgetItem(destination: AnyView(PayPalWidgetView()), title: "PayPal", subtitle: "Standalone PayPal button"),
        WidgetItem(destination: AnyView(GiftCardWidgetView()), title: "Gift Card", subtitle: "Standalone Gift Card form"),
        WidgetItem(destination: AnyView(Integrated3DSWidgetView()), title: "Integrated 3DS", subtitle: "Integrated 3DS widget"),
        WidgetItem(destination: AnyView(Standalone3DSWidgetView()), title: "Standalone 3DS", subtitle: "Standalone 3DS widget"),
        WidgetItem(destination: AnyView(FlyPayWidgetView()), title: "FlyPay", subtitle: "Standalone FlyPay widget"),
        WidgetItem(destination: AnyView(AfterpayWidgetView()), title: "Afterpay", subtitle: "Standalone Afterpay widget"),
        WidgetItem(destination: AnyView(ClickToPayWidgetView()), title: "Click to Pay", subtitle: "ClickToPay flow")
    ].sorted { $0.title < $1.title }

    var body: some View {
        NavigationStack {
            List(widgetItems) { item in
                stylizedNavigationLink(destination: item.destination, title: item.title, subtitle: item.subtitle)
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

struct WidgetItem: Identifiable {
    let id = UUID()
    let destination: AnyView
    let title: String
    let subtitle: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsView()
    }
}
