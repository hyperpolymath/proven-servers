// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for proven-servers.

namespace Proven;

/// <summary>LeapIndicator matching the Idris2 ABI tags (0-3).</summary>
public enum LeapIndicator : byte
{
    NoWarning = 0,
    LastMinute61 = 1,
    LastMinute59 = 2,
    Unsynchronised = 3
}

/// <summary>NtpMode matching the Idris2 ABI tags (0-7).</summary>
public enum NtpMode : byte
{
    Reserved = 0,
    SymmetricActive = 1,
    SymmetricPassive = 2,
    Client = 3,
    Server = 4,
    Broadcast = 5,
    ControlMessage = 6,
    Private = 7
}

/// <summary>ExchangeState matching the Idris2 ABI tags (0-3).</summary>
public enum ExchangeState : byte
{
    Idle = 0,
    RequestReceived = 1,
    TimestampCalculated = 2,
    ResponseSent = 3
}

/// <summary>ClockDisciplineState matching the Idris2 ABI tags (0-4).</summary>
public enum ClockDisciplineState : byte
{
    Unset = 0,
    Spike = 1,
    Freq = 2,
    Sync = 3,
    Panic = 4
}

/// <summary>KissCode matching the Idris2 ABI tags (0-3).</summary>
public enum KissCode : byte
{
    Deny = 0,
    Rstr = 1,
    Rate = 2,
    Other = 3
}

/// <summary>NtpError matching the Idris2 ABI tags (0-5).</summary>
public enum NtpError : byte
{
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidPacket = 3,
    KissOfDeath = 4,
    StratumTooHigh = 5
}
