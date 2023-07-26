//
//  StyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 19.07.2023..
//

import Foundation
import SwiftUI

class StyleVM: ObservableObject {

    @Published var primaryColor = "000000"
    @Published var secondaryColor = "FFFFFF"

    @Published var fontName = "San Francisco"

    @Published var cornerRadius = "0"
    @Published var padding = "0"

    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }

    func saveStyle() {
        
    }
}
