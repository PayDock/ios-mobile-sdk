//
//  SettingsVM.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 21.07.2023..
//

import Foundation
import SwiftUI
import MobileSDK

class SettingsVM: ObservableObject {

    // MARK: - Dependencies

    private let projectEnvironment: ProjectEnvironment

    // MARK: - Properties

    @Published var selectedEnvironment = ""
    var languages = ["English"]
    var selectedLanguage = "English"
    var accessToken = ""

    // MARK: - Initialization

    init(projectEnvironment: ProjectEnvironment = .shared) {
        self.projectEnvironment = projectEnvironment
    }

    func getProjectEnvironmentNames() -> [String] {
        return ProjectEnvironment.Environment.allCases.map { $0.rawValue }
    }

    func getSelectedEnvironmentEndpoint() -> String {
        return projectEnvironment.getEnvironmentEndpoint()
    }

    func copyAccessToken() {
        UIPasteboard.general.string = accessToken
    }

    func save() {
        ProjectEnvironment.accessToken = accessToken
    }

}
