// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for proven-servers.

namespace Proven;

/// <summary>MessageType matching the Idris2 ABI tags (0-7).</summary>
public enum MessageType : byte
{
    Discover = 0,
    Offer = 1,
    Request = 2,
    Ack = 3,
    Nak = 4,
    Release = 5,
    Inform = 6,
    Decline = 7
}

/// <summary>OptionCode matching the Idris2 ABI tags (0-7).</summary>
public enum OptionCode : byte
{
    SubnetMask = 0,
    Router = 1,
    Dns = 2,
    DomainName = 3,
    LeaseTime = 4,
    ServerId = 5,
    RequestedIp = 6,
    MsgType = 7
}

/// <summary>HardwareType matching the Idris2 ABI tags (0-3).</summary>
public enum HardwareType : byte
{
    Ethernet = 0,
    Ieee802 = 1,
    Arcnet = 2,
    FrameRelay = 3
}

/// <summary>DhcpState matching the Idris2 ABI tags (0-5).</summary>
public enum DhcpState : byte
{
    Idle = 0,
    DiscoverReceived = 1,
    OfferSent = 2,
    RequestReceived = 3,
    AckSent = 4,
    NakSent = 5
}

/// <summary>LeaseState matching the Idris2 ABI tags (0-5).</summary>
public enum LeaseState : byte
{
    Available = 0,
    Offered = 1,
    Bound = 2,
    Renewing = 3,
    Rebinding = 4,
    Expired = 5
}

/// <summary>RelaySubOption matching the Idris2 ABI tags (0-1).</summary>
public enum RelaySubOption : byte
{
    CircuitId = 0,
    RemoteId = 1
}
