// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file tacacs.hpp
/// @brief TACACS+ protocol types for proven-servers.

#ifndef PROVEN_TACACS_HPP
#define PROVEN_TACACS_HPP

#include <cstdint>

namespace proven {

/// @brief PacketType matching the Idris2 ABI tags.
enum class PacketType : uint8_t {
    Authentication = 0,
    Authorization = 1,
    Accounting = 2
};

/// @brief AuthenType matching the Idris2 ABI tags.
enum class AuthenType : uint8_t {
    Ascii = 0,
    Pap = 1,
    Chap = 2,
    MsChapV1 = 3,
    MsChapV2 = 4
};

/// @brief AuthenAction matching the Idris2 ABI tags.
enum class AuthenAction : uint8_t {
    Login = 0,
    ChangePass = 1,
    SendAuth = 2
};

/// @brief AuthenStatus matching the Idris2 ABI tags.
enum class AuthenStatus : uint8_t {
    Pass = 0,
    Fail = 1,
    GetData = 2,
    GetUser = 3,
    GetPass = 4,
    Restart = 5,
    Error = 6,
    Follow = 7
};

/// @brief AuthorStatus matching the Idris2 ABI tags.
enum class AuthorStatus : uint8_t {
    PassAdd = 0,
    PassRepl = 1,
    Fail = 2,
    Error = 3,
    Follow = 4
};

/// @brief AcctStatus matching the Idris2 ABI tags.
enum class AcctStatus : uint8_t {
    Success = 0,
    Error = 1,
    Follow = 2
};

/// @brief AcctFlag matching the Idris2 ABI tags.
enum class AcctFlag : uint8_t {
    Start = 0,
    Stop = 1,
    Watchdog = 2
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Authenticating = 1,
    Authorizing = 2,
    Active = 3,
    Closing = 4
};

} // namespace proven

#endif // PROVEN_TACACS_HPP
