<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** LeapIndicator matching the Idris2 ABI tags. */
enum LeapIndicator: int
{
    case NoWarning = 0;
    case LastMinute61 = 1;
    case LastMinute59 = 2;
    case Unsynchronised = 3;
}

/** NtpMode matching the Idris2 ABI tags. */
enum NtpMode: int
{
    case Reserved = 0;
    case SymmetricActive = 1;
    case SymmetricPassive = 2;
    case Client = 3;
    case Server = 4;
    case Broadcast = 5;
    case ControlMessage = 6;
    case Private = 7;
}

/** ExchangeState matching the Idris2 ABI tags. */
enum ExchangeState: int
{
    case Idle = 0;
    case RequestReceived = 1;
    case TimestampCalculated = 2;
    case ResponseSent = 3;
}

/** ClockDisciplineState matching the Idris2 ABI tags. */
enum ClockDisciplineState: int
{
    case Unset = 0;
    case Spike = 1;
    case Freq = 2;
    case Sync = 3;
    case Panic = 4;
}

/** KissCode matching the Idris2 ABI tags. */
enum KissCode: int
{
    case Deny = 0;
    case Rstr = 1;
    case Rate = 2;
    case Other = 3;
}

/** NtpError matching the Idris2 ABI tags. */
enum NtpError: int
{
    case Ok = 0;
    case InvalidSlot = 1;
    case NotActive = 2;
    case InvalidPacket = 3;
    case KissOfDeath = 4;
    case StratumTooHigh = 5;
}
