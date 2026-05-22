// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file rtsp.hpp
/// @brief RTSP protocol types for proven-servers.

#ifndef PROVEN_RTSP_HPP
#define PROVEN_RTSP_HPP

#include <cstdint>

namespace proven {

/// @brief Method matching the Idris2 ABI tags.
enum class Method : uint8_t {
    Describe = 0,
    Setup = 1,
    Play = 2,
    Pause = 3,
    Teardown = 4,
    GetParameter = 5,
    SetParameter = 6,
    Options = 7,
    Announce = 8,
    Record = 9,
    Redirect = 10
};

/// @brief TransportProtocol matching the Idris2 ABI tags.
enum class TransportProtocol : uint8_t {
    RtpAvpUdp = 0,
    RtpAvpTcp = 1,
    RtpAvpUdpMulticast = 2
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Init = 0,
    Ready = 1,
    Playing = 2,
    Recording = 3
};

/// @brief StatusCode matching the Idris2 ABI tags.
enum class StatusCode : uint8_t {
    Ok = 0,
    MovedPermanently = 1,
    MovedTemporarily = 2,
    BadRequest = 3,
    Unauthorized = 4,
    NotFound = 5,
    MethodNotAllowed = 6,
    NotAcceptable = 7,
    SessionNotFound = 8,
    InternalServerError = 9,
    NotImplemented = 10,
    ServiceUnavailable = 11
};

/// @brief RtspError matching the Idris2 ABI tags.
enum class RtspError : uint8_t {
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidTransition = 3,
    MethodNotAllowed = 4,
    TransportError = 5,
    SessionExpired = 6
};

} // namespace proven

#endif // PROVEN_RTSP_HPP
