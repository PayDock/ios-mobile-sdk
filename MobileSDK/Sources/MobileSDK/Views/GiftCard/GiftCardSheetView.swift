//
//  GiftCardSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.11.2023..
//

//import SwiftUI
//
//public struct GiftCardSheetView: View {
//
//    // MARK: - Properties
//
//    @Binding var isPresented: Bool
//    @State var storePin: Bool
//    private let completion: (Result<String, Error>) -> Void
//
//    // MARK: - Initialisation
//
//    public init(storePin: Bool = true,
//                isPresented: Binding<Bool>,
//                completion: @escaping (Result<String, Error>) -> Void) {
//        self.storePin = storePin
//        self._isPresented = isPresented
//        self.completion = completion
//    }
//
//    public var body: some View {
//        VStack {
//            Text("")
//        }
//        .bottomSheet(isPresented: $isPresented) {
//            GiftCardWidget(storePin: storePin) { result in
//                switch result {
//                case .success(let token): break
//                case .failure(let error): break
//                }
//            }
//        }
//    }
//}
//
//struct GiftCardSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        GiftCardSheetView(
//            storePin: true,
//            isPresented: .constant(true),
//            completion: { _ in })
//    }
//}
