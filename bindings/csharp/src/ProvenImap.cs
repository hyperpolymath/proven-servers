// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for proven-servers.

namespace Proven;

/// <summary>Command matching the Idris2 ABI tags (0-13).</summary>
public enum Command : byte
{
    Login = 0,
    Logout = 1,
    Select = 2,
    Examine = 3,
    Create = 4,
    Delete = 5,
    Rename = 6,
    List = 7,
    Fetch = 8,
    Store = 9,
    Search = 10,
    Copy = 11,
    Noop = 12,
    Capability = 13
}

/// <summary>State matching the Idris2 ABI tags (0-3).</summary>
public enum State : byte
{
    NotAuthenticated = 0,
    Authenticated = 1,
    Selected = 2,
    Logout = 3
}

/// <summary>Flag matching the Idris2 ABI tags (0-5).</summary>
public enum Flag : byte
{
    Seen = 0,
    Answered = 1,
    Flagged = 2,
    Deleted = 3,
    Draft = 4,
    Recent = 5
}
