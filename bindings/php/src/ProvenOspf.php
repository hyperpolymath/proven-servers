<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OSPF protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** PacketType matching the Idris2 ABI tags. */
enum PacketType: int
{
    case Hello = 0;
    case DatabaseDescription = 1;
    case LinkStateRequest = 2;
    case LinkStateUpdate = 3;
    case LinkStateAck = 4;
}

/** NeighborState matching the Idris2 ABI tags. */
enum NeighborState: int
{
    case Down = 0;
    case Attempt = 1;
    case Init = 2;
    case TwoWay = 3;
    case ExStart = 4;
    case Exchange = 5;
    case Loading = 6;
    case Full = 7;
}

/** LsaType matching the Idris2 ABI tags. */
enum LsaType: int
{
    case RouterLsa = 0;
    case NetworkLsa = 1;
    case SummaryLsa = 2;
    case AsbrSummaryLsa = 3;
    case AsExternalLsa = 4;
}

/** AreaType matching the Idris2 ABI tags. */
enum AreaType: int
{
    case Normal = 0;
    case Stub = 1;
    case TotallyStub = 2;
    case Nssa = 3;
}

/** OspfError matching the Idris2 ABI tags. */
enum OspfError: int
{
    case Ok = 0;
    case InvalidSlot = 1;
    case NotActive = 2;
    case InvalidTransition = 3;
    case InvalidPacket = 4;
    case AreaError = 5;
    case FloodLimit = 6;
}
