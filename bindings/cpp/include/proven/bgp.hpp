// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file bgp.hpp
/// @brief BGP protocol types for proven-servers.

#ifndef PROVEN_BGP_HPP
#define PROVEN_BGP_HPP

#include <cstdint>

namespace proven {

/// @brief BgpState matching the Idris2 ABI tags.
enum class BgpState : uint8_t {
    Idle = 0,
    Connect = 1,
    Active = 2,
    OpenSent = 3,
    OpenConfirm = 4,
    Established = 5
};

/// @brief BgpEvent matching the Idris2 ABI tags.
enum class BgpEvent : uint8_t {
    ManualStart = 0,
    ManualStop = 1,
    AutomaticStart = 2,
    ConnectRetryTimerExpires = 3,
    HoldTimerExpires = 4,
    KeepaliveTimerExpires = 5,
    DelayOpenTimerExpires = 6,
    TcpConnectionValid = 7,
    TcpCrAcked = 8,
    TcpConnectionConfirmed = 9,
    TcpConnectionFails = 10,
    BgpOpenReceived = 11,
    BgpHeaderErr = 12,
    BgpOpenMsgErr = 13,
    NotifMsgVerErr = 14,
    NotifMsg = 15,
    KeepaliveMsg = 16,
    UpdateMsg = 17,
    UpdateMsgErr = 18
};

/// @brief MessageType matching the Idris2 ABI tags.
enum class MessageType : uint8_t {
    Open = 0,
    Update = 1,
    Notification = 2,
    Keepalive = 3
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
    MessageHeaderError = 0,
    OpenMessageError = 1,
    UpdateMessageError = 2,
    HoldTimerExpired = 3,
    FsmError = 4,
    Cease = 5
};

/// @brief Origin matching the Idris2 ABI tags.
enum class Origin : uint8_t {
    Igp = 0,
    Egp = 1,
    Incomplete = 2
};

/// @brief AsPathSegmentType matching the Idris2 ABI tags.
enum class AsPathSegmentType : uint8_t {
    AsSet = 0,
    AsSequence = 1
};

/// @brief PathAttrType matching the Idris2 ABI tags.
enum class PathAttrType : uint8_t {
    Origin = 0,
    AsPath = 1,
    NextHop = 2,
    Med = 3,
    LocalPref = 4,
    AtomicAggr = 5,
    Aggregator = 6,
    Unknown = 7
};

} // namespace proven

#endif // PROVEN_BGP_HPP
