//
//  PayPalFilenames.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 08.10.2024..
//

import Foundation

enum PayPalFilenames: String {
    case authSuccess = "paypal_vault_session_auth_success_response"
    case authFail = "paypal_vault_session_auth_error_response"
    case setupTokenSuccess = "paypal_vault_setup_token_success_response"
    case getClientId = "paypal_vault_get_client_id_success_response"
}
