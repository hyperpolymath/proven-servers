// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file xmpp.hpp
/// @brief XMPP protocol types for proven-servers.

#ifndef PROVEN_XMPP_HPP
#define PROVEN_XMPP_HPP

#include <cstdint>

namespace proven {

/// @brief StanzaType matching the Idris2 ABI tags.
enum class StanzaType : uint8_t {
    Message = 0,
    Presence = 1,
    Iq = 2
};

/// @brief MessageType matching the Idris2 ABI tags.
enum class MessageType : uint8_t {
    Chat = 0,
    Error = 1,
    Groupchat = 2,
    Headline = 3,
    Normal = 4
};

/// @brief PresenceType matching the Idris2 ABI tags.
enum class PresenceType : uint8_t {
    Available = 0,
    Away = 1,
    Dnd = 2,
    Xa = 3,
    Unavailable = 4
};

/// @brief IqType matching the Idris2 ABI tags.
enum class IqType : uint8_t {
    Get = 0,
    Set = 1,
    Result = 2,
    Error = 3
};

/// @brief StreamError matching the Idris2 ABI tags.
enum class StreamError : uint8_t {
    BadFormat = 0,
    Conflict = 1,
    ConnectionTimeout = 2,
    HostGone = 3,
    HostUnknown = 4,
    NotAuthorized = 5,
    PolicyViolation = 6,
    ResourceConstraint = 7,
    SystemShutdown = 8
};

} // namespace proven

#endif // PROVEN_XMPP_HPP
