//
//  SSLPinningManager.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import CommonCrypto

final class SSLPinningManager: NSObject {

    // MARK: - Properties

    private let publicKeyHash = ProjectEnvironment.shared.getSslPublicKeyHash()
    private let rsa2048Asn1Header:[UInt8] = [0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00];

    // MARK: - Helpers

    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)

        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        keyWithHeader.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress!, CC_LONG(buffer.count), &hash)
        }

        return Data(hash).base64EncodedString()
    }

}

// MARK: - URLSessionDelegate

extension SSLPinningManager: URLSessionDelegate {

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certs = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let serverCertificate = certs.first else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }

        let serverPublicKey = SecCertificateCopyKey(serverCertificate)
        let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil)!
        let data: Data = serverPublicKeyData as Data
        let serverHashKey = sha256(data: data)
        let publicKeyLocal = publicKeyHash

        if (serverHashKey == publicKeyLocal) {
            completionHandler(.useCredential, URLCredential(trust:serverTrust))
            return

        } else {
            completionHandler(.cancelAuthenticationChallenge,nil)
        }
    }

}
