// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file authserver.hpp
/// @brief Auth protocol types for proven-servers.

#ifndef PROVEN_AUTHSERVER_HPP
#define PROVEN_AUTHSERVER_HPP

#include <cstdint>

namespace proven {

/// @brief AuthMethod matching the Idris2 ABI tags.
enum class AuthMethod : uint8_t {
    Password = 0,
    Certificate = 1,
    OAuth2 = 2,
    Saml = 3,
    Fido2 = 4,
    Kerberos = 5,
    Ldap = 6,
    Radius = 7
};

/// @brief TokenType matching the Idris2 ABI tags.
enum class TokenType : uint8_t {
    Access = 0,
    Refresh = 1,
    Id = 2,
    Api = 3
};

/// @brief AuthResult matching the Idris2 ABI tags.
enum class AuthResult : uint8_t {
    Success = 0,
    InvalidCredentials = 1,
    AccountLocked = 2,
    AccountExpired = 3,
    MfaRequired = 4,
    IpBlocked = 5
};

/// @brief MfaMethod matching the Idris2 ABI tags.
enum class MfaMethod : uint8_t {
    Totp = 0,
    Sms = 1,
    Push = 2,
    Fido2Mfa = 3,
    Email = 4
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Active = 0,
    Expired = 1,
    Revoked = 2,
    Locked = 3
};

} // namespace proven

#endif // PROVEN_AUTHSERVER_HPP
