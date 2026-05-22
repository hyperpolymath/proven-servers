// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TLS protocol types for proven-servers.

/// TlsState matching the Idris2 ABI tags.
public enum TlsState: UInt8, CaseIterable, Sendable {
    case tlsIdle = 0
    case tlsClientHello = 1
    case tlsServerHello = 2
    case tlsNegotiating = 3
    case tlsEstablished = 4
    case tlsRenegotiating = 5
    case tlsShutdown = 6
}

/// TlsVersion matching the Idris2 ABI tags.
public enum TlsVersion: UInt8, CaseIterable, Sendable {
    case tls12 = 0
    case tls13 = 1
}

/// CipherSuite matching the Idris2 ABI tags.
public enum CipherSuite: UInt8, CaseIterable, Sendable {
    case aesGcm128Sha256 = 0
    case aesGcm256Sha384 = 1
    case chaCha20Poly1305Sha256 = 2
    case aesCcm128Sha256 = 3
}
