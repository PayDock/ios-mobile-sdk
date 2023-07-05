//
//  ContentViewVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import Foundation
import MobileSDK

class ContentVM: ObservableObject {
    
    private let mobileSDKMain: MobileSDKMain
    
    init(mobileSDKMain: MobileSDKMain = MobileSDKMain()) {
        self.mobileSDKMain = mobileSDKMain
    }
    
    func doSomething() {
        mobileSDKMain.printSuccess()
    }
    
}
