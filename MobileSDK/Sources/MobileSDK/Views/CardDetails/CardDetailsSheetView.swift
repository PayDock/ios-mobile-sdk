//
//  CardDetailsSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

//public struct CardDetailsSheetView: View {
//
//    @State private var gatewayId: String
//    @Binding var isPresented: Bool
//    private let completion: (Result<String, CardDetailsError>) -> Void
//
//    public init(isPresented: Binding<Bool>,
//                gatewayId: String,
//                completion: @escaping (Result<String, CardDetailsError>) -> Void) {
//        self._isPresented = isPresented
//        self.gatewayId = gatewayId
//        self.completion = completion
//    }
//
//    public var body: some View {
//        VStack {
//            Text("")
//        }
//        .bottomSheet(isPresented: $isPresented) {
//            CardDetailsWidget(gatewayId: gatewayId, completion: completion)
//        }
//    }
//}
//
//struct CardDetailsSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardDetailsSheetView(isPresented: .constant(true), gatewayId: "a1234", completion: { _ in })
//    }
//}
