// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ospf.hpp
/// @brief OSPF protocol types for proven-servers.

#ifndef PROVEN_OSPF_HPP
#define PROVEN_OSPF_HPP

#include <cstdint>

namespace proven {

/// @brief PacketType matching the Idris2 ABI tags.
enum class PacketType : uint8_t {
    Hello = 0,
    DatabaseDescription = 1,
    LinkStateRequest = 2,
    LinkStateUpdate = 3,
    LinkStateAck = 4
};

/// @brief NeighborState matching the Idris2 ABI tags.
enum class NeighborState : uint8_t {
    Down = 0,
    Attempt = 1,
    Init = 2,
    TwoWay = 3,
    ExStart = 4,
    Exchange = 5,
    Loading = 6,
    Full = 7
};

/// @brief LsaType matching the Idris2 ABI tags.
enum class LsaType : uint8_t {
    RouterLsa = 0,
    NetworkLsa = 1,
    SummaryLsa = 2,
    AsbrSummaryLsa = 3,
    AsExternalLsa = 4
};

/// @brief AreaType matching the Idris2 ABI tags.
enum class AreaType : uint8_t {
    Normal = 0,
    Stub = 1,
    TotallyStub = 2,
    Nssa = 3
};

/// @brief OspfError matching the Idris2 ABI tags.
enum class OspfError : uint8_t {
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidTransition = 3,
    InvalidPacket = 4,
    AreaError = 5,
    FloodLimit = 6
};

} // namespace proven

#endif // PROVEN_OSPF_HPP
