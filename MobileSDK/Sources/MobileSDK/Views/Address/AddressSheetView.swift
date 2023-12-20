//
//  AddressSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

//import SwiftUI
//
//public struct AddressSheetView: View {
//
//    @Binding var isPresented: Bool
//    let completion: (Result<Address, Error>) -> Void
//
//    public init(isPresented: Binding<Bool>,
//                completion: @escaping (Result<Address, Error>) -> Void) {
//        self._isPresented = isPresented
//        self.completion = completion
//    }
//
//    public var body: some View {
//        VStack {
//            Text("")
//        }
//        .bottomSheet(isPresented: $isPresented) {
//            AddressWidget(completion: completion)
//        }
//    }
//}
//
//struct AddressSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddressSheetView(isPresented: .constant(true), completion: { _ in })
//    }
//}
