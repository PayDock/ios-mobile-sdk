//
//  CardDetailsVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 02.08.2023..
//

import Foundation

class CardDetailsVM: ObservableObject {

    var text1: String = ""
    var text2: String = ""

    var editingTextField1 = false {
        didSet {
            guard editingTextField1 != oldValue else {
                return
            }
            if editingTextField1 {
                editingTextField2 = false
            }
        }
    }

    var editingTextField2 = false {
        didSet {
            guard editingTextField2 != oldValue else {
                return
            }
            if editingTextField2 {
                editingTextField1 = false
            }
        }
    }

    func cancelEditing() {
        editingTextField1 = false
        editingTextField2 = false
    }
}
