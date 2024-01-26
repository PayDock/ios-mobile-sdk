//
//  CheckoutView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 18.07.2023..
//

import SwiftUI

struct CheckoutView: View {

    @State var isSheetPresented = false

    let items: [BasketItem] = [
        .init(
            id: "1",
            title: "ThinkPad X1 Yoga Gen 7",
            description: "ThinkPad X1 Yoga Gen 7\n14” Intel 2 in 1 Laptop",
            price: "£3,299", 
            image: "demoItem1"
        ),
        .init(
            id: "2",
            title: "Galaxy S23 Ultra",
            description: "SM-S918BZGHSEK\n512 GB｜12 GB｜Green",
            price: "£2,199",
            image: "demoItem2"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Your cart")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(items) {
                    BasketItemView(item: $0)
                        .padding(.bottom, 16)
                }
                Spacer()
                VStack (spacing: 16) {
                    TotalRowView(title: "Subtotal", value: "£5,498", color: .gray)
                    TotalRowView(title: "Shipping", value: "Free", color: .gray)
                    Divider()
                    TotalRowView(title: "Total", value: "£5,498", color: .black)
                }
                Button("Checkout") {
                    isSheetPresented = true
                }
                .foregroundStyle(.white)
                .font(Font.system(size: 16, weight: .semibold))
                .frame(height: 48)
                .frame(maxWidth:.infinity)
                .background(Color(hex: "6750A4"))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            }.padding(16)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Image("demoLogo")
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "person")
                    }
                }
                .bottomSheet(isPresented: $isSheetPresented) {
                    CheckoutPaymentSheet()
                }
        }
    }
}

struct TotalRowView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundStyle(color)
        }
    }
}

struct BasketItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let price: String
    let image: String
}

struct BasketItemView: View {
    let item: BasketItem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(item.image)
                .padding(16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(spacing: 8) {
                Text(item.title)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(item.description)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(item.price)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "EDEDFF"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}
