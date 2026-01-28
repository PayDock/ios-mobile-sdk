//
//  StyleWidgetListView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import SwiftUI

struct StyleWidgetListView: View {

    @StateObject var viewModel: StyleVM = StyleVM()

    let widgetItems: [StyleWidgetItem] = {
        let allWidgets = StyleWidgetItem(widget: .all)

        let otherWidgets = [
            StyleWidgetItem(widget: .card),
            StyleWidgetItem(widget: .address),
            StyleWidgetItem(widget: .applePay),
            StyleWidgetItem(widget: .paypal),
            StyleWidgetItem(widget: .giftCard),
            StyleWidgetItem(widget: .mpgs3ds),
            StyleWidgetItem(widget: .standalone3ds),
            StyleWidgetItem(widget: .colesPay),
            StyleWidgetItem(widget: .afterPay),
            StyleWidgetItem(widget: .clickToPay),
            StyleWidgetItem(widget: .paypalVault),
            StyleWidgetItem(widget: .zip)
        ].sorted { $0.widget.title < $1.widget.title }

        return [allWidgets] + otherWidgets
    }()

    // MARK: - Initialization

    init() {
        styleNavigation()
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading) {
                    Text("Customise the look and feel of the widgets on the Widget tab")
                        .font(.caption)

                    StyleDarkModeView()
                        .environmentObject(viewModel)
                        .listRowBackground(Color(hex: "#EAE0D7"))
                        .listRowSeparatorTint(.clear)

                    Text("Select Widget")
                        .font(.title3)
                        .padding(.vertical, 16)

                }
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color(hex: "#EAE0D7"))

                ForEach(widgetItems) { item in
                    stylizedNavigationLink(item: item, destination: item.destination)
                }
            }
            .navigationTitle("Style")
            .listStyle(.plain)
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .background(Color(hex: "#EAE0D7")).ignoresSafeArea()
    }

    func stylizedNavigationLink(item: StyleWidgetItem, destination: some View) -> some View {
        return NavigationLink(destination: destination.environmentObject(viewModel)) {
            cell(icon: item.widget.icon, title: item.widget.title)
        }
        .listRowSeparatorTint(.black)
        .listSectionSeparator(.hidden, edges: .top)
        .listRowBackground(Color(hex: "#EAE0D7"))
    }

    func cell(icon: Image, title: String) -> some View {
        HStack {
            HStack {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.title2)
                    .padding(.vertical, 6)
                Spacer()
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

struct StyleWidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        StyleWidgetListView()
    }
}
