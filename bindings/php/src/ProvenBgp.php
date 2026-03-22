<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BGP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** BgpState matching the Idris2 ABI tags. */
enum BgpState: int
{
    case Idle = 0;
    case Connect = 1;
    case Active = 2;
    case OpenSent = 3;
    case OpenConfirm = 4;
    case Established = 5;
}

/** BgpEvent matching the Idris2 ABI tags. */
enum BgpEvent: int
{
    case ManualStart = 0;
    case ManualStop = 1;
    case AutomaticStart = 2;
    case ConnectRetryTimerExpires = 3;
    case HoldTimerExpires = 4;
    case KeepaliveTimerExpires = 5;
    case DelayOpenTimerExpires = 6;
    case TcpConnectionValid = 7;
    case TcpCrAcked = 8;
    case TcpConnectionConfirmed = 9;
    case TcpConnectionFails = 10;
    case BgpOpenReceived = 11;
    case BgpHeaderErr = 12;
    case BgpOpenMsgErr = 13;
    case NotifMsgVerErr = 14;
    case NotifMsg = 15;
    case KeepaliveMsg = 16;
    case UpdateMsg = 17;
    case UpdateMsgErr = 18;
}

/** MessageType matching the Idris2 ABI tags. */
enum MessageType: int
{
    case Open = 0;
    case Update = 1;
    case Notification = 2;
    case Keepalive = 3;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case MessageHeaderError = 0;
    case OpenMessageError = 1;
    case UpdateMessageError = 2;
    case HoldTimerExpired = 3;
    case FsmError = 4;
    case Cease = 5;
}

/** Origin matching the Idris2 ABI tags. */
enum Origin: int
{
    case Igp = 0;
    case Egp = 1;
    case Incomplete = 2;
}

/** AsPathSegmentType matching the Idris2 ABI tags. */
enum AsPathSegmentType: int
{
    case AsSet = 0;
    case AsSequence = 1;
}

/** PathAttrType matching the Idris2 ABI tags. */
enum PathAttrType: int
{
    case Origin = 0;
    case AsPath = 1;
    case NextHop = 2;
    case Med = 3;
    case LocalPref = 4;
    case AtomicAggr = 5;
    case Aggregator = 6;
    case Unknown = 7;
}
