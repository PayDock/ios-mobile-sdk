//
//  GiftCardWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct GiftCardWidgetView: View {

    @State var showAlert = false
    @State var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                GiftCardWidget( config: GiftCardWidgetConfig( accessToken: ProjectEnvironment.shared.getWidgetAccessToken(), storePin: false),  appearance: getAppearance()) { result in
                    switch result {
                    case .success(let giftCardResult): self.alertMessage = giftCardResult.token
                    case .failure(let error): self.alertMessage = error.localizedDescription
                    }
                    showAlert = true
                }
            }
            .alert("Gift Card", isPresented: $showAlert, actions: {}, message: {
                Text(alertMessage)
            })
        }
    }
    
    private func getAppearance() -> GiftCardWidgetAppearance {
        // TODO: - For theme testing - pull the data from Style screen once it's implemented and remove test code
        return GiftCardWidgetAppearance()
//        let appearance = GiftCardWidgetAppearance(title: .init(text: .init(textColor: .pink)), textField: .init(colors: .init(active: .orange), dimensions: .init(cornerRadius: 20, borderWidth: 5), fonts: .init()), actionButton: .init(colors: .init(background: .blue,text: .purple, border: .red)), toolbarButton: .init())
//        return appearance
    }
}

struct GiftCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidgetView()
    }
}

