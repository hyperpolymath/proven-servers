// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server protocol types for proven-servers.

/// AuthScheme matching the Idris2 ABI tags.
public enum AuthScheme: UInt8, CaseIterable, Sendable {
    case apiKey = 0
    case bearer = 1
    case basic = 2
    case oAuth2 = 3
    case hmac = 4
    case mtls = 5
}

/// RateLimitStrategy matching the Idris2 ABI tags.
public enum RateLimitStrategy: UInt8, CaseIterable, Sendable {
    case fixedWindow = 0
    case slidingWindow = 1
    case tokenBucket = 2
    case leakyBucket = 3
}

/// ApiVersion matching the Idris2 ABI tags.
public enum ApiVersion: UInt8, CaseIterable, Sendable {
    case v1 = 0
    case v2 = 1
    case v3 = 2
    case latest = 3
    case deprecated = 4
}

/// ResponseFormat matching the Idris2 ABI tags.
public enum ResponseFormat: UInt8, CaseIterable, Sendable {
    case json = 0
    case xml = 1
    case protobuf = 2
    case messagePack = 3
}

/// GatewayError matching the Idris2 ABI tags.
public enum GatewayError: UInt8, CaseIterable, Sendable {
    case unauthorized = 0
    case rateLimited = 1
    case notFound = 2
    case badRequest = 3
    case serviceUnavailable = 4
    case circuitOpen = 5
}
