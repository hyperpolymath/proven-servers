// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Telnet protocol types for proven-servers.

namespace Proven;

/// <summary>Command matching the Idris2 ABI tags (0-15).</summary>
public enum Command : byte
{
    Se = 0,
    Nop = 1,
    DataMark = 2,
    Break = 3,
    InterruptProcess = 4,
    AbortOutput = 5,
    AreYouThere = 6,
    EraseChar = 7,
    EraseLine = 8,
    GoAhead = 9,
    Sb = 10,
    Will = 11,
    Wont = 12,
    Do = 13,
    Dont = 14,
    Iac = 15
}

/// <summary>TelnetOption matching the Idris2 ABI tags (0-9).</summary>
public enum TelnetOption : byte
{
    Echo = 0,
    SuppressGoAhead = 1,
    Status = 2,
    TimingMark = 3,
    TerminalType = 4,
    WindowSize = 5,
    TerminalSpeed = 6,
    RemoteFlowControl = 7,
    Linemode = 8,
    Environment = 9
}

/// <summary>NegotiationState matching the Idris2 ABI tags (0-3).</summary>
public enum NegotiationState : byte
{
    Inactive = 0,
    WillSent = 1,
    DoSent = 2,
    Active = 3
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Negotiating = 1,
    Active = 2,
    Subneg = 3,
    Closing = 4
}
