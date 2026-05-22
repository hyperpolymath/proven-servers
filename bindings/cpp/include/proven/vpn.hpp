// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file vpn.hpp
/// @brief VPN protocol types for proven-servers.

#ifndef PROVEN_VPN_HPP
#define PROVEN_VPN_HPP

#include <cstdint>

namespace proven {

/// @brief TunnelType matching the Idris2 ABI tags.
enum class TunnelType : uint8_t {
    Ipsec = 0,
    Wireguard = 1,
    Openvpn = 2,
    L2tp = 3
};

/// @brief TunnelPhase matching the Idris2 ABI tags.
enum class TunnelPhase : uint8_t {
    Idle = 0,
    Phase1Init = 1,
    Phase1Auth = 2,
    Phase1Done = 3,
    Phase2Negotiating = 4,
    Established = 5,
    Expired = 6
};

/// @brief EncryptionAlgorithm matching the Idris2 ABI tags.
enum class EncryptionAlgorithm : uint8_t {
    Aes128Cbc = 0,
    Aes256Cbc = 1,
    Aes128Gcm = 2,
    Aes256Gcm = 3,
    Chacha20Poly1305 = 4,
    NullCipher = 5
};

/// @brief IntegrityAlgorithm matching the Idris2 ABI tags.
enum class IntegrityAlgorithm : uint8_t {
    HmacSha1 = 0,
    HmacSha256 = 1,
    HmacSha384 = 2,
    HmacSha512 = 3,
    NoIntegrity = 4
};

/// @brief DhGroup matching the Idris2 ABI tags.
enum class DhGroup : uint8_t {
    Dh14 = 0,
    Ecp256 = 1,
    Ecp384 = 2,
    Curve25519 = 3
};

/// @brief SaLifecycle matching the Idris2 ABI tags.
enum class SaLifecycle : uint8_t {
    None = 0,
    Active = 1,
    Rekeying = 2,
    Expired = 3,
    Deleted = 4
};

/// @brief IkeVersion matching the Idris2 ABI tags.
enum class IkeVersion : uint8_t {
    V1 = 0,
    V2 = 1
};

/// @brief VpnError matching the Idris2 ABI tags.
enum class VpnError : uint8_t {
    AuthenticationFailed = 0,
    NoProposalChosen = 1,
    LifetimeExpired = 2,
    InvalidSpi = 3,
    ReplayDetected = 4,
    NegotiationTimeout = 5
};

} // namespace proven

#endif // PROVEN_VPN_HPP
