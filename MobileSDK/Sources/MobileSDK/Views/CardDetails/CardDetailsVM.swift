//
//  CardDetailsVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 02.08.2023..
//

import Foundation

class CardDetailsVM: ObservableObject {

    @Published var hint1 = "Hint 1"
    @Published var hint2 = "Hint 2"

    let placeholder1 = "Placeholder 1"
    let placeholder2 = "Placeholder 2"

    var text1: String = ""
    var text2: String = ""

    @Published var text1Valid = true {
      didSet {
        hint1 = text1Valid ? "Hint 1" : "Error 1"
      }
    }
    @Published var text2Valid = true {
      didSet {
        hint2 = text2Valid ? "Hint 2" : "Error 2"
      }
    }
//
//    var editingTextField1 = false {
//        didSet {
//            guard editingTextField1 != oldValue else {
//                return
//            }
//            if editingTextField1 {
//                editingTextField2 = false
//            }
//        }
//    }
//
//    var editingTextField2 = false {
//        didSet {
//            guard editingTextField2 != oldValue else {
//                return
//            }
//            if editingTextField2 {
//                editingTextField1 = false
//            }
//        }
//    }

//    func cancelEditing() {
//        editingTextField1 = false
//        editingTextField2 = false
//    }

    func validateText1() {
      text1Valid.toggle() // Demonstrative dummy validation.
    }

    func validateText2() {
      text2Valid.toggle() // Demonstrative dummy validation.
    }
    
}
