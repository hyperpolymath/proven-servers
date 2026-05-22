// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Proxy protocol types for proven-servers.

/// ProxyMode matching the Idris2 ABI tags.
public enum ProxyMode: UInt8, CaseIterable, Sendable {
    case forward = 0
    case reverse = 1
}

/// HopByHopHeader matching the Idris2 ABI tags.
public enum HopByHopHeader: UInt8, CaseIterable, Sendable {
    case connection = 0
    case keepAlive = 1
    case proxyAuth = 2
    case proxyAuthz = 3
    case te = 4
    case trailers = 5
    case transferEncoding = 6
    case upgrade = 7
}

/// CacheDirective matching the Idris2 ABI tags.
public enum CacheDirective: UInt8, CaseIterable, Sendable {
    case noCache = 0
    case noStore = 1
    case maxAge = 2
    case `public` = 3
    case `private` = 4
    case mustRevalidate = 5
}

/// ProxyError matching the Idris2 ABI tags.
public enum ProxyError: UInt8, CaseIterable, Sendable {
    case badGateway = 0
    case gatewayTimeout = 1
    case upstreamRefused = 2
    case upstreamTls = 3
}
