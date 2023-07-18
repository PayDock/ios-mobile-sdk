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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .onAppear {

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsView()
    }
}
