// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file sshbastion.hpp
/// @brief SSH Bastion protocol bindings for proven-servers.

#ifndef PROVEN_SSHBASTION_HPP
#define PROVEN_SSHBASTION_HPP

#include <cstdint>

namespace proven {

/// @brief BastionState matching the Idris2 ABI tags.
enum class BastionState : uint8_t {
    BastionConnected = 0,
    BastionKeyExchanged = 1,
    BastionAuthenticated = 2,
    BastionChannelOpen = 3,
    BastionActive = 4,
    BastionClosed = 5
};

/// @brief KexMethod matching the Idris2 ABI tags.
enum class KexMethod : uint8_t {
    KexCurve25519 = 0,
    KexDhGroup14 = 1,
    KexDhGroup16 = 2,
    KexEcdhP256 = 3,
    KexEcdhP384 = 4
};

/// @brief AuthMethod matching the Idris2 ABI tags.
enum class AuthMethod : uint8_t {
    AuthPublicKey = 0,
    AuthPassword = 1,
    AuthKeyboard = 2,
    AuthCertificate = 3
};

/// @brief ChannelType matching the Idris2 ABI tags.
enum class ChannelType : uint8_t {
    ChannelSession = 0,
    ChannelDirectTcpIp = 1,
    ChannelForwardedTcpIp = 2,
    ChannelSubsystem = 3
};

/// @brief ChannelState matching the Idris2 ABI tags.
enum class ChannelState : uint8_t {
    ChannelOpening = 0,
    ChannelOpen = 1,
    ChannelClosing = 2,
    ChannelClosed = 3
};

/// @brief DisconnectReason matching the Idris2 ABI tags.
enum class DisconnectReason : uint8_t {
    DisconnectHostNotAllowed = 0,
    DisconnectProtocolError = 1,
    DisconnectKeyExchangeFailed = 2,
    DisconnectAuthFailed = 3,
    DisconnectServiceNotAvailable = 4,
    DisconnectByApplication = 5,
    DisconnectTooManyConnections = 6
};

} // namespace proven

#endif // PROVEN_SSHBASTION_HPP
