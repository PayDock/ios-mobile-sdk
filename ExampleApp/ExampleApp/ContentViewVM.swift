//
//  ContentViewVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import Foundation
import MobileSDK

class ContentVM: ObservableObject {
    
    private let mobileSDK: MobileSDK
    
    init(mobileSDK: MobileSDK = MobileSDK()) {
        self.mobileSDK = mobileSDK
    }
    
    func doSomething() {
        mobileSDK.printSuccess()
    }
    
}
