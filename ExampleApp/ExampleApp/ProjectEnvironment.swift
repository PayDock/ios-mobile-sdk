//
//  Environment.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

struct ProjectEnvironment {

    static let shared = ProjectEnvironment()

    /// Main environment variable. Needs to be set externally to the correct value from the main app/extension target upon launch.
    /// Defaults to .production if not set explicitly
    private(set) var environment: Environment = .production

    private init() {
        #if PRODUCTION
        self.environment = .production
        #elseif SANDBOX
        self.environment = .sandbox
        #elseif STAGING
        self.environment = .staging
        #else
        fatalError("Error setting up environment!")
        #endif

        print("[ENVIRONMENT] Working environment set to \(environment)")
    }

    enum Environment: String {
        case production, sandbox, staging
    }
}
