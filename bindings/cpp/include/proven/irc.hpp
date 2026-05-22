// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file irc.hpp
/// @brief IRC protocol types for proven-servers.

#ifndef PROVEN_IRC_HPP
#define PROVEN_IRC_HPP

#include <cstdint>

namespace proven {

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    Nick = 0,
    User = 1,
    Join = 2,
    Part = 3,
    Privmsg = 4,
    Notice = 5,
    Quit = 6,
    Ping = 7,
    Pong = 8,
    Mode = 9,
    Kick = 10,
    Topic = 11,
    Invite = 12,
    Names = 13,
    List = 14,
    Who = 15,
    Whois = 16
};

/// @brief NumericReply matching the Idris2 ABI tags.
enum class NumericReply : uint8_t {
    Welcome = 0,
    YourHost = 1,
    Created = 2,
    MyInfo = 3,
    Bounce = 4,
    NickInUse = 5,
    NoSuchNick = 6,
    NoSuchChannel = 7,
    ChannelIsFull = 8,
    InviteOnlyChan = 9,
    BannedFromChan = 10
};

/// @brief ChannelMode matching the Idris2 ABI tags.
enum class ChannelMode : uint8_t {
    Op = 0,
    Voice = 1,
    Ban = 2,
    Limit = 3,
    InviteOnly = 4,
    Moderated = 5,
    NoExternalMsgs = 6,
    TopicLock = 7,
    Secret = 8,
    Private = 9
};

/// @brief State matching the Idris2 ABI tags.
enum class State : uint8_t {
    Disconnected = 0,
    Connecting = 1,
    Registered = 2,
    InChannel = 3,
    Quitting = 4
};

/// @brief IrcError matching the Idris2 ABI tags.
enum class IrcError : uint8_t {
    None = 0,
    NickInUse = 1,
    ChannelFull = 2,
    InviteOnly = 3,
    Banned = 4,
    NotRegistered = 5
};

} // namespace proven

#endif // PROVEN_IRC_HPP
