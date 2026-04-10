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
            ConfigWidgetItem(widget: .clickToPay),
            ConfigWidgetItem(widget: .applePay),
            ConfigWidgetItem(widget: .zip)
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
                    stylizedNavigationLink(item: item, destination: item.destination(viewModel: viewModel))
                }

                VStack(alignment: .center, spacing: 4) {
                    Text(appVersionString)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color(hex: "#EAE0D7"))
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

    private var appVersionString: AttributedString {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        var attributedString = AttributedString("Version ")

        var versionText = AttributedString(version)
        versionText.font = .caption.bold()
        attributedString.append(versionText)

        attributedString.append(AttributedString(" (Build "))

        var buildText = AttributedString(build)
        buildText.font = .caption.bold()
        attributedString.append(buildText)

        attributedString.append(AttributedString(")"))

        return attributedString
    }
}

struct ConfigWidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigWidgetListView()
    }
}
