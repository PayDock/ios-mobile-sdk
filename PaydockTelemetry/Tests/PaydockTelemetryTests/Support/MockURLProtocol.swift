//
//  MockURLProtocol.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Answers every request of a session that lists it with a scripted response or error, and records each request with
/// its body. No network.
final class MockURLProtocol: URLProtocol {
    enum Reply {
        case response(status: Int, headers: [String: String], body: Data)
        case error(URLError.Code)
        /// Never answers.
        case silence
    }

    struct Request {
        let url: URL?
        let method: String?
        let headers: [String: String]
        let body: Data
    }

    private static let lock = NSLock()
    private static var reply: Reply = .response(status: 204, headers: [:], body: Data())
    private static var requestLog: [Request] = []

    static var requests: [Request] {
        lock.lock()
        defer { lock.unlock() }
        return requestLog
    }

    static func answer(_ reply: Reply) {
        lock.lock()
        self.reply = reply
        lock.unlock()
    }

    static func reset() {
        lock.lock()
        reply = .response(status: 204, headers: [:], body: Data())
        requestLog = []
        lock.unlock()
    }

    /// A NetworkingLib client whose own session routes every request through this protocol.
    static func makeClient() -> any HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return SessionClient(session: URLSession(configuration: configuration))
    }

    override static func canInit(with request: URLRequest) -> Bool { true }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lock.lock()
        Self.requestLog.append(Request(url: request.url, method: request.httpMethod,
                                       headers: request.allHTTPHeaderFields ?? [:], body: Self.body(of: request)))
        let reply = Self.reply
        Self.lock.unlock()

        switch reply {
        case let .response(status, headers, body):
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        case let .error(code):
            client?.urlProtocol(self, didFailWithError: URLError(code))
        case .silence:
            break
        }
    }

    override func stopLoading() {}

    /// The body as sent: a session hands it to the protocol as a stream.
    private static func body(of request: URLRequest) -> Data {
        if let body = request.httpBody {
            return body
        }
        guard let stream = request.httpBodyStream else {
            return Data()
        }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 16_384)
        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: buffer.count)
            guard read > 0 else {
                break
            }
            data.append(buffer, count: read)
        }
        return data
    }

    private struct SessionClient: HTTPClient {
        let session: URLSession
        var sslPinningManager: SSLPinningManager? { nil }
    }
}
