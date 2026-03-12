//
//  WidgetsView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

struct WidgetsView: View {

    init() {
        styleNavigation()
    }

    let widgetItems: [WidgetItem] = [
        WidgetItem(destination: AnyView(CardDetailsExampleView()), title: "Card Details", subtitle: "Tokenise card details"),
        WidgetItem(destination: AnyView(AddressExampleView()), title: "Address", subtitle: "Capture customer address form"),
        WidgetItem(destination: AnyView(ApplePayExampleView()), title: "Apple Pay", subtitle: "Standalone Apple Pay flow"),
        WidgetItem(destination: AnyView(PayPalExampleView()), title: "PayPal", subtitle: "Standalone PayPal button"),
        WidgetItem(destination: AnyView(GiftCardExampleView()), title: "Gift Card", subtitle: "Standalone Gift Card form"),
        WidgetItem(destination: AnyView(MPGS3dsExampleView()), title: "MPGS 3DS", subtitle: "MPGS Integrated 3DS widget"),
        WidgetItem(destination: AnyView(Standalone3DSExampleView()), title: "Standalone 3DS", subtitle: "Standalone 3DS widget"),
        WidgetItem(destination: AnyView(ColesPayExampleView()), title: "Coles Pay", subtitle: "Standalone Coles Pay widget"),
        WidgetItem(destination: AnyView(AfterpayExampleView()), title: "Afterpay", subtitle: "Standalone Afterpay widget"),
        WidgetItem(destination: AnyView(ClickToPayExampleView()), title: "Click to Pay", subtitle: "ClickToPay flow"),
        WidgetItem(destination:
                    AnyView(PayPalVaultExampleView()), title: "PayPal Vault", subtitle: "Link your PayPal account for faster checkout"),
        WidgetItem(destination: AnyView(ZipExampleView()), title: "Zip", subtitle: "Standalone Zip payment button")
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
