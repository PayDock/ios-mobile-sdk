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

        print("[ENVIRONMENT] Working environment set to \(environment)")
    }

    enum Environment: String, CaseIterable {
        case production, sandbox, staging
    }

    func getEnvironmentEndpoint() -> String {
        switch environment {
            // TODO: - Change endpoint for prod and staging. All environments currently use sandbox endpopint
        case .production: return "api-sandbox.paydock.com"
//        case .production: return "api.paydock.com"
        case .sandbox: return "api-sandbox.paydock.com"
            // TODO: - Change endpoint for prod and staging. All environments currently use sandbox endpopint
        case .staging: return "api-sandbox.paydock.com"
//        case .staging: return "apista.paydock.com"
        }
    }

    func getPublicKey() -> String {
        switch environment {
            // TODO: - Change tokens for prod and staging. All environments currently use Sanbox tokens
        case .production: return "b3e5eafcbf585cd298fc66fdc6b449505e64bf8d"
        case .sandbox: return "b3e5eafcbf585cd298fc66fdc6b449505e64bf8d"
        case .staging: return "b3e5eafcbf585cd298fc66fdc6b449505e64bf8d"
        }
    }

    func getSecretKey() -> String {
        switch environment {
            // TODO: - Change tokens for prod and staging. All environments currently use Sanbox tokens
        case .production: return "2d7fa96060b38a942a5fe97f244580a5322971b5"
        case .sandbox: return "2d7fa96060b38a942a5fe97f244580a5322971b5"
        case .staging: return "2d7fa96060b38a942a5fe97f244580a5322971b5"
        }
    }
}
