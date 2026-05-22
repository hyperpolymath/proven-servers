// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file radius.hpp
/// @brief RADIUS protocol types for proven-servers.

#ifndef PROVEN_RADIUS_HPP
#define PROVEN_RADIUS_HPP

#include <cstdint>

namespace proven {

/// @brief PacketType matching the Idris2 ABI tags.
enum class PacketType : uint8_t {
    AccessRequest = 0,
    AccessAccept = 1,
    AccessReject = 2,
    AccountingRequest = 3,
    AccountingResponse = 4,
    AccessChallenge = 5
};

/// @brief AttributeType matching the Idris2 ABI tags.
enum class AttributeType : uint8_t {
    UserName = 0,
    UserPassword = 1,
    NasIpAddress = 2,
    NasPort = 3,
    ServiceType = 4,
    FramedProtocol = 5,
    FramedIpAddress = 6,
    ReplyMessage = 7,
    SessionTimeout = 8
};

/// @brief ServiceType matching the Idris2 ABI tags.
enum class ServiceType : uint8_t {
    Login = 0,
    Framed = 1,
    CallbackLogin = 2,
    CallbackFramed = 3,
    Outbound = 4,
    Administrative = 5
};

/// @brief AuthMethod matching the Idris2 ABI tags.
enum class AuthMethod : uint8_t {
    Pap = 0,
    Chap = 1,
    Mschap = 2,
    Mschapv2 = 3,
    Eap = 4
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Authenticating = 1,
    Authorized = 2,
    Rejected = 3,
    Challenged = 4,
    Accounting = 5,
    Complete = 6
};

/// @brief RadiusResult matching the Idris2 ABI tags.
enum class RadiusResult : uint8_t {
    Ok = 0,
    Err = 1,
    InvalidParam = 2,
    PoolExhausted = 3,
    BadSecret = 4
};

} // namespace proven

#endif // PROVEN_RADIUS_HPP
