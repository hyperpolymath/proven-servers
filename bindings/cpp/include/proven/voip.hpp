// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file voip.hpp
/// @brief VoIP/SIP protocol types for proven-servers.

#ifndef PROVEN_VOIP_HPP
#define PROVEN_VOIP_HPP

#include <cstdint>

namespace proven {

/// @brief Method matching the Idris2 ABI tags.
enum class Method : uint8_t {
    Invite = 0,
    Ack = 1,
    Bye = 2,
    Cancel = 3,
    Register = 4,
    Options = 5,
    Info = 6,
    Update = 7,
    Subscribe = 8,
    Notify = 9,
    Refer = 10,
    Message = 11,
    Prack = 12
};

/// @brief ResponseCode matching the Idris2 ABI tags.
enum class ResponseCode : uint8_t {
    Trying = 0,
    Ringing = 1,
    SessionProgress = 2,
    Ok = 3,
    MultipleChoices = 4,
    MovedPermanently = 5,
    MovedTemporarily = 6,
    BadRequest = 7,
    Unauthorized = 8,
    Forbidden = 9,
    NotFound = 10,
    MethodNotAllowed = 11,
    RequestTimeout = 12,
    BusyHere = 13,
    Decline = 14,
    ServerInternalError = 15,
    ServiceUnavailable = 16
};

/// @brief DialogState matching the Idris2 ABI tags.
enum class DialogState : uint8_t {
    Early = 0,
    Confirmed = 1,
    Terminated = 2
};

} // namespace proven

#endif // PROVEN_VOIP_HPP
