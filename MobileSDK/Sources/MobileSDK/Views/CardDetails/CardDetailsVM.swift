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

    @Published var editingTextField1 = false
    @Published var editingTextField2 = false

    func setEditingTextField(focusedField: CardDetailsFocusable?) {
        guard let focusedField = focusedField else { return }
        switch focusedField {
        case .text1:
            editingTextField1 = true
            editingTextField2 = false

        case .text2:
            editingTextField1 = false
            editingTextField2 = true
        }
    }

    // MARK: - Methods

    func validateText1() {
      text1Valid.toggle() // Test validation.
    }

    func validateText2() {
      text2Valid.toggle() // Test validation.
    }

    enum CardDetailsFocusable: Hashable {
      case text1
      case text2
    }
    
}
