// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file smb.hpp
/// @brief SMB protocol types for proven-servers.

#ifndef PROVEN_SMB_HPP
#define PROVEN_SMB_HPP

#include <cstdint>

namespace proven {

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    Negotiate = 0,
    SessionSetup = 1,
    Logoff = 2,
    TreeConnect = 3,
    TreeDisconnect = 4,
    Create = 5,
    Close = 6,
    Read = 7,
    Write = 8,
    Lock = 9,
    Ioctl = 10,
    Cancel = 11,
    QueryDirectory = 12,
    ChangeNotify = 13,
    QueryInfo = 14,
    SetInfo = 15
};

/// @brief Dialect matching the Idris2 ABI tags.
enum class Dialect : uint8_t {
    Smb2_0_2 = 0,
    Smb2_1 = 1,
    Smb3_0 = 2,
    Smb3_0_2 = 3,
    Smb3_1_1 = 4
};

/// @brief ShareType matching the Idris2 ABI tags.
enum class ShareType : uint8_t {
    Disk = 0,
    Pipe = 1,
    Print = 2
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Negotiated = 1,
    Authenticated = 2,
    TreeConnected = 3,
    FileOpen = 4,
    Disconnecting = 5
};

} // namespace proven

#endif // PROVEN_SMB_HPP
