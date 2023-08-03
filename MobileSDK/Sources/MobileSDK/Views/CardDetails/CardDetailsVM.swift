//
//  CardDetailsVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 02.08.2023..
//

import Foundation

class CardDetailsVM: ObservableObject {

    // MARK: - Properties

    @Published var hint1 = "Hint 1"
    @Published var hint2 = "Hint 2"

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

    let placeholder1 = "Placeholder 1"
    let placeholder2 = "Placeholder 2"

    var text1: String = ""
    var text2: String = ""

    var editingTextField1 = false {
        didSet {
            guard editingTextField1 != oldValue else { return }

            if editingTextField1 {
                editingTextField2 = false
            } else {
                validateText1()
            }
        }
    }

    var editingTextField2 = false {
        didSet {
            guard editingTextField2 != oldValue else { return }

            if editingTextField2 {
                editingTextField1 = false
            } else {
                validateText2()
            }
        }
    }

    // MARK: - Methods

    func validateText1() {
      text1Valid.toggle() // Test validation.
    }

    func validateText2() {
      text2Valid.toggle() // Test validation.
    }
    
}
