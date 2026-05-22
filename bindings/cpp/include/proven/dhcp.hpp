// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file dhcp.hpp
/// @brief DHCP protocol types for proven-servers.

#ifndef PROVEN_DHCP_HPP
#define PROVEN_DHCP_HPP

#include <cstdint>

namespace proven {

/// @brief MessageType matching the Idris2 ABI tags.
enum class MessageType : uint8_t {
    Discover = 0,
    Offer = 1,
    Request = 2,
    Ack = 3,
    Nak = 4,
    Release = 5,
    Inform = 6,
    Decline = 7
};

/// @brief OptionCode matching the Idris2 ABI tags.
enum class OptionCode : uint8_t {
    SubnetMask = 0,
    Router = 1,
    Dns = 2,
    DomainName = 3,
    LeaseTime = 4,
    ServerId = 5,
    RequestedIp = 6,
    MsgType = 7
};

/// @brief HardwareType matching the Idris2 ABI tags.
enum class HardwareType : uint8_t {
    Ethernet = 0,
    Ieee802 = 1,
    Arcnet = 2,
    FrameRelay = 3
};

/// @brief DhcpState matching the Idris2 ABI tags.
enum class DhcpState : uint8_t {
    Idle = 0,
    DiscoverReceived = 1,
    OfferSent = 2,
    RequestReceived = 3,
    AckSent = 4,
    NakSent = 5
};

/// @brief LeaseState matching the Idris2 ABI tags.
enum class LeaseState : uint8_t {
    Available = 0,
    Offered = 1,
    Bound = 2,
    Renewing = 3,
    Rebinding = 4,
    Expired = 5
};

/// @brief RelaySubOption matching the Idris2 ABI tags.
enum class RelaySubOption : uint8_t {
    CircuitId = 0,
    RemoteId = 1
};

} // namespace proven

#endif // PROVEN_DHCP_HPP
