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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                GiftCardWidget(config: GiftCardWidgetConfig(accessToken: ProjectEnvironment.shared.getWidgetAccessToken(), storePin: false),
                               appearance: getAppearance()) { result in
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
        let appearance = StyleThemeManager.getAppearance(for: .giftCard, isDarkMode: colorScheme == .dark, as: GiftCardWidgetAppearance.self, shouldCreateDefaultIfNeeded: false)
        return appearance ?? GiftCardWidgetAppearance()
    }
}

struct GiftCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidgetView()
    }
}

