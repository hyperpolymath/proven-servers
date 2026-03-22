// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file sdn.hpp
/// @brief SDN protocol types for proven-servers.

#ifndef PROVEN_SDN_HPP
#define PROVEN_SDN_HPP

#include <cstdint>

namespace proven {

/// @brief SdnMessageType matching the Idris2 ABI tags.
enum class SdnMessageType : uint8_t {
    Hello = 0,
    Error = 1,
    EchoRequest = 2,
    EchoReply = 3,
    FeaturesRequest = 4,
    FeaturesReply = 5,
    FlowMod = 6,
    PacketIn = 7,
    PacketOut = 8,
    PortStatus = 9,
    BarrierRequest = 10,
    BarrierReply = 11
};

/// @brief FlowAction matching the Idris2 ABI tags.
enum class FlowAction : uint8_t {
    Output = 0,
    SetField = 1,
    Drop = 2,
    PushVlan = 3,
    PopVlan = 4,
    SetQueue = 5,
    Group = 6
};

/// @brief MatchField matching the Idris2 ABI tags.
enum class MatchField : uint8_t {
    InPort = 0,
    EthDst = 1,
    EthSrc = 2,
    EthType = 3,
    VlanId = 4,
    IpSrc = 5,
    IpDst = 6,
    TcpSrc = 7,
    TcpDst = 8,
    UdpSrc = 9,
    UdpDst = 10
};

/// @brief PortState matching the Idris2 ABI tags.
enum class PortState : uint8_t {
    Up = 0,
    Down = 1,
    Blocked = 2
};

} // namespace proven

#endif // PROVEN_SDN_HPP
