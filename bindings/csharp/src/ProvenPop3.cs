// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for proven-servers.

namespace Proven;

/// <summary>Command matching the Idris2 ABI tags (0-10).</summary>
public enum Command : byte
{
    User = 0,
    Pass = 1,
    Stat = 2,
    List = 3,
    Retr = 4,
    Dele = 5,
    Noop = 6,
    Rset = 7,
    Quit = 8,
    Top = 9,
    Uidl = 10
}

/// <summary>State matching the Idris2 ABI tags (0-2).</summary>
public enum State : byte
{
    Authorization = 0,
    Transaction = 1,
    Update = 2
}

/// <summary>Response matching the Idris2 ABI tags (0-1).</summary>
public enum Response : byte
{
    Ok = 0,
    Err = 1
}

/// <summary>Pop3Error matching the Idris2 ABI tags (0-5).</summary>
public enum Pop3Error : byte
{
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidTransition = 3,
    InvalidCommand = 4,
    AuthFailed = 5
}
