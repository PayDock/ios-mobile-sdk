//
//  AccountProfileView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct AccountProfileView: View {
    
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    var body: some View {
            VStack{
                title()
                box()
                    .cornerRadius(10.0)
                    .padding()
                Spacer()
            }
            .alert(alertTitle, isPresented: $showAlert, actions: {}, message: {
                Text(alertMessage)
            })
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("My Account")
    }
    
    private func title() -> some View {
        Text("Saved payment method")
            .font(.system(size: 18))
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .leading, .trailing], 18)
    }
    
    private func box() -> some View {
        VStack {
            HStack {
                Image("payPal")
                    .padding([.top, .leading, .trailing], 16)
                Spacer()
            }
            Text("Link your PayPal account to use method next time you shop")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding([.leading, .trailing], 16)
            vaultWidget()
        }
        .background(Color.gray.opacity(0.1))
    }
    
    private func vaultWidget() -> some View {
        PayPalSavePaymentSourceWidget(config: getVaultConfig()) { result in
            switch result {
            case let .success(payPalVaultResult):
                handleSuccess(result: payPalVaultResult)
            case let .failure(error):
                handleError(error: error)
            }
        }
        .frame(height: 48.0)
        .padding()
        .padding(.bottom, 8)
    }
    
    private func getVaultConfig() -> PayPalVaultConfig {
        let config = PayPalVaultConfig(
            accessToken: ProjectEnvironment.shared.getAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "")
        return config
    }
    
    private func handleError(error: PayPalVaultError) {
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }

    private func handleSuccess(result: PayPalVaultResult) {
        alertTitle = "Success"
        alertMessage = "Token:\n \(result.token)\n\n Email:\n \(result.email)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }
}

struct AccountProfileView_Previews: PreviewProvider {
    static var previews: some View {
        AccountProfileView()
    }
}
