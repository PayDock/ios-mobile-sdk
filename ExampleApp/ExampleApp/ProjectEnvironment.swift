//
//  Environment.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
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
    }

    enum Environment: String, CaseIterable {
        case production, sandbox, staging
    }

    func getEnvironmentEndpoint() -> String {
        switch environment {
        case .production: return "api.paydock.com"
        case .sandbox: return "api-sandbox.paydock.com"
        case .staging: return "apista.paydock.com"
        }
    }

    func getPublicKey() -> String {
        // Enter your own public keys
        switch environment {
        case .production: return ""
        case .sandbox: return ""
        case .staging: return ""
        }
    }

    func getSecretKey() -> String {
        // Enter your own secret keys
        switch environment {
        case .production: return ""
        case .sandbox: return ""
        case .staging: return ""
        }
    }
}
