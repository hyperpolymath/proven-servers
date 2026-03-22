// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file git.hpp
/// @brief Git protocol types for proven-servers.

#ifndef PROVEN_GIT_HPP
#define PROVEN_GIT_HPP

#include <cstdint>

namespace proven {

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    UploadPack = 0,
    ReceivePack = 1,
    UploadArchive = 2
};

/// @brief PacketType matching the Idris2 ABI tags.
enum class PacketType : uint8_t {
    Flush = 0,
    Delimiter = 1,
    ResponseEnd = 2,
    Data = 3,
    PktError = 4,
    SidebandData = 5,
    SidebandProgress = 6,
    SidebandError = 7
};

/// @brief RefType matching the Idris2 ABI tags.
enum class RefType : uint8_t {
    Branch = 0,
    Tag = 1,
    Head = 2,
    Remote = 3,
    GitNote = 4
};

/// @brief Capability matching the Idris2 ABI tags.
enum class Capability : uint8_t {
    MultiAck = 0,
    ThinPack = 1,
    SideBand64k = 2,
    OfsDelta = 3,
    Shallow = 4,
    DeepenSince = 5,
    DeepenNot = 6,
    FilterSpec = 7,
    ObjectFormat = 8
};

/// @brief HookResult matching the Idris2 ABI tags.
enum class HookResult : uint8_t {
    Accept = 0,
    Reject = 1
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Discovery = 1,
    Negotiating = 2,
    Transfer = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_GIT_HPP
