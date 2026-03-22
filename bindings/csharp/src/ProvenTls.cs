// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TLS protocol bindings for proven-servers.

namespace Proven;

/// <summary>TlsState matching the Idris2 ABI tags (0-6).</summary>
public enum TlsState : byte
{
    TlsIdle = 0,
    TlsClientHello = 1,
    TlsServerHello = 2,
    TlsNegotiating = 3,
    TlsEstablished = 4,
    TlsRenegotiating = 5,
    TlsShutdown = 6
}

/// <summary>TlsVersion matching the Idris2 ABI tags (0-1).</summary>
public enum TlsVersion : byte
{
    Tls12 = 0,
    Tls13 = 1
}

/// <summary>CipherSuite matching the Idris2 ABI tags (0-3).</summary>
public enum CipherSuite : byte
{
    AesGcm128Sha256 = 0,
    AesGcm256Sha384 = 1,
    ChaCha20Poly1305Sha256 = 2,
    AesCcm128Sha256 = 3
}
