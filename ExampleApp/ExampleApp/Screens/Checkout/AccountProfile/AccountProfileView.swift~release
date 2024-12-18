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
    
    @StateObject private var viewModel = AccountProfileVM()
    
    var body: some View {
            VStack{
                title()
                box()
                    .cornerRadius(10.0)
                    .padding()
                Spacer()
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
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
        PayPalSavePaymentSourceWidget(config: viewModel.getVaultConfig()) { result in
            switch result {
            case let .success(result):
                viewModel.createCustomer(payPalVaultResult: result)
            case let .failure(error):
                viewModel.handleError(error: error)
            }
        }
        .frame(height: 48.0)
        .padding()
        .padding(.bottom, 8)
    }
}

struct AccountProfileView_Previews: PreviewProvider {
    static var previews: some View {
        AccountProfileView()
    }
}
