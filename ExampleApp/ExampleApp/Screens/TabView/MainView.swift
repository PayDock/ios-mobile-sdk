//
//  MainView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 18.07.2023..
//

import SwiftUI

struct MainView: View {

    @State private var selection: Int = 0

    init() {
        UITabBar.appearance().backgroundColor = .white
    }

    var body: some View {
        TabView(selection: $selection) {
            CheckoutView()
                .tabItem {
                    Label("Checkout", image: selection == 0 ? "cart-active" : "cart")
                }
                .tag(0)

            WidgetsView()
                .tabItem {
                    Label("Widgets", image: selection == 1 ? "grid-layout-active" : "grid-layout")
                }
                .tag(1)

            StyleWidgetListView()
                .tabItem {
                    Label("Style", image: selection == 2 ? "paintbucket-active" : "paintbucket")
                }
                .tag(2)
                .toolbarBackground(Color.white, for: .tabBar)
        }
        .toolbarBackground(Color.red, for: .tabBar)
        .accentColor(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
