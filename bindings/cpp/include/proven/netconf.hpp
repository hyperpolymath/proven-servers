// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file netconf.hpp
/// @brief NETCONF protocol types for proven-servers.

#ifndef PROVEN_NETCONF_HPP
#define PROVEN_NETCONF_HPP

#include <cstdint>

namespace proven {

/// @brief NetconfOperation matching the Idris2 ABI tags.
enum class NetconfOperation : uint8_t {
    Get = 0,
    GetConfig = 1,
    EditConfig = 2,
    CopyConfig = 3,
    DeleteConfig = 4,
    Lock = 5,
    Unlock = 6,
    CloseSession = 7,
    KillSession = 8,
    Commit = 9,
    Validate = 10,
    DiscardChanges = 11
};

/// @brief Datastore matching the Idris2 ABI tags.
enum class Datastore : uint8_t {
    Running = 0,
    Startup = 1,
    Candidate = 2
};

/// @brief EditOperation matching the Idris2 ABI tags.
enum class EditOperation : uint8_t {
    Merge = 0,
    Replace = 1,
    Create = 2,
    Delete = 3,
    Remove = 4
};

/// @brief NetconfErrorType matching the Idris2 ABI tags.
enum class NetconfErrorType : uint8_t {
    Transport = 0,
    Rpc = 1,
    Protocol = 2,
    Application = 3
};

/// @brief ErrorSeverity matching the Idris2 ABI tags.
enum class ErrorSeverity : uint8_t {
    Error = 0,
    Warning = 1
};

/// @brief NetconfState matching the Idris2 ABI tags.
enum class NetconfState : uint8_t {
    Idle = 0,
    Connected = 1,
    Locked = 2,
    Editing = 3,
    Closing = 4,
    Terminated = 5
};

} // namespace proven

#endif // PROVEN_NETCONF_HPP
