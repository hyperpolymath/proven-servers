<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SDN protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** SdnMessageType matching the Idris2 ABI tags. */
enum SdnMessageType: int
{
    case Hello = 0;
    case Error = 1;
    case EchoRequest = 2;
    case EchoReply = 3;
    case FeaturesRequest = 4;
    case FeaturesReply = 5;
    case FlowMod = 6;
    case PacketIn = 7;
    case PacketOut = 8;
    case PortStatus = 9;
    case BarrierRequest = 10;
    case BarrierReply = 11;
}

/** FlowAction matching the Idris2 ABI tags. */
enum FlowAction: int
{
    case Output = 0;
    case SetField = 1;
    case Drop = 2;
    case PushVlan = 3;
    case PopVlan = 4;
    case SetQueue = 5;
    case Group = 6;
}

/** MatchField matching the Idris2 ABI tags. */
enum MatchField: int
{
    case InPort = 0;
    case EthDst = 1;
    case EthSrc = 2;
    case EthType = 3;
    case VlanId = 4;
    case IpSrc = 5;
    case IpDst = 6;
    case TcpSrc = 7;
    case TcpDst = 8;
    case UdpSrc = 9;
    case UdpDst = 10;
}

/** PortState matching the Idris2 ABI tags. */
enum PortState: int
{
    case Up = 0;
    case Down = 1;
    case Blocked = 2;
}
