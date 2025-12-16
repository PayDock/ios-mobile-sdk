//
//  ConfigWidgetListView.swift
//  ExampleApp
//

import SwiftUI

struct ConfigWidgetListView: View {

    @StateObject var viewModel: ConfigVM = ConfigVM()

    let widgetItems: [ConfigWidgetItem] = {
        let globalItem = ConfigWidgetItem(widget: .global)
        let otherItems = [
            ConfigWidgetItem(widget: .card),
            ConfigWidgetItem(widget: .address),
            ConfigWidgetItem(widget: .giftCard),
            ConfigWidgetItem(widget: .paypal),
            ConfigWidgetItem(widget: .paypalVault),
            ConfigWidgetItem(widget: .afterPay),
            ConfigWidgetItem(widget: .colesPay),
            ConfigWidgetItem(widget: .clickToPay)
        ].sorted { $0.widget.title < $1.widget.title }

        return [globalItem] + otherItems
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
                    Text("Configure the settings and parameters for widgets on the Widget tab")
                        .font(.caption)

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
            .navigationTitle("Config")
            .listStyle(.plain)
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .background(Color(hex: "#EAE0D7")).ignoresSafeArea()
    }

    func stylizedNavigationLink(item: ConfigWidgetItem, destination: some View) -> some View {
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
                    .frame(width: 24.0, height: 24.0)
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

struct ConfigWidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigWidgetListView()
    }
}
