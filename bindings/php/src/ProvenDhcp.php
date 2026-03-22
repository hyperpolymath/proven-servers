<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** MessageType matching the Idris2 ABI tags. */
enum MessageType: int
{
    case Discover = 0;
    case Offer = 1;
    case Request = 2;
    case Ack = 3;
    case Nak = 4;
    case Release = 5;
    case Inform = 6;
    case Decline = 7;
}

/** OptionCode matching the Idris2 ABI tags. */
enum OptionCode: int
{
    case SubnetMask = 0;
    case Router = 1;
    case Dns = 2;
    case DomainName = 3;
    case LeaseTime = 4;
    case ServerId = 5;
    case RequestedIp = 6;
    case MsgType = 7;
}

/** HardwareType matching the Idris2 ABI tags. */
enum HardwareType: int
{
    case Ethernet = 0;
    case Ieee802 = 1;
    case Arcnet = 2;
    case FrameRelay = 3;
}

/** DhcpState matching the Idris2 ABI tags. */
enum DhcpState: int
{
    case Idle = 0;
    case DiscoverReceived = 1;
    case OfferSent = 2;
    case RequestReceived = 3;
    case AckSent = 4;
    case NakSent = 5;
}

/** LeaseState matching the Idris2 ABI tags. */
enum LeaseState: int
{
    case Available = 0;
    case Offered = 1;
    case Bound = 2;
    case Renewing = 3;
    case Rebinding = 4;
    case Expired = 5;
}

/** RelaySubOption matching the Idris2 ABI tags. */
enum RelaySubOption: int
{
    case CircuitId = 0;
    case RemoteId = 1;
}
