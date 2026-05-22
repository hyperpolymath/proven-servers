// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file chat.hpp
/// @brief Chat protocol types for proven-servers.

#ifndef PROVEN_CHAT_HPP
#define PROVEN_CHAT_HPP

#include <cstdint>

namespace proven {

/// @brief MessageType matching the Idris2 ABI tags.
enum class MessageType : uint8_t {
    Text = 0,
    Image = 1,
    File = 2,
    System = 3,
    Reaction = 4,
    Edit = 5,
    Delete = 6,
    Reply = 7,
    Thread = 8
};

/// @brief PresenceStatus matching the Idris2 ABI tags.
enum class PresenceStatus : uint8_t {
    Online = 0,
    Away = 1,
    Dnd = 2,
    Invisible = 3,
    Offline = 4
};

/// @brief RoomType matching the Idris2 ABI tags.
enum class RoomType : uint8_t {
    Direct = 0,
    Group = 1,
    Channel = 2,
    Broadcast = 3
};

/// @brief Permission matching the Idris2 ABI tags.
enum class Permission : uint8_t {
    Read = 0,
    Write = 1,
    Admin = 2,
    Invite = 3,
    Kick = 4,
    Ban = 5,
    Pin = 6,
    DeleteOthers = 7
};

/// @brief Event matching the Idris2 ABI tags.
enum class Event : uint8_t {
    MessageSent = 0,
    MessageDelivered = 1,
    MessageRead = 2,
    UserJoined = 3,
    UserLeft = 4,
    Typing = 5,
    RoomCreated = 6
};

} // namespace proven

#endif // PROVEN_CHAT_HPP
