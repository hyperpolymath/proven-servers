// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file tls.hpp
/// @brief TLS protocol bindings for proven-servers.

#ifndef PROVEN_TLS_HPP
#define PROVEN_TLS_HPP

#include <cstdint>

namespace proven {

/// @brief TlsState matching the Idris2 ABI tags.
enum class TlsState : uint8_t {
    TlsIdle = 0,
    TlsClientHello = 1,
    TlsServerHello = 2,
    TlsNegotiating = 3,
    TlsEstablished = 4,
    TlsRenegotiating = 5,
    TlsShutdown = 6
};

/// @brief TlsVersion matching the Idris2 ABI tags.
enum class TlsVersion : uint8_t {
    Tls12 = 0,
    Tls13 = 1
};

/// @brief CipherSuite matching the Idris2 ABI tags.
enum class CipherSuite : uint8_t {
    AesGcm128Sha256 = 0,
    AesGcm256Sha384 = 1,
    ChaCha20Poly1305Sha256 = 2,
    AesCcm128Sha256 = 3
};

} // namespace proven

#endif // PROVEN_TLS_HPP
